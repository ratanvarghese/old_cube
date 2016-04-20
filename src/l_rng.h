#pragma once

#include <stdint.h>
#include <lua.h>

//C
void init_rng(uint32_t metaseed);
uint32_t CMWC4096();

//Lua
int luaopen_rng(lua_State* L);
