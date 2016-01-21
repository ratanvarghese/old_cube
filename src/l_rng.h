#pragma once

#include <stdint.h>
#include <lua.h>

/*C*/
void init_rng(uint32_t metaseed);

/*Lua*/
int luaopen_rng(lua_State* L);
