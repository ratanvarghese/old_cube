#pragma once

#include <lua.h>

/*C*/
int userio_init();
int userio_destroy();
void userio_override_lib(lua_State* L);

/*Lua*/
int luaopen_userio(lua_State* L);
