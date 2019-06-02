//
//  BETrustFactorDispatch_Wifi.h
//  BioEncrypt
//
//

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Wifi : NSObject

// Determine if the connected access point is a SOHO (Small Office/Home Offic) network
+ (BETrustFactorOutputObject *)consumerAP:(NSArray *)payload;

+ (BETrustFactorOutputObject *)hotspot:(NSArray *)payload;

+ (BETrustFactorOutputObject *)defaultSSID:(NSArray *)payload;

+ (BETrustFactorOutputObject *)unencryptedWifi:(NSArray *)payload;

/* Old/Archived
//+ (BETrustFactorOutput_Object *)captivePortal:(NSArray *)payload;
 */

// Unknown SSID Check - Get the current AP SSID
+ (BETrustFactorOutputObject *)SSIDBSSID:(NSArray *)payload; 


@end
