//C Standard Library
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

//Lua Library
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//UNIX headers
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

//Cube of Time headers
#include "l_userio.h"
#include "l_rng.h"

extern char* getenv(char* s);

typedef enum
{
    MAINARG_TESTFILE,
    MAINARG_CONFIGFILE,
    MAINARG_MAX
}
t_mainarg;

bool strcmp_or(const char* to_judge, const char* alt1, const char* alt2)
{
    return !strcmp(to_judge, alt1) || !strcmp(to_judge, alt2);
}

//argsort must have size MAINARG MAX, argv must have size argc
void interpret_args(int argc, char* argv[], char* argsort[])
{
    //Skip exec name, increment up to second-to-last arg
    for(int i = 1; i < (argc-1); i++) 
    {
        if(strcmp_or(argv[i], "--test", "-t"))
            argsort[MAINARG_TESTFILE] = argv[i+1];
        if(strcmp_or(argv[i], "--config", "-c"))
            argsort[MAINARG_CONFIGFILE] = argv[i+1];
    }
}

void setup_package_path(lua_State* L, char* argsort[])
{
    const char* src_dir = "./src/?.lua";
    const char* test_dir = "./test/?.lua";
    lua_settop(L, 0);
    
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    luaL_addstring(&b, src_dir);
    if(argsort[MAINARG_TESTFILE])
    {
        luaL_addchar(&b, ';');
        luaL_addstring(&b, test_dir);
    }

    luaL_pushresult(&b);
    lua_getglobal(L, "package");
    lua_insert(L, -2);
    lua_setfield(L, 1, "path");
    lua_settop(L, 0);
}

void setup_config_path(lua_State* L, char* argsort[])
{
    const char* config_varname = "CUBE_CONFIG";
    lua_settop(L, 0);
    if(argsort[MAINARG_CONFIGFILE])
    {
        lua_pushstring(L, argsort[MAINARG_CONFIGFILE]);
        lua_setglobal(L, config_varname);
    }
    else
    {
        char* home_dir = getenv("HOME");
        if(!home_dir && getpwuid(getuid()))
            home_dir = getpwuid(getuid())->pw_dir;
        if(home_dir)
        {
            const char* config_filename = ".cuberc";
            lua_pushstring(L, home_dir);
            lua_pushstring(L, "/");
            lua_pushstring(L, config_filename);
            lua_concat(L, 3);
            lua_setglobal(L, config_varname);
        }
    }
    lua_settop(L, 0);
}

int main(int argc, char* argv[])
{
    //Sort arguments
    char* argsort[MAINARG_MAX];
    for(int i = 0; i < MAINARG_MAX; i++)
    {
        argsort[i] = NULL;
    }
    interpret_args(argc, argv, argsort);
    
    //Setup Lua state
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);
    setup_package_path(L, argsort);
    setup_config_path(L, argsort);

    luaopen_userio(L);
    luaopen_rng(L);

    //Choose entry point and run
    int status = 0;
    if(argsort[MAINARG_TESTFILE])
        status = luaL_dofile(L, argsort[MAINARG_TESTFILE]);
    else
    {    
        userio_override_lib(L);
        userio_init();
        status = luaL_dofile(L, "./src/start.lua");
        userio_destroy();
    }

    //Exit
    if(status)
        printf("%s\n", lua_tostring(L, -1));
    lua_close(L);
    return 0;
}
