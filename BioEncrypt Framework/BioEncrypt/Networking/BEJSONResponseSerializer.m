//
//  JYJSONResponseSerializer.m
//  Jealousy
//
//  Created by Ivo Leko on 15/02/16.
//

#import "BEJSONResponseSerializer.h"

@implementation BEJSONResponseSerializer


- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id JSONObject = [super responseObjectForResponse:response data:data error:error];
    
    if (*error != nil) {
        
        // prepare new error with custom server error messages/codes
        NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
        NSDictionary *system = [JSONObject objectForKey:@"system"];
        NSDictionary *errorDic = [system objectForKey:@"error"];
        
        if (![errorDic isEqual:[NSNull null]]) {
            userInfo[BioEncryptServerErrorMessage] = errorDic[@"message"];
            userInfo[BioEncryptServerCustomErrorCode] = errorDic[@"code"];
            userInfo[BioEncryptServerDeveloperErrorMessage] = errorDic[@"developer"];
        }
        
        NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
        (*error) = newError;
    }
    
    
    return (JSONObject);
}

@end
