//C standard Library
#include <time.h>

//Lua Library
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

//Cube of Time headers
#include "l_rng.h"

//static globals
#define NUMBER_OF_SEEDS 4096
static uint32_t seeds[NUMBER_OF_SEEDS];
static uint32_t carry = 362436;
static int ready = 0;

//C functions
void init_rng(uint32_t metaseed)
{
    //Algorithm by George Marsaglia
    uint32_t x = 0, y = 0, z = 0, w = 0, v = 0;

    x = metaseed;
    for(int i = 0; i < NUMBER_OF_SEEDS; i++)
    {
        uint32_t t = (x^(x>>7));
        x = y;
        y = z;
        z = w;
        w = v;
        v = (v^(v<<6))^(t^(t<<13));

        seeds[i] = (y + y + 1) * v;
    }
    ready = 1;
}

uint32_t CMWC4096()
{
    //Algorithm by George Marsaglia
    uint64_t multiplier = 18782;
    static uint32_t seed_selection = NUMBER_OF_SEEDS - 1;
    uint64_t t = 0;
    uint32_t j = 0;
    static uint32_t lag = 0xfffffffe;

    seed_selection = (seed_selection+1)&(NUMBER_OF_SEEDS - 1);
    t = multiplier * seeds[seed_selection] + carry;
    carry = (t>>32);
    j = t + carry;
    if(j < carry)
    {
        j++;
        carry++;
    }

    seeds[seed_selection] = lag - j;
    return lag - j;
}

//Lua functions
static int l_init(lua_State* L)
{
    init_rng((uint32_t) luaL_checkinteger(L, 1));
    return 0;
}

void unready_rng_check(lua_State* L, char* msg)
{
    if(!ready)
    {
        lua_pushfstring(L, "Attempt to %s with unseeded RNG.\n", msg);
        lua_error(L);
    }
}

static int l_coin(lua_State* L)
{
    unready_rng_check(L, "flip coin");
    lua_pushboolean(L, (int)(CMWC4096()%2));
    return 1;
}

static int l_wcoin(lua_State* L)
{
    unready_rng_check(L, "flip weighted coin");
    int percent_heads = (int)luaL_checkinteger(L, 1);
    lua_pushboolean(L, (int)((CMWC4096()%100) < percent_heads));
    return 1;
}

static int l_dice(lua_State* L)
{
    unready_rng_check(L, "roll dice");
    int throws = (int) luaL_checkinteger(L, 1);
    int sides = (int) luaL_checkinteger(L, 2);

    int result = 0;
    for(int t = 0; t < throws; t++)
        result += (int) ((CMWC4096()%sides)+1);

    lua_pushinteger(L, result);
    return 1;
}

static const struct luaL_Reg rng_lib [] = {
    {"coin", l_coin},
    {"wcoin", l_wcoin},
    {"dice", l_dice},
    {"init", l_init},
    {NULL, NULL} //Sentinel
}; 

int luaopen_rng(lua_State* L)
{
    const char* lbname = "rng";
    luaL_newlib(L, rng_lib);
    lua_setglobal(L, lbname);
    
    //Set default metaseed 
    lua_getglobal(L, lbname);
    lua_pushinteger(L, (uint32_t) time(NULL));
    lua_setfield(L, 1, "metaseed");
    lua_pop(L, 1);

    return 0;
}
