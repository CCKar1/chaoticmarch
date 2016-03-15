#import <Foundation/Foundation.h>

#import "lua_support.h"

@interface LuaExec : NSObject
- (void) execScript:(NSString*)script;
@end

@implementation LuaExec : NSObject {
	
}

- (void) execScript:(NSString*)script {
	execLuaScript(script);
}

@end