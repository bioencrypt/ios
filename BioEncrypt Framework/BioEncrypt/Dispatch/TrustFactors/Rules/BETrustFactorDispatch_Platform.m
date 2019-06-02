//  BETrustFactorDispatch_Platform.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Platform.h"
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation BETrustFactorDispatch_Platform

// Vulnerable/bad version
+ (BETrustFactorOutputObject *)vulnerableVersion:(NSArray *)payload {
    
    // Good resorce for currently signed apple releases  http://api.ineal.me/tss/all
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString* currentVersion =  [[UIDevice currentDevice] systemVersion] ;
    
    if (!currentVersion) {
        // NO VERSION
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check blacklist
    for (NSString *badVersions in payload) {
        if([badVersions containsString:@"-"]){ // Range of version numbers
            NSArray* range = [badVersions componentsSeparatedByString:@"-"];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0]) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO([range objectAtIndex:1])) {
                [outputArray addObject:currentVersion];
                break;
            }
        }
        else if([badVersions containsString:@"*"]){ // Wild card version number
            NSArray* startRange = [badVersions componentsSeparatedByString:@"*"];
            NSArray* endRange = [[startRange objectAtIndex:0] componentsSeparatedByString:@"."];
            
            NSString *botVersion = [startRange objectAtIndex:0];
            NSString *topVersion = [NSString stringWithFormat:@"%@.9",[endRange objectAtIndex:0]];
            
            // Check for version match
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(botVersion) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(topVersion)) {
                [outputArray addObject:currentVersion];
                break;
            }
        
        // Specific version
        } else {
            if (SYSTEM_VERSION_EQUAL_TO(badVersions)) {
                [outputArray addObject:currentVersion];
                break;
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Allowed versions
+ (BETrustFactorOutputObject *)versionAllowed:(NSArray *)payload {
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSString* currentVersion =  [[UIDevice currentDevice] systemVersion] ;
    
    if (!currentVersion) {
        // NO VERSION
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    //Check whitelist
    BOOL allowed = NO;
    for (NSString *allowedVersions in payload) {
        if([allowedVersions containsString:@"-"]){ //range of version numbers
            NSArray* range = [allowedVersions componentsSeparatedByString:@"-"];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO([range objectAtIndex:0]) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO([range objectAtIndex:1])) {
                allowed=YES;
                break;
            }
        }
        else if([allowedVersions containsString:@"*"]){ //wild card version number
            NSArray* startRange = [allowedVersions componentsSeparatedByString:@"*"];
            NSArray* endRange = [[startRange objectAtIndex:0] componentsSeparatedByString:@"."];
            
            NSString *botVersion = [startRange objectAtIndex:0];
            NSString *topVersion = [NSString stringWithFormat:@"%@.9",[endRange objectAtIndex:0]];
            
            // Check for version match
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(botVersion) && SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(topVersion)) {
                allowed=YES;
                break;
            }
        }
        else{ //specific version
            if (SYSTEM_VERSION_EQUAL_TO(allowedVersions)) {
                allowed=YES;
                break;
            }
        }
    }
    
    // Version not allowed
    if(!allowed){
        [outputArray addObject:currentVersion];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Short up time
+ (BETrustFactorOutputObject *)shortUptime:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
    
    if (!uptime) {
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    int secondsInHour = 3600;
    NSString *hoursUp = [NSString stringWithFormat:@"%.0f",uptime/secondsInHour];
    
    // less than desired uptime
    if([hoursUp integerValue] < [[[payload objectAtIndex:0] objectForKey:@"minimumHoursUp"] integerValue])
    {
        [outputArray addObject:[NSString stringWithFormat:@"up%@",hoursUp]];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


@end
