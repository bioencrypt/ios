//
//  BETrustFactorDispatch_Wifi.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Wifi.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NetworkExtension/NetworkExtension.h>
#import <ifaddrs.h>
#import <net/if.h>

@implementation BETrustFactorDispatch_Wifi


// Determine if the connected access point is a SOHO (Small Office/Home Offic) network based on mac OUI
+ (BETrustFactorOutputObject *)defaultSSID:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Check if WiFi is disabled
    if([[[BETrustFactorDatasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }    // If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    NSDictionary *wifiInfo = [[BETrustFactorDatasets sharedDatasets] getWifiInfo];
    
    // Check for a connection
    if (wifiInfo == nil){
        
        // WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    // Get the ssid
    NSString *ssid = [wifiInfo objectForKey:@"ssid"];
    
    // Validate the ssid
    if ((ssid == nil && ssid.length == 0)) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check OUI of connected AP based on BSSID
    NSArray *defaultSSIDList;
    
    // Look for our OUI list
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kCoreDetectionBundle withExtension:kCoreDetectionBundleExtension]];
    NSString* ssidListPath = [bundle pathForResource:kCDBDefaultSSIDS ofType:kCDBDefaultSSIDSType];
    
    NSString* fileContents =
    [NSString stringWithContentsOfFile:ssidListPath
                              encoding:NSUTF8StringEncoding error:nil];
    
    // If we didn't find our OUI list, fallback on payload list
    if(fileContents == nil) {
        
        // Try payload
        if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
            // Payload is EMPTY
            
            // Set the DNE status code to NODATA
            [trustFactorOutputObject setStatusCode:DNEStatus_error];
            
            // Return with the blank output object
            return trustFactorOutputObject;
            
        } else {
            
            //Use the payload list
            defaultSSIDList = payload;
        }
        
    } else {
        
        defaultSSIDList =
        [fileContents componentsSeparatedByCharactersInSet:
         [NSCharacterSet newlineCharacterSet]];
    }
    
 
    NSArray *results;

    // Run through the payload and compare to the BSSID
    for (NSString *defaultSSID in defaultSSIDList) {
      
        // Create instance of NSRegularExpression
        NSError *error;
        // which is a compiled regular expression pattern
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:defaultSSID options:0 error:&error];
        
        // Array of matches of regex in string
        results = [regex matchesInString:ssid options:0 range:NSMakeRange(0, ssid.length)];
            
        if (results.count > 0){
            
            [outputArray addObject:[wifiInfo objectForKey:@"ssid"]];
            break;
            
        }

    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}



// Determine if the connected access point is a SOHO (Small Office/Home Offic) network based on mac OUI
+ (BETrustFactorOutputObject *)consumerAP:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Try payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }

    
    // Check if WiFi is disabled
    if([[[BETrustFactorDatasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }    // If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    NSDictionary *wifiInfo = [[BETrustFactorDatasets sharedDatasets] getWifiInfo];
    
    // Check for a connection
    if (wifiInfo == nil){
        
        // WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }

    // Get the BSSID
    NSString *bssid = [wifiInfo objectForKey:@"bssid"];
    
    // Validate the gateway IP and BSSID
    if ((bssid == nil && bssid.length == 0)) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check OUI of connected AP based on BSSID
    NSArray *ouiList;
    
    // Look for our OUI list
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kCoreDetectionBundle withExtension:kCoreDetectionBundleExtension]];
    NSString* ouiListPath = [bundle pathForResource:kCDBOUI ofType:kCDBOUIType];
    
    NSString* fileContents =
    [NSString stringWithContentsOfFile:ouiListPath
                              encoding:NSUTF8StringEncoding error:nil];
    
    ouiList =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    bool OUImatch = NO;
    // Run through the payload and compare to the BSSID
    for (NSString *oui in ouiList) {
        // Check if the bssid matches one of the OUI's in the payload
        if ([bssid rangeOfString:oui options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            
            OUImatch=YES;
            
            // Break from the for loop
            break;
        }
    }

    
    NSString *gatewayIP = [wifiInfo objectForKey:@"gatewayIP"];
    
    // Validate the gateway IP and BSSID
    if ((gatewayIP == nil && gatewayIP.length == 0)) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    bool IPmatch = NO;
    // Run through all the files in the payload
    for (NSString *ip in payload) {
        
        // Check if they exist
        if ([gatewayIP containsString:ip]) {
            
            // If the bad file exists, mark it in the array
            IPmatch=YES;
            break;
            
        }
    }
    
    if(OUImatch==YES && IPmatch==YES){
        // Add the SSID
        [outputArray addObject:[wifiInfo objectForKey:@"ssid"]];
    }
    
      // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}


// Determine if the connected access point is hotspot using a static list and dynamic guessing
+ (BETrustFactorOutputObject *)hotspot:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Check if WiFi is disabled
    if([[[BETrustFactorDatasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }    // If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    NSDictionary *wifiInfo = [[BETrustFactorDatasets sharedDatasets] getWifiInfo];
    
    // Check for a connection
    if (wifiInfo == nil){
        
        // WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    // Get the ssid
    NSString *ssid = [wifiInfo objectForKey:@"ssid"];
    
    // Validate the gateway IP and BSSID
    if ((ssid == nil && ssid.length == 0)) {
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check OUI of connected AP based on BSSID
    NSArray *hotspotList;
    
    // Look for our OUI list
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kCoreDetectionBundle withExtension:kCoreDetectionBundleExtension]];
    NSString* ouiListPath = [bundle pathForResource:kCDBHotspotSSIDS ofType:kCDBHotspotSSIDSType];
    
    NSString* fileContents =
    [NSString stringWithContentsOfFile:ouiListPath
                              encoding:NSUTF8StringEncoding error:nil];
    
    hotspotList =
    [fileContents componentsSeparatedByCharactersInSet:
     [NSCharacterSet newlineCharacterSet]];
    
    bool hotspotListMatch = NO;
    // Run through the payload and compare to the BSSID
    for (NSString *hotspot in hotspotList) {
        // Check if the bssid matches one of the OUI's in the payload
        if ([ssid rangeOfString:hotspot options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            
            hotspotListMatch=YES;
            
            // Break from the for loop
            break;
        }
    }
    
    // Test for basic hotspot names
    
    bool hotspotDynamicMatch=NO;
    
    if(hotspotListMatch==NO){
        
        if ([ssid rangeOfString:@"wifi" options:NSCaseInsensitiveSearch].location != NSNotFound || [ssid rangeOfString:@"wi-fi" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
            
            if ([ssid rangeOfString:@"free" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
            
            if ([ssid rangeOfString:@"guest" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
            
            if ([ssid rangeOfString:@"public" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
            
        }else if ([ssid rangeOfString:@"hotspot" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
                hotspotDynamicMatch = YES;
            
        }else if ([ssid rangeOfString:@"guest" options:NSCaseInsensitiveSearch].location != NSNotFound){
            
            if ([ssid rangeOfString:@"net" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
            
            if ([ssid rangeOfString:@"_" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
            
            if ([ssid rangeOfString:@"-" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
                
                hotspotDynamicMatch = YES;
                
            }
        }
    }


    if(hotspotDynamicMatch==YES || hotspotListMatch==YES){
        // Add the SSID
        [outputArray addObject:[wifiInfo objectForKey:@"ssid"]];
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Determine if the connected access point is unencrypted using Network Extension API and entitlement provided by Apple
+ (BETrustFactorOutputObject *)unencryptedWifi:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Check if WiFi is disabled
    if([[[BETrustFactorDatasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }    // If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    

    NSArray *wifiEncryption = [[BETrustFactorDatasets sharedDatasets] getWifiEncryption];
    
    // Check for a connection
    if (wifiEncryption == nil || wifiEncryption.count == 0){
        
        // WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    // Get ssids of unsecure networks, and save them into output array
    for (NSDictionary *dic in wifiEncryption) {
        if (![dic[@"secure"] boolValue]) {
            [outputArray addObject:dic[@"ssid"]];
        }
    }
    

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}



/* Old/Archived
 
 + (BETrustFactorOutput_Object *)captivePortal:(NSArray *)payload {
 
 // Create the trustfactor output object
 BETrustFactorOutput_Object *trustFactorOutputObject = [[BETrustFactorOutput_Object alloc] init];
 
 // Set the default status code to OK (default = DNEStatus_ok)
 [trustFactorOutputObject setStatusCode:DNEStatus_ok];
 
 // Create the output array
 NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
 
 //No connection, check if WiFi is enabled
 if([[BETrustFactorDatasets sharedDatasets] isWifiEnabled]==NO){
 
 //Not enabled, set DNE and return (penalize)
 [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
 
 // Return with the blank output object
 return trustFactorOutputObject;
 }
 
 NSDictionary *wifiInfo = [[BETrustFactorDatasets sharedDatasets] getWifiInfo];
 
 // Check for a connection
 if (wifiInfo == nil){
 
 //WiFi is enabled but there is no connection (don't penalize)
 [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
 
 // Return with the blank output object
 return trustFactorOutputObject;
 
 }
 
 NSString *ssid = [wifiInfo objectForKey:@"ssid"];
 
 
 //Perform WISPR check
 NSString *url =@"http://www.apple.com/library/test/success.html";
 NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]
 initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
 
 [urlRequest setValue:@"CaptiveNetworkSupport/1.0 wispr" forHTTPHeaderField:@"User-Agent"];
 
 NSData *data = [ NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: nil ];
 NSString *returnDataWispr = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding: NSUTF8StringEncoding];
 
 //Perform Blank page check
 url =@"http://www.google.com/blank.html";
 urlRequest = [[NSMutableURLRequest alloc]
 initWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
 
 data = [ NSURLConnection sendSynchronousRequest:urlRequest returningResponse: nil error: nil ];
 NSString *returnDataBlank = [[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding: NSUTF8StringEncoding];
 
 // Check if WISPR return something other than "Success" HTML AND if the AP returns a login page instead of blank during google check
 if(![returnDataWispr containsString:@"Success"] || [returnDataBlank length] > 1)
 {
 [outputArray addObject:ssid];
 }
 
 
 
 // Set the trustfactor output to the output array (regardless if empty)
 [trustFactorOutputObject setOutput:outputArray];
 
 // Return the trustfactor output object
 return trustFactorOutputObject;
 
 return 0;
 }
 
 */

// Unknown SSID Check - Get the current AP SSID
+ (BETrustFactorOutputObject *)SSIDBSSID:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets]  validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    //Ceck if WiFi is disabled
    if([[[BETrustFactorDatasets sharedDatasets] isWifiEnabled] intValue]==0){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_disabled];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }    //If we're enabled, still check if we're tethering and set as unavaialble if we are
    else if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        //Not enabled, set DNE and return (penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_unavailable];
        
        // Return with the blank output object
        return trustFactorOutputObject;
        
    }
    
    NSDictionary *wifiInfo = [[BETrustFactorDatasets sharedDatasets] getWifiInfo];
    
    // Check for a connection
    if (wifiInfo == nil){
        
        //WiFi is enabled but there is no connection (don't penalize)
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the current Access Point BSSID
    NSString *bssid = nil;
    
    // Get the current Access Point SSID
    NSString *ssid = nil;
    
    ssid = [wifiInfo objectForKey:@"ssid"];
    
    bssid = [wifiInfo objectForKey:@"bssid"];
    
    // Get the length of MAC address to use from
    int lengthOfMAC = [[[payload objectAtIndex:0] objectForKey:@"MACAddresslength"] intValue];
    
    // Validate the BSSID and SSID
    if ((bssid != nil && bssid.length > 0) && (ssid != nil && ssid.length > 0)) {
        
        // Get all of MAC except the specificed octets or hex
        
        // For System/User unfamiliar WiFi rules we skip the last two octets, this ensures that if the device is in a different (e.g., starbucks) with the same ssid the rule will still trigger but it hopefully won't trigger in an enterprise environment where the end of a MAC address is very close because they were all purchased together. Dictated by TrustFactor's payload value.
        
        // For User BSSID authenticator rule we get all but the last hex digit of MAC address, this is because SOHO routers have multiple attenas and we don't want the rule to not recognize the same AP just because it switched attenas. Dictated by TrustFactor's payload value.
        
        NSString *trimmedBSSID = [bssid substringToIndex:lengthOfMAC];
        
        
        // Add the current bssid to the list
        [outputArray addObject:[[ssid stringByAppendingString:@"_"] stringByAppendingString:trimmedBSSID]];
    }else{
        
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        return trustFactorOutputObject;
        
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// Unknown SSID Check - Get the current AP SSID
+ (BETrustFactorOutputObject *)hotspotEnabled:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    if([[[BETrustFactorDatasets sharedDatasets] isTethering] intValue]==1){
        
        [outputArray addObject:@"hotspotOn"];
        
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

@end
