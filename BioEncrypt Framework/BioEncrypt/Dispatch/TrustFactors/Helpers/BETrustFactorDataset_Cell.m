//
//  BETrustFactorDataset_Cell.m
//  BioEncrypt
//
//

// Import header file
#import "BETrustFactorDataset_Cell.h"

// System Frameworks
#import <UIKit/UIKit.h>
@import CoreTelephony;

@implementation BETrustFactorDataset_Cell

static UIView* statusBarForegroundView;

// Check for signal strength
+(NSNumber*)getSignalRaw {
    
    NSDictionary* status = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"cellSignal"];
}

// Get WiFi IP Address
+ (NSString *)getCarrierName {
    
    NSDictionary* status = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"cellServiceString"];
}

// Get WiFi IP Address
+ (NSString *)getCarrierSpeed {
    
    NSString *carrierSpeed;
    CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
    carrierSpeed = telephonyInfo.currentRadioAccessTechnology;
    
    return carrierSpeed;
}

// Check if we are in airplane mode
+(NSNumber *)isAirplane{

    NSDictionary* status = [[BETrustFactorDatasets sharedDatasets] getStatusBar];
    return [status valueForKey:@"isAirplaneMode"];
}

@end
