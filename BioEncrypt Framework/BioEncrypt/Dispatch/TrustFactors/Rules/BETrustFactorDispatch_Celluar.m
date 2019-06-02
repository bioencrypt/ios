//
//  BETrustFactorDispatch_Celluar.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Celluar.h"

@implementation BETrustFactorDispatch_Celluar

// USES PRIVATE API
+ (BETrustFactorOutputObject *)cellConnectionChange:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Get the current list of user apps
    NSString *carrierConnectionInfo = [[BETrustFactorDatasets sharedDatasets] getCarrierConnectionName];
    
    // Check the array
    if (!carrierConnectionInfo || carrierConnectionInfo == nil || carrierConnectionInfo.length < 1) {
        
        // Set the DNE status code to NODATA
        // this avoids showing "error" when using default policy and the statusbar checks are not run
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    // Add carrier connection info to the output array
    [outputArray addObject:carrierConnectionInfo];

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// USES PRIVATE API
+ (BETrustFactorOutputObject *)airplaneMode:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Get the status Bar
    NSNumber *enabled = [[BETrustFactorDatasets sharedDatasets] isAirplaneMode];
    
    // Check the array
    if (!enabled || enabled == nil) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Is airplane enabled?
    if(enabled.intValue == 1){
        [outputArray addObject:@"airplane"];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
