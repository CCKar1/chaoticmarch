//
//  logging.h
//
//  Created by Mikhail Sosonkin on 3/15/16.
//
//

#ifndef appMonkey_logging_h
#define appMonkey_logging_h

#if __cplusplus
extern "C" {
#endif
    
void AMLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

#if __cplusplus
}   // Extern C
#endif
    
#endif
