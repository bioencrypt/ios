//
//  BETrustFactorDataset_Wifi.h
//  BioEncrypt
//
//  Created by Jason Sinchak on 7/19/15.
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "BEConstants.h"

// Headers
#import <arpa/inet.h>
#import "BETrustFactorDatasets.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <net/if.h>

@interface BETrustFactorDataset_Wifi : NSObject

// Get wifi information
+ (NSDictionary*)getWifi;

// Signal information
+ (NSNumber *) getSignal;

// Check if wifi enables
+ (NSNumber *)isWiFiEnabled;

// Check if tethering
+ (NSNumber *)isTethering;

// check if connected to unencrypted wifi
+ (NSArray *) getWifiEncryption;

@end

