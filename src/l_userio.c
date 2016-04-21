//C Standard Library
#include <stdbool.h>

//POSIX
#include <unistd.h>

//Ncurses Library
#include <ncurses.h>

//Lua Library
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//Cube of Time Headers
#include "l_userio.h"

extern int usleep(__useconds_t);

//Static globals
static WINDOW *msgwin, *mapwin, *statwin;
int ready = 0;
#define USERIO_MAX_X 80
#define USERIO_MAX_Y 20
const char* lbname = "userio";

//Global C functions
int userio_init()
{
    if(ready)
        return 1;

    initscr();
    raw();
    keypad(stdscr, TRUE);
    noecho();
    curs_set(0);

    msgwin = newwin(2, USERIO_MAX_X, 0, 0);
    mapwin = newwin(USERIO_MAX_Y, USERIO_MAX_X, 2, 0);
    statwin = newwin(2, USERIO_MAX_X, USERIO_MAX_Y+2, 0);
    
    nodelay(mapwin, false);
    ready = 1;
    return 0;
}

int userio_destroy()
{
    if(!ready)
        return 1;

    delwin(msgwin);
    delwin(mapwin);
    delwin(statwin);
    delwin(stdscr);
    endwin();

    msgwin = NULL;
    mapwin = NULL;
    statwin = NULL;

    ready = 0;
    return 0;
}

void userio_override_lib(lua_State* L)
{
    //Most of the codebase should NOT deal with these raw IO functions!
    //Be sure to change userio.lua if changing the UI
    lua_getglobal(L, "require");
    lua_pushfstring(L, lbname);
    lua_call(L, 1, 0);
    lua_settop(L, 0);
}

//Lua functions
void unready_interface_check(lua_State* L, char* msg)
{
    if(!ready)
    {
        lua_pushfstring(L, "Attempt to %s unready interface\n", msg);
        lua_error(L);
    }
}

static int l_display_char(lua_State* L)
{
    unready_interface_check(L, "display char to");
    const char* c = luaL_checkstring(L, -3);
    int x = (int) luaL_checkinteger(L, -2);
    int y = (int) luaL_checkinteger(L, -1);

    if(x >= USERIO_MAX_X || x < 0 || y >= USERIO_MAX_Y || y < 0)
    {
        lua_pushfstring(L, "Error display \"%c\" to (%d,%d)", *c, x, y);
        lua_error(L);
    }

    int need_display = mvwinch(mapwin, y, x) != *c;
    if(need_display)
        mvwaddch(mapwin, y, x, *c);

    lua_pushboolean(L, need_display);
    return 1;
}

static int l_display_refresh(lua_State* L)
{
    unready_interface_check(L, "refresh display of");
    wrefresh(mapwin);
    return 0;
}

static int l_display_clear(lua_State* L)
{
    unready_interface_check(L, "clear display of");
    wclear(mapwin);
    return 0;
}

static int l_get_max_x(lua_State* L)
{
    lua_pushinteger(L, USERIO_MAX_X);
    return 1;
}

static int l_get_max_y(lua_State* L)
{
    lua_pushinteger(L, USERIO_MAX_Y);
    return 1;
}

static int l_message(lua_State* L)
{
    unready_interface_check(L, "print message to");
    wmove(msgwin, 1, 0);
    wclrtoeol(msgwin);
    wmove(msgwin, 0, 0);
    wclrtoeol(msgwin);
    mvwprintw(msgwin, 0, 0, luaL_checkstring(L, -1));
    wrefresh(msgwin);
    return 0;
}

static int l_get_char(lua_State* L)
{
    unready_interface_check(L, "get char from");
    //Want to avoid filling input buffer when user holds down a key.
    //Also want to avoid hogging the CPU.
    nodelay(mapwin, true);
    char c = ERR;
    while(c == ERR)
    {
        c = wgetch(mapwin);
        usleep(5000);
    }
    lua_pushfstring(L, "%c", c);
    while(wgetch(mapwin) != ERR)
        usleep(5000);
    nodelay(mapwin, false);

    wmove(msgwin, 1, 0);
    wclrtoeol(msgwin);
    wmove(msgwin, 0, 0);
    wclrtoeol(msgwin);
    wrefresh(msgwin);
    return 1;
}

static int l_get_string(lua_State* L)
{
    unready_interface_check(L, "get string from");
    char input_buf[USERIO_MAX_X];
    size_t n_prompt = 0, pre_input_gap = 0;
    const size_t prompt_limit = 3*(USERIO_MAX_X/4);
    const char* prompt = lua_tolstring(L, -1, &n_prompt); //Optional

    if(n_prompt > prompt_limit)
    {
        lua_pushfstring(L, "input prompt too long");
        lua_error(L);
    }

    wmove(msgwin, 1, 0);
    wclrtoeol(msgwin);
    wmove(msgwin, 0, 0);
    wclrtoeol(msgwin);
    if(prompt && n_prompt)
    {
        mvwprintw(msgwin, 0, 0, prompt);
        wrefresh(msgwin);
        pre_input_gap = n_prompt + 1;
    }

    wmove(msgwin, 0, 0);
    echo();
    curs_set(1);
    mvwgetnstr(
        msgwin,
        0,
        pre_input_gap,
        input_buf,
        USERIO_MAX_X - n_prompt - 2
    );
    curs_set(0);
    noecho();
    wrefresh(msgwin);

    lua_pushfstring(L, "%s", input_buf); 
    return 1;
}

static const struct luaL_Reg userio_lib [] = {
    {"message", l_message},
    {"get_char", l_get_char},
    {"get_string", l_get_string},
    {"display_char", l_display_char},
    {"display_clear", l_display_clear},
    {"display_refresh", l_display_refresh},
    {"get_max_x", l_get_max_x},
    {"get_max_y", l_get_max_y},
    {NULL, NULL} //Sentinel
};

int luaopen_userio(lua_State* L)
{
    luaL_newlib(L, userio_lib);
    lua_setglobal(L, lbname);
    return 0;
}
