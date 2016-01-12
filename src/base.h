#pragma once

#include <lua.h>
#include <lauxlib.h>

void base_openlib(lua_State* L, const luaL_Reg* lib, const char* lbname);
