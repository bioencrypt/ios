//
//  BETrustFactorDispatch_Netstat.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Netstat.h"
#import "ActiveConnection.h"

@implementation BETrustFactorDispatch_Netstat

// Bad destination
+ (BETrustFactorOutputObject *)badDst:(NSArray *)payload {

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
    
    // Check if error was determined by netstat data callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the current netstat data
    NSArray *connections = [[BETrustFactorDatasets sharedDatasets] getNetstatInfo];
    
    // Check if error from dataset (expired)
    if ([[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus] != DNEStatus_ok ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    

    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is a listening socket or local
        if([connection.status isEqualToString:@"LISTEN"] || [connection.remoteHost isEqualToString:@"localhost"] )
            continue;

        // Iterate through payload names and look for matching processes
        for (NSString *badDstIP in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([connection.remoteHost hasSuffix:badDstIP]) {
                
                // Make sure we don't add more than one instance of destination
                if (![outputArray containsObject:connection.remoteHost]){
                    
                    // Add the destination to the output array
                    [outputArray addObject:connection.remoteHost];
                }
            }
        }
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;

}

// Priviledged port
+ (BETrustFactorOutputObject *)priviledgedPort:(NSArray *)payload {
    
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
    
    // Check if error was determined by netstat data callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the current netstat data
    NSArray *connections = [[BETrustFactorDatasets sharedDatasets] getNetstatInfo];
    
    // Check if error from dataset (expired)
    if ([[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus] != DNEStatus_ok ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if(![connection.status isEqualToString:@"LISTEN"])
            continue;
        
        
        // Iterate through source ports and look for matching ports
        for (NSNumber *badSrcPort in payload) {
            
            // Check if the current port is equal to bad port
            if([connection.localPort intValue] == [badSrcPort intValue]) {
                
                // make sure we don't add more than one instance of the port
                if (![outputArray containsObject:connection.localPort ]){
                    
                    // Add the port to the output array
                    [outputArray addObject:connection.localPort];
                }
            }
        }
    }
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// New service
+ (BETrustFactorOutputObject *)newService:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Check if error was determined by netstat data callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the current netstat data
    NSArray *connections = [[BETrustFactorDatasets sharedDatasets] getNetstatInfo];
    
    // Check if error from dataset (expired)
    if ([[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus] != DNEStatus_ok ) {
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is NOT a listening socket
        if (![connection.status isEqualToString:@"LISTEN"]) {
            continue;
        }
        
        // make sure we don't add more than one instance of the port
        if (![outputArray containsObject:connection.localPort]) {
            
            // Add the port to the output array
            [outputArray addObject:connection.localPort];
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


// Data Exfiltration
+ (BETrustFactorOutputObject *)goodDNS:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    //gdentgw.good.com
    //gdrelay.good.com
    //gdweb.good.com
    //gdmdc.good.com
    //bxenroll.good.com
    //bxcheckin.good.com
    
    /*
     if (result == TRUE) {
     NSMutableArray *tempDNS = [[NSMutableArray alloc] init];
     for(int i = 0; i < CFArrayGetCount(addresses); i++){
     struct sockaddr_in* remoteAddr;
     CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
     remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
     
     if(remoteAddr != NULL){
     // Extract the ip address
     //const char *strIP41 = inet_ntoa(remoteAddr->sin_addr);
     NSString *strDNS =[NSString stringWithCString:inet_ntoa(remoteAddr->sin_addr) encoding:NSASCIIStringEncoding];
     NSLog(@"RESOLVED %d:<%@>", i, strDNS);
     [tempDNS addObject:strDNS];
     }
     }
     }
     */
    
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Data Exfiltration
+ (BETrustFactorOutputObject *)dataExfiltration:(NSArray *)payload {
    
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
    
    // Get the current netstat data
    NSDictionary *dataXfer = [[BETrustFactorDatasets sharedDatasets] getDataXferInfo];
    
    // Check the dictionary
    if (!dataXfer || dataXfer == nil) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get uptime in seconds
    long uptime = 0;
    uptime = (long)[[NSProcessInfo processInfo] systemUptime];
    
    if (uptime == 0) {
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // second, 3600 = hour, 86400 = day
    int timeInterval=0;
    timeInterval = [[[payload objectAtIndex:0] objectForKey:@"secondsInterval"] intValue];
    
    // Check payload item prior to division
    if(timeInterval == 0){
        
        // Not been up long enough to be measured
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Per interval data transfer max in MB
    int dataMax=0;
    dataMax = [[[payload objectAtIndex:0] objectForKey:@"maxSentMB"] intValue];
    
    // Check payload item prior to division
    if(dataMax==0){
        //not been up long enough to be measured
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    int timeSlots = 0;
    timeSlots = round(uptime/timeInterval);
    
    if (timeSlots < 1){
        //not been up long enough to be measured
        

        // Don't set an error let it generate default and not trigger
        //[trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get total data xfer sent in MB
    int dataSent = [[dataXfer objectForKey:@"WiFiSent"] intValue] + [[dataXfer objectForKey:@"WANSent"] intValue] + [[dataXfer objectForKey:@"TUNSent"] intValue];
    
    // Calculate xfer per timeslot
    int dataSentPerTimeSlot = ceil(dataSent/timeSlots);
    
    // Check if we even occupy one timeslot
    if (dataSentPerTimeSlot < 1){
        //not been up long enough to be measured
        
        
        // Don't set an error let it generate default and not trigger
        //[trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Compare dataSentPerTimeSlot to maxData allowed
    
    if(dataSentPerTimeSlot > dataMax){
        
        [outputArray addObject:@"exfil"];
        
    }
  
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Unencrypted traffic
+ (BETrustFactorOutputObject *)unencryptedTraffic:(NSArray *)payload {
    
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
    
    // Check if error was determined by netstat data callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the current netstat data
    NSArray *connections = [[BETrustFactorDatasets sharedDatasets] getNetstatInfo];
    
    // Check if error from dataset (expired)
    if ([[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus] != DNEStatus_ok ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets] netstatDataDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check the array
    if (!connections || connections == nil || connections.count < 1) {
        // Current connection array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    
    // Run through all the connection dictionaries
    for (ActiveConnection *connection in connections) {
        
        // Skip if this is not a current connection
        if([connection.remoteHost isEqualToString:@"localhost"])
            continue;
        
        // If its 443 don't even look
        if([connection.remotePort intValue] == 443)
            continue;
        
        // Iterate through payload names and look for matching processes
        for (NSNumber *badDstPort in payload) {
            
            // Check if the domain of the connection equal one in payload
            if([connection.remotePort intValue] == [badDstPort intValue]) {
                // make sure we don't add more than one instance of the connection
                if (![outputArray containsObject:connection.remoteHost]){
                    
                    // Trim to last two octets of domain
                    NSString *host = connection.remoteHost;
                    
                    // > 15 its probably a DNS name
                    if(host.length > 15){
                        NSArray *components = [connection.remoteHost componentsSeparatedByString:@"."];
                        if (components.count > 1)
                        {
                            host = [components[components.count-2] stringByAppendingString:components[components.count-1]];
                        }
                    }else{
                        NSArray *components = [connection.remoteHost componentsSeparatedByString:@"."];
                        if (components.count == 4)
                        {
                            host = [[components[components.count-4] stringByAppendingString:components[components.count-3]] stringByAppendingString:components[components.count-2]];
                        }

                    }
                    

                    [outputArray addObject:host];
                }
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
