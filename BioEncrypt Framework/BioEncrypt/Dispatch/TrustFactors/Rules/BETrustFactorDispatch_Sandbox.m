//
//  BETrustFactorDispatch_Sandbox.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Sandbox.h"
#import <sys/stat.h>

// Define if system version is less than
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation BETrustFactorDispatch_Sandbox

// Sandbox API Verification and Kernel Configurations - Basically Jailbreak Checks
+ (BETrustFactorOutputObject *)integrity:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];

    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get the current process environment info
    NSDictionary *environmentInfo = [[NSProcessInfo processInfo] environment];

    // Check if we're not sandboxed
    if ([environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] != nil) {
        
        [outputArray addObject:[@"APP_SANDBOX_CONTAINER_ID_Found" stringByAppendingString:[[environmentInfo objectForKey:@"APP_SANDBOX_CONTAINER_ID"] stringValue]]];
    }
    
    // Check if DYLD_INSERT_LIBRARY path is available (JBs only)
    if ([environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"]) {
        // Check if the environment info responds to stringvalue selectors
        if ([[environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"] respondsToSelector:@selector(stringValue)]) {
            // Add it to the array
            [outputArray addObject:[@"DYLD_INSERT_LIBRARIES_Found" stringByAppendingString:[[environmentInfo objectForKey:@"DYLD_INSERT_LIBRARIES"] stringValue]]];
        }
    }

    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    // Check for shell - if less than iOS 9
    
//    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
//        if (system(0)) { //returned 1 therefore device is JB'ed
//            [outputArray addObject:@"systemCmdWorks"];
//        }
//    }
    #pragma GCC diagnostic pop
    
    // Check for fork
    if (fork() >= 0) { /* If the fork succeeded, we're jailbroken */
            [outputArray addObject:@"forkCmdWorks"];
    }

    // Check for sym links
    struct stat s;
    for (NSString *file in payload) {
        if (!lstat([file cStringUsingEncoding:NSASCIIStringEncoding], &s)) {
            if (s.st_mode & S_IFLNK) [outputArray addObject:[@"symlink_" stringByAppendingString:file]];
        }

    }
    
    NSError *error;
    
    [[NSString stringWithFormat:@"test"] writeToFile:@"/private/cache.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (nil == error){
        [outputArray addObject:@"writeRestrictedFile"];
    }
    else{
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/test_jb.txt" error:nil];
    }

    FILE *file = fopen("/bin/ssh", "r");
    
    if (file){
        [outputArray addObject:@"readRestrictedFile"];
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];

    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Helper functions

@end
