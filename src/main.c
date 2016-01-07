/*C Standard Library*/
#include <stdio.h>

/*Lua Library*/
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(int argc, char* argv[])
{
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    const char* lua_path = "./src/?.lua;./test/?.lua";
    lua_settop(L, 0);
    lua_getglobal(L, "package");
    lua_pushstring(L, lua_path);
    lua_setfield(L, 1, "path");
    lua_settop(L, 0);

    int status = 0;
    if(argc < 2)
        status = luaL_dofile(L, "./src/start.lua");
    else
        status = luaL_dofile(L, argv[1]);

    if(status)
        printf("%s\n", lua_tostring(L, -1));
    lua_close(L);
    return 0;
}
