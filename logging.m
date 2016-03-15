//
//  logging.m
//
//  Created by Mikhail Sosonkin on 3/15/16.
//
//

#import <Foundation/Foundation.h>
#import "logging.h"

#if __cplusplus
extern "C" {
#endif

void AMLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    
    NSString* appname = @"CLICKTHRU: ";
    format = [appname stringByAppendingString:format];
    
    NSLogv(format, args);
    
    va_end(args);
}

#if __cplusplus
}   // Extern C
#endif