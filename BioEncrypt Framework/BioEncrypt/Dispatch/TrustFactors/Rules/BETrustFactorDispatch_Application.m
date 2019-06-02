//
//  BETrustFactorDispatch_Application.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Application.h"
#import "ActiveProcess.h"

@implementation BETrustFactorDispatch_Application

// Implementations

// USES PRIVATE API

/* TrustFactor Removed from policy
 
 }, {
 "id": 22,
 "notFoundIssueMessage": "High risk apps detected",
 "notFoundSuggestionMessage": "Uninstall high risk apps",
 "lowConfidenceIssueMessage": "",
 "lowConfidenceSuggestionMessage": "",
 "revision": 1,
 "classID": 3,
 "subClassID": 3,
 "name": "high risk installed apps",
 "transparentEligible": 0,
 "partialWeight": 0,
 "weight": 35,
 "learnMode": 0,
 "learnTime": 0,
 "learnAssertionCount": 0,
 "learnRunCount": 0,
 "decayMode": 0,
 "decayMetric": 0,
 "wipeOnUpdate": 0,
 "dispatch": "Application",
 "implementation": "installedApp:",
 "whitelistable": 0,
 "privateAPI": 1,
 "payload": [
 "com.dunkinbrands.DunkinMobile",
 "net.technet.systat"
 ]
 
 */
+ (BETrustFactorOutputObject *)installedApp:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Current app name
    NSString *appName;
    
    // Get the current list of user apps
    NSArray *userApps = [[[BETrustFactorDatasets sharedDatasets] getInstalledAppInfo] copy];

    // Check the array
    if (!userApps || userApps == nil || userApps.count < 1) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the process information
    for (NSDictionary *app in userApps) {
        
        // Get the current process name
        appName = [app objectForKey:@"bundleID"];
        
        // Iterate through payload names and look for matching processes
        for (NSString *badAppName in payload) {
            
            // Check if the process name is equal to the current process being viewed
            if([badAppName isEqualToString:appName]) {
                
                // Make sure we don't add more than one instance of the proc
                if (![outputArray containsObject:badAppName]){
                    
                    // Add the process to the output array
                    [outputArray addObject:badAppName];
                }
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

/* Removed due to iOS 9
 
// High Risk Applications
+ (BETrustFactorOutputObject *)runningApp:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
 
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the current processes
    NSArray *currentProcesses = [[BETrustFactorDatasets sharedDatasets] getProcessInfo];
    
    // Check the array
    if (!currentProcesses || currentProcesses == nil || currentProcesses.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the process information
    for (ActiveProcess *process in currentProcesses) {
        
               // Iterate through payload names and look for matching processes
        for (NSString *badProcName in payload) {
            
            // Check if the process name is equal to the current process being viewed
            if([badProcName isEqualToString:process.name]) {
                
                // make sure we don't add more than one instance of the proc
                if (![outputArray containsObject:process.name]){
                    
                    // Add the process to the output array
                    [outputArray addObject:process.name];
                }
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


// Check for bad url handlers
+ (BETrustFactorOutputObject *)uriHandler:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Run through the payload
    for (NSString *urlString in payload) {
        
        // Create a fake url for the current payload string
        NSURL *fakeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", urlString]];
        
        // Return whether or not the fake url item exists
        if ([[UIApplication sharedApplication] canOpenURL:fakeURL]) {
            // Exists
            
            // make sure we don't add more than one instance of the proc
            if (![outputArray containsObject:[fakeURL path]]){
                // Add the process to the output array
                [outputArray addObject:[fakeURL absoluteString]];
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}
 
*/


@end
