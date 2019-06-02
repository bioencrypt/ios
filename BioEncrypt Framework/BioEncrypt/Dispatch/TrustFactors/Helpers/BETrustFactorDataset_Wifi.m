//
//  BETrustFactorDataset_Wifi.m
//  BioEncrypt
//
//  Created by Jason Sinchak on 7/24/15.
//


#import "BETrustFactorDataset_Wifi.h"
#import "ActiveRoute.h"
#import <NetworkExtension/NetworkExtension.h>



@implementation BETrustFactorDataset_Wifi

// Get wifi information
+(NSDictionary*)getWifi{
    
    // If wifi is not connected
    if(![self isWiFiConnected]){
        return nil;
    }
    
    // Get the current Access Point BSSID
    NSString *bssid = nil;
    
    // Get the current Access Point SSID
    NSString *ssid = nil;
    
    // Get the current Access Point Gateway IP
    NSString *gatewayIP = nil;
    
    // Get the current WiFi interface IP
    NSString *wifiIP = nil;
    
    // Get the supported network interfaces
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    // Check if the array is valid
    if (!ifs || ifs == nil) {
        // Unable to use this api on this device
        
        // Return with the blank output object
        return nil;
    }
    
    // Run through the interfaces
    for (NSString *ifnam in ifs) {
        // Get the current interface object's network information
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        // Check if the interface contains the BSSID key
        if (info[@"SSID"]) {
            
            // Set the BSSID variable
            bssid = info[@"BSSID"];
            
            //Check if it starts with 00:, as if it does it seems to truncate the first 0 so fix it up
            if([[bssid substringToIndex:2] isEqualToString:@"0:"]){
                
                bssid = [@"0" stringByAppendingString:info[@"BSSID"]];
            }
            
            // Set the BSSID variable
            ssid = info[@"SSID"];
        }
        
    }
    
    // Validate the SSID & BSSID
    if (ssid == nil || ssid.length == 0 || bssid ==nil || bssid.length ==0) {
        return nil;
    }
    
    // Set the route array variable with the routing information
    NSArray *routeArray = [[BETrustFactorDatasets sharedDatasets] getRouteInfo];
    
    // Return the first route object's gateway IP which will be WiFi if it is connected
    gatewayIP = [[routeArray objectAtIndex:0] gateway];
    
    // Validate the gatewayIP
    if (gatewayIP == nil || gatewayIP.length == 0) {
        return nil;
    }
    
    // Set wifi IP address
    wifiIP = [self wiFiIPAddress];
    
    // Validate the wifiIP
    if (wifiIP == nil || wifiIP.length == 0) {
        return nil;
    }
    
    // Create an array of the objects
    NSArray *ItemArray = [NSArray arrayWithObjects:ssid, bssid, gatewayIP, wifiIP, nil];
    
    // Create an array of keys
    NSArray *KeyArray = [NSArray arrayWithObjects:@"ssid", @"bssid", @"gatewayIP", @"wifiIP", nil];
    
    // Create the dictionary
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
    
    return dict;
}

// Get WiFi IP Address
+ (NSString *)wiFiIPAddress {
    // Get the WiFi IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        // Set up int for success or fail
        int Status = 0;
        
        // Get all the network interfaces
        Status = getifaddrs(&Interfaces);
        
        // If it's 0, then it's good
        if (Status == 0)
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is WiFi
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"en0"])
                    {
                        // Get the WiFi IP Address
                        IPAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)Temp->ifa_addr)->sin_addr)];
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Get Current IP Address
+ (NSString *)currentIPAddress {
    // Get the current IP Address
    
    // Check which interface is currently in use
    if ([self isWiFiConnected]) {
        // WiFi is in use
        
        // Get the WiFi IP Address
        NSString *WiFiAddress = [self wiFiIPAddress];
        
        // Check that you get something back
        if (WiFiAddress == nil || WiFiAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Wifi address
        return WiFiAddress;
    } else if ([self connectedToCellNetwork]) {
        // Cell Network is in use
        
        // Get the Cell IP Address
        NSString *CellAddress = [self cellIPAddress];
        
        // Check that you get something back
        if (CellAddress == nil || CellAddress.length <= 0) {
            // Error, no address found
            return nil;
        }
        
        // Return Cell address
        return CellAddress;
    } else {
        // No interface in use
        return nil;
    }
}

// Get the External IP Address
+ (NSString *)externalIPAddress {
    @try {
        // Check if we have an internet connection then try to get the External IP Address
        if (![self connectedToCellNetwork] && ![self isWiFiConnected]) {
            // Not connected to anything, return nil
            return nil;
        }
        
        // Get the external IP Address based on dynsns.org
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"]
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (!error) {
            NSUInteger an_Integer;
            NSArray *ipItemsArray;
            NSString *externalIP;
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray = [theIpHtml  componentsSeparatedByString:@" "];
                an_Integer = [ipItemsArray indexOfObject:@"Address:"];
                
                externalIP =[ipItemsArray objectAtIndex:++an_Integer];
            }
            
            // Check that you get something back
            if (externalIP == nil || externalIP.length <= 0) {
                // Error, no address found
                return nil;
            }
            
            // Return External IP
            return externalIP;
        } else {
            // Error, no address found
            return nil;
        }
    }
    @catch (NSException *exception) {
        // Error, no address found
        return nil;
    }
}

// Get Cell IP Address
+ (NSString *)cellIPAddress {
    // Get the Cell IP Address
    @try {
        // Set a string for the address
        NSString *IPAddress;
        // Set up structs to hold the interfaces and the temporary address
        struct ifaddrs *Interfaces;
        struct ifaddrs *Temp;
        struct sockaddr_in *s4;
        char buf[64];
        
        // If it's 0, then it's good
        if (!getifaddrs(&Interfaces))
        {
            // Loop through the list of interfaces
            Temp = Interfaces;
            
            // Run through it while it's still available
            while(Temp != NULL)
            {
                // If the temp interface is a valid interface
                if(Temp->ifa_addr->sa_family == AF_INET)
                {
                    // Check if the interface is Cell
                    if([[NSString stringWithUTF8String:Temp->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        s4 = (struct sockaddr_in *)Temp->ifa_addr;
                        
                        if (inet_ntop(Temp->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL) {
                            // Failed to find it
                            IPAddress = nil;
                        } else {
                            // Got the Cell IP Address
                            IPAddress = [NSString stringWithUTF8String:buf];
                        }
                    }
                }
                
                // Set the temp value to the next interface
                Temp = Temp->ifa_next;
            }
        }
        
        // Free the memory of the interfaces
        freeifaddrs(Interfaces);
        
        // Check to make sure it's not empty
        if (IPAddress == nil || IPAddress.length <= 0) {
            // Empty, return not found
            return nil;
        }
        
        // Return the IP Address of the WiFi
        return IPAddress;
    }
    @catch (NSException *exception) {
        // Error, IP Not found
        return nil;
    }
}

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork {
    // Check if we're connected to cell network
    NSString *CellAddress = [self cellIPAddress];
    // Check if the string is populated
    if (CellAddress == nil || CellAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // Cellular Network in use
        return true;
    }
}

// Is wifi enabled
+ (NSNumber *) isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    // FREEDOM
    freeifaddrs(interfaces);
    
    // If we got more than 1 instance of awdl0 from this API its a trick to tell that WiFi is enabled
    if([cset countForObject:@"awdl0"] > 1){
        return [NSNumber numberWithInt:1];
    } else {
        
        // Check if we're tethering
        if([[self isTethering] intValue] == 1){
            
            return [NSNumber numberWithInt:1];
            
        } else { //return that its disabled for realz
            
            return [NSNumber numberWithInt:0];
        }
    }
    
}

// Check if tethering
+ (NSNumber *) isTethering {
    
    NSDictionary* status = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"isTethering"];
    
}

// Get the wifi signal
+ (NSNumber *) getSignal{
    
    NSDictionary* status = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"wifiSignal"];
}

// Connected to WiFi?
+ (BOOL)isWiFiConnected {
    // Check if we're connected to WiFi
    NSString *WiFiAddress = [self wiFiIPAddress];
    // Check if the string is populated
    if (WiFiAddress == nil || WiFiAddress.length <= 0) {
        // Nothing found
        return false;
    } else {
        // WiFi in use
        return true;
    }
}

// check if connected to unencrypted wifi
+ (NSArray *) getWifiEncryption {
    
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    @autoreleasepool {
        //it is necessary to call registerWithOptions: queue: handler: method before supportedNetworkInterfaces (to avoid getting nil instead of array
        dispatch_queue_t myQueue = dispatch_queue_create("HotSpotHelperQueue",NULL);
        [NEHotspotHelper registerWithOptions:nil queue:myQueue handler:^(NEHotspotHelperCommand * _Nonnull cmd) {
    
        }];
    }
    
    for(NEHotspotNetwork *hotspotNetwork in [NEHotspotHelper supportedNetworkInterfaces])
    {
        NSString *ssid = hotspotNetwork.SSID;
        NSString *bssid = hotspotNetwork.BSSID;
        BOOL secure = hotspotNetwork.secure;
        BOOL autoJoined = hotspotNetwork.autoJoined;
        double signalStrength = hotspotNetwork.signalStrength;
        
        
        NSDictionary *dic = @{
                              @"ssid"           : ssid,
                              @"bssid"          : bssid,
                              @"autoJoined"     : @(autoJoined),
                              @"signalStrength" : @(signalStrength),
                              @"secure"         : @(secure)
                              };
        [arrayM addObject:dic];
    }


    return [NSArray arrayWithArray: arrayM];

}


@end
