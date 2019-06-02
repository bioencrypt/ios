//
//  BETrustFactorDispatch_Activity.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Activity.h"

@implementation BETrustFactorDispatch_Activity

// Get user's previous activity
+ (BETrustFactorOutputObject *)previous:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the user's activity history
    NSArray *previousActivities;
    
    // Check if error was determined by activity callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  activityDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  activityDNEStatus] != DNEStatus_expired ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] activityDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    } else {
        // No known errors occured previously, try to get dataset and check our object
        
        previousActivities = [[BETrustFactorDatasets sharedDatasets] getPreviousActivityInfo];
        
        // Check activity dataset again
        if (!previousActivities || previousActivities == nil || previousActivities.count < 1) {
            
            // No data for status
            [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
            
            // Return with the blank output object
            return trustFactorOutputObject;
        }
    }
    
    // Set default variables
    float stillCount = 0;
    float movingCount = 0;
    float movingFastcount = 0;
    float unknownCount = 0;
    NSString *lastActivity;
    
    // Check each category for hit since lots of activities are returned in most cases
    for (CMMotionActivity *actItem in previousActivities)
    {
        
        // High confidence
        if(actItem.confidence == 2){
            
            // Stationary
            if (actItem.stationary == 1){
                stillCount = stillCount + 1;
                
            // Moving
            } else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
                movingCount = movingCount + 1;
            
            // Moving in a vehicle
            } else if (actItem.automotive == 1){
                movingFastcount = movingFastcount + 1;
            
            // Unknown
            } else {
                unknownCount = unknownCount + 1;
            }
        }
        
        // Medium confidence
        //if(actItem.confidence == 1){
        
        //  if (actItem.stationary == 1){
        //      stillCount = stillCount + 0.5;
        //  }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
        //      movingCount = movingCount + 0.5;
        //  }else if (actItem.automotive == 1){
        //      movingFastcount = movingFastcount + 0.5;
        //  }
        //  else{
        //      unknownCount = unknownCount + 0.5;
        //  }
        
        
        //}
        
        // Low confidence
        //if(actItem.confidence == 0){
        
        //if (actItem.stationary == 1){
        //    stillCount = stillCount + 0.5;
        // }else if (actItem.cycling == 1 || actItem.walking == 1 || actItem.running == 1){
        //    movingCount = movingCount + 0.5;
        // }else if (actItem.automotive == 1){
        //    movingFastcount = movingFastcount + 0.5;
        //}
        // else{
        //     unknownCount = unknownCount + 0.5;
        // }
        
        
        //}
        
        // NSLog(@"Got a PREVIOUS core motion update");
        //NSLog(@"Previous activity date is %f",actItem.timestamp);
        //NSLog(@"Previous activity confidence from a scale of 0 to 2 - 2 being best- is: %ld",actItem.confidence);
        //NSLog(@"Previous activity type is unknown: %i",actItem.unknown);
        //NSLog(@"Previous activity type is stationary: %i",actItem.stationary);
        //NSLog(@"Previous activity type is walking: %i",actItem.walking);
        //NSLog(@"Previous activity type is running: %i",actItem.running);
        //NSLog(@"Previous activity type is cycling: %i",actItem.cycling);
        //NSLog(@"Previous activity type is automotive: %i",actItem.automotive);
    }
    
    // Stationary
    if(stillCount >= movingCount && stillCount >= movingFastcount && stillCount >= unknownCount){
        lastActivity = @"still";
        
    // Moving
    } else if(movingCount > stillCount && movingCount > movingFastcount && movingCount > unknownCount) {
        lastActivity = @"moving";
        
    // Moving in a vehicle
    } else if(movingFastcount > stillCount && movingFastcount > movingCount && movingFastcount > unknownCount){
        lastActivity = @"movingFast";
    
    // Unknown
    } else {
        lastActivity=@"unknown";
        
        // Moving status unavailable
        //[trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        //return trustFactorOutputObject;
    }
    
    //NSLog(@"Previous activity result: %@", lastActivity);
    
    // Hours partitioned across 24, adjust accordingly but it does impact multiple rules
    // Hour block from policy
    
    //NSString *blockOfDay = [[BETrustFactorDatasets sharedDatasets] getTimeDateStringWithHourBlockSize:[[[payload objectAtIndex:0] objectForKey:@"hoursInBlock"] integerValue] withDayOfWeek:NO];
    
    //NSString *activityString =  [blockOfDay stringByAppendingString:[NSString stringWithFormat:@"-%@",lastActivity]];
    
    // Merge with activity and hour
    [outputArray addObject:lastActivity];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}


// get device state
+ (BETrustFactorOutputObject *) deviceState: (NSArray *) payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Get the status Bar
    NSDictionary *statusBar = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    
    // Check the dic
    if (!statusBar || statusBar == nil) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // This string gets built by combination of the states available
    NSMutableString *anomalyString = [[NSMutableString alloc] init];
    
    if ([statusBar[@"isBackingUp"] intValue]==1)
        [anomalyString appendString:@"backingUp_"];
    if ([statusBar[@"isOnCall"] intValue]==1)
        [anomalyString appendString:@"onCall_"];
    if ([statusBar[@"isNavigating"] intValue]==1)
        [anomalyString appendString:@"navigating_"];
    if ([statusBar[@"isUsingYourLocation"] intValue]==1)
        [anomalyString appendString:@"usingLocation_"];
    if ([statusBar[@"doNotDisturb"] intValue]==1)
        [anomalyString appendString:@"doNotDisturb_"];
    if ([statusBar[@"orientationLock"] intValue]==1)
        [anomalyString appendString:@"orientationLock_"];
    if ([statusBar[@"isTethering"] intValue]==1)
        [anomalyString appendString:@"tethering_"];
    if (![statusBar[@"lastApp"] isEqualToString:@""])
        [anomalyString appendFormat:@"lastApp_%@",[statusBar valueForKey:@"lastApp"]];
    
         
    //TODO: There is already separate trustfactor for airPlaneMode
    if ([statusBar[@"isAirplaneMode"] intValue]==1)
        [anomalyString appendString:@"airplane_"];
    
    
    
    //if nothing
    if ([anomalyString isEqualToString:@""]) {
        [anomalyString appendString:@"none_"];
    }
    
    [outputArray addObject:anomalyString];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
