#include "base.h"

void base_openlib(lua_State* L, const luaL_Reg* lib, const char* lbname)
{
    lua_newtable(L);
    for(int i = 0; lib[i].name != NULL; i++)
    {
        lua_pushcfunction(L, lib[i].func);
        lua_setfield(L, 1, lib[i].name);
    }
    lua_setglobal(L, lbname);
}
