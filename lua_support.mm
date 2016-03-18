//
//  lua_support.m
//  
//
//  Created by Mikhail Sosonkin on 3/15/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIScreen.h>
#import <pthread.h>

#import "logging.h"
#import "SimulateTouch.h"
#import "ui-kit.h"

//from: http://stackoverflow.com/questions/5029267/is-there-any-way-of-asking-an-ios-view-which-of-its-children-has-first-responder/14135456#14135456
@interface UIResponder (firstResponder)
- (id) currentFirstResponder;
@end

static __weak id currentFirstResponder;

@implementation UIResponder (FirstResponder)

+(id)currentFirstResponder {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}

-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}

@end

#if __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

    CGSize scaled_size;
    CGSize actual_size;
    
    void adoptResolution(int w, int h) {
        scaled_size.height = h;
        scaled_size.width = w;
    }
    
    CGPoint scalePoint(CGPoint point) {
        point.x /= (scaled_size.width/actual_size.width);
        point.y /= (scaled_size.height/actual_size.height);
        
        return point;
    }

    void typeString(NSString* inputString) {
        id firstResponder = [UIResponder currentFirstResponder];

        //check if input is text field
        if( nil != firstResponder ) {
            if([firstResponder respondsToSelector:@selector(setText)]) {
                [firstResponder setText: inputString];
            }
        }
    }
    
    int lua_log(lua_State* L) {
        const char* param1 = luaL_checkstring(L, 1);
        
        AMLog(@"lua: %@", [NSString stringWithUTF8String:param1]);
        
        return 0;
    }

    BOOL isInBounds(CGRect rect, UIView* view) {
        CGPoint abs_point = [view convertPoint:[view bounds].origin toView: nil];

        BOOL retVal = 
            ((abs_point.x >= rect.origin.x) && ((rect.origin.x + rect.size.width) <= abs_point.x)) &&
            ((abs_point.y >= rect.origin.y) && ((rect.origin.y + rect.size.height) <= abs_point.y));

        return retVal;
    }

    BOOL findStringAt(NSString* str, CGRect box) {
        __block BOOL foundString = false;

        walkViewTree((UIView*)[[UIApplication sharedApplication] keyWindow], ^BOOL(UIView * curView){
            if(isInBounds(box, curView) && [curView respondsToSelector:@selector(text)]) {
                NSString* text = [curView text];

                AMLog(@"lua: %@", text);

                if([text rangeOfString: str].location == NSNotFound) {
                    foundString = true;

                    return false;
                }
            }

            return true;
        });

        return foundString;
    }

    BOOL findComponentAt(Class componentName, CGRect box) {
        __block BOOL foundComp = false;

        walkViewTree((UIView*)[[UIApplication sharedApplication] keyWindow], ^BOOL(UIView * curView){
            if(isInBounds(box, curView)) {
                if([curView isKindOfClass:componentName]) {
                    foundComp = true;
                    // found, stop scanning.
                    return false;
                }
            }

            return true;
        });

        return foundComp;
    }

    CGRect makeRectFromBox(CGFloat res_x, CGFloat res_y, CGFloat choice_x, CGFloat choice_y) {
        CGFloat boxWidth = actual_size.width/res_x;
        CGFloat boxHeight = actual_size.height/res_y;
        CGFloat x = boxWidth * choice_x;
        CGFloat y = boxHeight * choice_y;

        return CGRectMake(x, y, boxWidth, boxHeight);
    }

    BOOL isHidden(UIView* view) {
        __block BOOL ret = false;

        walkUpView(view, ^BOOL(UIView* curView) {
            if([curView respondsToSelector:@selector(isHidden)] && [curView isHidden]) {
                ret = true;

                return false;
            }

            return true;
        });

        return ret;
    }
    
    int pathIndeces[10] = {0};
    
    int lua_touchDown(lua_State* L) {
        int touchId = luaL_checkint(L, 1);
        lua_Number x = luaL_checknumber(L, 2);
        lua_Number y = luaL_checknumber(L, 3);
        
        if(touchId < 0 || touchId > 9) {
            lua_pushstring(L, "touch ID must be [0, 9]");
            lua_error(L);
        }

        AMLog(@"lua: touchDown(%f, %f)", x, y);
        
        pathIndeces[touchId] = [SimulateTouch simulateTouch:0 atPoint:scalePoint(CGPointMake(x, y)) withType:STTouchDown];
        
        return 0;
    }
    
    int lua_touchUp(lua_State* L) {
        int touchId = luaL_checkint(L, 1);
        lua_Number x = luaL_checknumber(L, 2);
        lua_Number y = luaL_checknumber(L, 3);
        
        if(touchId < 0 || touchId > 9) {
            lua_pushstring(L, "touch ID must be [0, 9]");
            lua_error(L);
        }

        AMLog(@"lua: touchUp(%f, %f) %d id %d", x, y, pathIndeces[touchId], touchId);
        
        [SimulateTouch simulateTouch:pathIndeces[touchId] atPoint:scalePoint(CGPointMake(x, y)) withType:STTouchUp];
        
        return 0;
    }
    
    int lua_touchMove(lua_State* L) {
        int touchId = luaL_checkint(L, 1);
        lua_Number x = luaL_checknumber(L, 2);
        lua_Number y = luaL_checknumber(L, 3);
        
        if(touchId < 0 || touchId > 9) {
            lua_pushstring(L, "touch ID must be [0, 9]");
            lua_error(L);
        }

        AMLog(@"lua: touchUp(%f, %f) %d id %d", x, y, pathIndeces[touchId], touchId);
        
        [SimulateTouch simulateTouch:pathIndeces[touchId] atPoint:scalePoint(CGPointMake(x, y)) withType:STTouchMove];
        
        return 0;
    }

    int lua_inputText(lua_State* L) {
        const char* inputString = luaL_checkstring(L, 1);
        
        AMLog(@"lua: inputText(%s)", inputString);
        
        typeString([NSString stringWithUTF8String:inputString]);
        
        return 0;
    }
    
    int lua_usleep(lua_State* L) {
        useconds_t micros = (useconds_t)luaL_checknumber(L, 1);
        
        AMLog(@"lua: usleep %d", micros);
        
        if(usleep(micros) != 0) {
            return 0;
        }
        
        return 0;
    }
    
    int lua_adaptResolution(lua_State* L) {
        int w = luaL_checkint(L, 1);
        int h = luaL_checkint(L, 2);
        
        AMLog(@"lua: adaptResolution %dx%d", w, h);
        
        adoptResolution(w, h);
        
        return 0;
    }
    
    int lua_adaptOrientation(lua_State* L) {
        int orientation = luaL_checkint(L, 1);
        
        AMLog(@"lua: adaptOrientation %d", orientation);
        
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:orientation] forKey:@"orientation"];
        
        return 0;
    }

    int lua_hasTextAt(lua_State* L) {
        const char* inputString = luaL_checkstring(L, 1);
        int resolution_x = luaL_checkint(L, 2);
        int resolution_y = luaL_checkint(L, 3);
        int choice_x = luaL_checkint(L, 4);
        int choice_y = luaL_checkint(L, 5);

        CGRect box = makeRectFromBox(resolution_x, resolution_y, choice_x, choice_y);
        BOOL foundString = findStringAt([NSString stringWithUTF8String:inputString], box);

        lua_pushboolean(L, foundString); // false - nothing found.

        return 1;
    }

    int lua_hasComponentAt(lua_State* L) {
        const char* componentName = luaL_checkstring(L, 1);
        int resolution_x = luaL_checkint(L, 2);
        int resolution_y = luaL_checkint(L, 3);
        int choice_x = luaL_checkint(L, 4);
        int choice_y = luaL_checkint(L, 5);

        BOOL foundComp = false;

        Class klass = objc_getClass(componentName);

        if(klass != nil) {
            CGRect box = makeRectFromBox(resolution_x, resolution_y, choice_x, choice_y);

            foundComp = findComponentAt(klass, box);
        }

        lua_pushboolean(L, foundComp); // false - nothing found.

        return 1;
    }

    NSString* findStringBelow(UIView* view) {
        __block NSString* ret = nil;

        walkViewTree(view, ^BOOL(UIView * curView){
            if([curView respondsToSelector:@selector(text)]) {
                ret = [curView text];

                return false;
            }

            return true;
        });

        return ret;
    }

    int lua_findOfTypes(lua_State* L) {
        NSMutableArray* types = [[NSMutableArray alloc] init];
        int arg_num = 1;
    
        while(true) {
            const char* componentName = luaL_checkstring(L, arg_num);

            // is empty string.
            if(componentName[0] == '\0') {
                // no more.
                break;
            }

            Class klass = objc_getClass(componentName);
            if(klass != nil) {
                [types addObject:klass];
            }

            arg_num++;
        }

        if([types count] > 0) {
            __block int nextComponent = 0;

            lua_newtable(L);

            walkViewTree((UIView*)[[UIApplication sharedApplication] keyWindow], ^BOOL(UIView * curView){
                BOOL matchesType = false;
                for(Class klass in types) {
                    if([curView isKindOfClass:klass]) {
                        matchesType = true;
                        break;
                    }
                }

                if(matchesType && !isHidden(curView)) {
                    CGRect bounds = [curView bounds];
                    CGPoint abs_point = [curView convertPoint:bounds.origin toView: nil];

                    lua_newtable(L);

                    lua_pushstring(L, "x");
                    lua_pushnumber(L, abs_point.x);
                    lua_settable(L, -3);

                    lua_pushstring(L, "y");
                    lua_pushnumber(L, abs_point.y);
                    lua_settable(L, -3);

                    lua_pushstring(L, "width");
                    lua_pushnumber(L, bounds.size.width);
                    lua_settable(L, -3);

                    lua_pushstring(L, "height");
                    lua_pushnumber(L, bounds.size.height);
                    lua_settable(L, -3);

                    NSString* label = findStringBelow(curView);

                    if(label != nil) {
                        lua_pushstring(L, "text");
                        lua_pushstring(L, [label UTF8String]);
                        lua_settable(L, -3);
                    }

                    // local table should be at the top of the stack
                    //  and bigger table following that.
                    lua_rawseti(L, -2, nextComponent);

                    nextComponent++;
                }

                return true;
            });
        }

        return 1;
    }

    int lua_get_bundle_id(lua_State* L) {
        NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];

        lua_pushstring(L, [bundle UTF8String]);

        return 1;
    }
    
    void execLuaScript(const char* script) {
        // initialize scale resolution.
        actual_size = [[UIScreen mainScreen] bounds].size;
        adoptResolution(actual_size.width, actual_size.height);
        
        lua_State *L = luaL_newstate();
        
        luaL_openlibs(L);

        const luaL_Reg log_lib[] = {
            {"log",       &lua_log},
            {"touchDown", &lua_touchDown},
            {"touchUp",   &lua_touchUp},
            {"touchMove", &lua_touchMove},
            {"usleep",    &lua_usleep},
            {"inputText", &lua_inputText},
            {"adaptResolution", &lua_adaptResolution},
            {"adaptOrientation", &lua_adaptOrientation},
            {"hasComponentAt", &lua_hasComponentAt},
            {"hasTextAt", &lua_hasTextAt},
            {"findOfTypes", &lua_findOfTypes},
            {"getBundleID", &lua_get_bundle_id},
            {NULL,        NULL}
        };
        
        lua_pushglobaltable(L);
        luaL_setfuncs(L, log_lib, 0);
        
        int fl = luaL_dostring(L, script);
        
        if(fl != 0){
            AMLog(@"lua Error: %@", [NSString stringWithUTF8String:lua_tostring(L, -1)]);
            lua_pop(L, 1);
        }
        
        lua_close(L);
    }

    void* thread_run(void* param) {
        execLuaScript((char*)param);

        return NULL;
    }

    __attribute__((constructor))
    static void init_click_thru(int argc, const char **argv) {
        const char* init_script = "dofile('/var/root/lua/chaotic_march.lua')";

        pthread_t thread = NULL;

        pthread_create(&thread, NULL, thread_run, (void*)init_script);
    }

#if __cplusplus
}
#endif
