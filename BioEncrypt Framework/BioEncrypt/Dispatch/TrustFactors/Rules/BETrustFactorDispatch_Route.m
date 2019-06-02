//
//  BETrustFactorDispatch_Route.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Route.h"
#import "BETrustFactorDataset_Netstat.h"
#import "ActiveRoute.h"

@implementation BETrustFactorDispatch_Route

// Check if using a VPN
+ (BETrustFactorOutputObject *)vpnUp:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get routes
    NSArray *routeArray = [[BETrustFactorDatasets sharedDatasets] getRouteInfo];
    
    //NSLog(@"%@",routeArray);

    // Check for routes
    if (!routeArray || routeArray == nil || routeArray.count < 1) {
        // Current route array is EMPTY
        
        // Set the DNE status code to UNAVAILABLE
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the routes
    @try {
        
        // Run through each route
        for (ActiveRoute *route in routeArray) {
            
            // Iterate through VPN interfaces names and look for match
            for (NSString *vpnInterface in payload) {
                
                // Check if the interface is equal to a known VPN interface name
                if([route.interface containsString:vpnInterface]) {
                    
                    // make sure gateway contains an IP, otherwise we'll ad "Link #15" and such which is not unique to this VPN connection
                    if([route.gateway containsString:@"."]){
                        
                        // make sure we don't add more than one instance of the VPN interface name
                        if (![outputArray containsObject:[vpnInterface stringByAppendingString:route.gateway]]){
                            
                            // Add the interface of VPN to the output array
                            [outputArray addObject:[vpnInterface stringByAppendingString:route.gateway]];
                        }

                        
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        // Error
        return nil;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// No route
+ (BETrustFactorOutputObject *)noRoute:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    // Get routes
    NSArray *routeArray = [[BETrustFactorDatasets sharedDatasets] getRouteInfo];
    bool defaultRoute = NO;
    
    // Check for routes
    if (!routeArray || routeArray == nil || routeArray.count < 1) {
        // Current route array is EMPTY
        
        // Set the DNE status code to UNAVAILABLE
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the routes
    @try {
        
        // Run through each route
        for (ActiveRoute *route in routeArray) {
            
            if(route.isDefault == YES){
                defaultRoute = YES;
                break;
            }
        }
        
        // Did not find a default route
        if (defaultRoute == NO){
            [outputArray addObject:@"noRoute"];
        }
    }
    
    @catch (NSException *exception) {
        // Error
        return nil;
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
