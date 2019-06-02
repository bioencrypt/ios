//
//  BETrustFactorDataset_Config.m
//  BioEncrypt
//
//

#import "BETrustFactorDataset_Config.h"
#import <UIKit/UIKit.h>
@import AVFoundation;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@implementation BETrustFactorDataset_Config
// Check if we are in airplane mode
+(NSNumber *)hasPassword{
    
    NSNumber* result;
    
    //only supported on iOS 8
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        static NSData *password = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            password = [NSKeyedArchiver archivedDataWithRootObject:NSStringFromSelector(_cmd)];
        });
        
        NSDictionary *query = @{
                                (__bridge id <NSCopying>)kSecClass: (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService: @"UIDevice-PasscodeStatus_KeychainService",
                                (__bridge id)kSecAttrAccount: @"UIDevice-PasscodeStatus_KeychainAccount",
                                (__bridge id)kSecReturnData: @YES,
                                };
        
        CFErrorRef sacError = NULL;
        SecAccessControlRef sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kNilOptions, &sacError);
        
        // Unable to create the access control item.
        if (sacObject == NULL || sacError != NULL) {
            
            result = [NSNumber numberWithInt:0];
            
            return result;
        }
        
        NSMutableDictionary *setQuery = [query mutableCopy];
        setQuery[(__bridge id) kSecValueData] = password;
        setQuery[(__bridge id) kSecAttrAccessControl] = (__bridge id) sacObject;
        
        OSStatus status;
        status = SecItemAdd((__bridge CFDictionaryRef)setQuery, NULL);
        
        // if we have the object, release it.
        if (sacObject) {
            CFRelease(sacObject);
            sacObject = NULL;
        }
        
        // if it failed to add the item.
        if (status == errSecDecode) {
            // Passcode not set
            result = [NSNumber numberWithInt:2];
            return result;
        }
        else{ //try copy
            
            status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
            
            // it managed to retrieve data successfully
            if (status != errSecSuccess) {
                // PAsscode not set
                result = [NSNumber numberWithInt:2];
                return result;
            }
            
            
        }
        
        //Must have a passcode
        result = [NSNumber numberWithInt:1];
        return result;
        
        
    } else {
        
        // not supported on device so serror
        result = [NSNumber numberWithInt:0];
        return result;
    }
}


@end
