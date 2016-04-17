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
#include <signal.h>

//Cube of Time headers
#include "l_userio.h"
#include "l_rng.h"

extern char* getenv(char* s);

typedef enum
{
    MAINARG_TESTFILE,
    MAINARG_CONFIGFILE,
    MAINARG_REPLAY,
    MAINARG_SAVEDIR,
    MAINARG_MAX
}
t_mainarg;

const char* flag_l[MAINARG_MAX] = 
{
    [MAINARG_TESTFILE] = "--test",
    [MAINARG_CONFIGFILE] = "--config",
    [MAINARG_REPLAY] = "--replay",
    [MAINARG_SAVEDIR] = "--savedir"
};

const char* flag_s[MAINARG_MAX] = 
{
    [MAINARG_TESTFILE] = "-t",
    [MAINARG_CONFIGFILE] = "-c",
    [MAINARG_REPLAY] = "-r",
    [MAINARG_SAVEDIR] = "-s"
};

bool equalarg(const char* s, t_mainarg argcode)
{
    return !strcmp(s, flag_s[argcode]) || !strcmp(s, flag_l[argcode]);
}

//argsort must have size MAINARG MAX, argv must have size argc
void interpret_args(int argc, char* argv[], char* argsort[])
{
    for(int i = 0; i < MAINARG_MAX; i++)
    {
        argsort[i] = NULL;
    }
    //Skip exec name, increment up to second-to-last arg
    for(int i = 1; i < (argc-1); i++) 
    {
        for(t_mainarg j = 0; j < MAINARG_MAX; j++)
        {
            if(!argsort[j] && equalarg(argv[i], j))
                argsort[j] = argv[i+1];
        }
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

void setup_lualibs(lua_State* L, char* argsort[])
{
    if(argsort[MAINARG_TESTFILE])
    {
        luaL_openlibs(L);
    }
    else
    {
        //Only need a subsection of the standard libs
        const luaL_Reg loadedlibs[] = {
            {"_G", luaopen_base},
            {LUA_LOADLIBNAME, luaopen_package},
            {LUA_COLIBNAME, luaopen_coroutine}, //for time module
            {LUA_TABLIBNAME, luaopen_table},
            {LUA_IOLIBNAME, luaopen_io}, //for reading config/save files
            {LUA_STRLIBNAME, luaopen_string},
            {LUA_MATHLIBNAME, luaopen_math}, //for time module, harmless
            {NULL, NULL}
        };
        for(const luaL_Reg* lib = loadedlibs; lib->func; lib++)
        {
            luaL_requiref(L, lib->name, lib->func, 1);
            lua_pop(L, 1);
        }
    }
}

void setup_replay(lua_State* L, char* argsort[])
{
    lua_settop(L, 0);
    
    const char* replay_varname = "REPLAY_MODE";
    if(argsort[MAINARG_REPLAY])
    {
        lua_pushstring(L, argsort[MAINARG_REPLAY]);
        lua_setglobal(L, replay_varname);
    }

    const char* savedir_varname = "SAVE_DIR";
    char* savedir;
    if(argsort[MAINARG_SAVEDIR])
        savedir = argsort[MAINARG_SAVEDIR];
    else
        savedir = "./save/";
    lua_pushstring(L, savedir);
    lua_setglobal(L, savedir_varname);

    const char* nonexist_file_errnum_varname = "NONEXIST_FILE_ERRNUM";
    lua_Integer nonexist_file_errnum = 2; //System-specific
    lua_pushinteger(L, nonexist_file_errnum);
    lua_setglobal(L, nonexist_file_errnum_varname);

    lua_settop(L, 0);
}

void setup_cubelibs(lua_State* L)
{
    //Needs to run after all the other setup
    luaopen_userio(L);
    luaopen_rng(L);
}

int main(int argc, char* argv[])
{
    //Sort arguments
    char* argsort[MAINARG_MAX];
    interpret_args(argc, argv, argsort);
    
    //Setup Lua state
    lua_State* L = luaL_newstate();
    setup_lualibs(L, argsort);
    setup_package_path(L, argsort);
    setup_config_path(L, argsort);
    setup_replay(L, argsort);
    setup_cubelibs(L);

    //Choose entry point and run
    int status = 0;
    if(argsort[MAINARG_TESTFILE])
    {
        status = luaL_dofile(L, argsort[MAINARG_TESTFILE]);
    }
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
