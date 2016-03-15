//
//  ui-kit.m
//
//  Created by Mikhail Sosonkin on 6/9/15.
//
//

#import <Foundation/Foundation.h>
#import "ui-kit.h"

void dispatch_on_main(void (^cb)()) {
    if([NSThread isMainThread]) {
        cb();
    } else {
        dispatch_sync(dispatch_get_main_queue(), cb);
    }
}

void _walkViewTree(UIView* root, BOOL (^callback)(UIView * curView)) {
    NSArray * subviews = [root subviews];
    for(UIView * view in subviews) {
        if(callback(view)) {
            _walkViewTree(view, callback);
        }
    }
}

void walkViewTree(UIView * root, BOOL (^callback)(UIView * curView)) {
    // make sure we cover the root as well.
    __block BOOL walkCont = FALSE;
    
    dispatch_on_main(^{
        walkCont = callback(root);
    });
    
    if(walkCont) {
        dispatch_on_main(^{
            _walkViewTree(root, callback);
        });
    }
}

void walkViewRoots(NSArray* roots, BOOL (^callback)(UIView * curView)) {
    for(UIView* root in roots) {
        walkViewTree(root, callback);
    }
}

void walkUpView(UIView* leaf, BOOL (^callback)(UIView * curView)) {
    if(leaf == NULL) {
        return;
    }
    
    dispatch_on_main(^{
        if(callback(leaf)) {
            walkUpView([leaf superview], callback);
        }
    });
}

NSArray* findViewType(Class type, UIView * root) {
    __block NSMutableArray * result = [[NSMutableArray alloc] init];
    
    walkViewTree(root, ^(UIView * curView) {
        if([curView class] == type || [[curView class] isSubclassOfClass:type]) {
            [result addObject:curView];
        }
        
        return YES;
    });
    
    return result;
}