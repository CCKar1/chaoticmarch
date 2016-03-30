// -- (c) Synack Inc 2016
//
//  lua_support.h
//
//  Created by Mikhail Sosonkin on 3/15/16.
//
//

#ifndef appMonkey_lua_support_h
#define appMonkey_lua_support_h

#if __cplusplus
extern "C" {
#endif
    
void execLuaScript(NSString* scriptfile);

#if __cplusplus
}
#endif

#endif
