//
//  BETrustFactorDataset_Cell.h
//  BioEncrypt
//
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "BEConstants.h"
#import "BETrustFactorDatasets.h"

// Headers

@interface BETrustFactorDataset_Cell : NSObject

// Check which carrier we have
+ (NSString *) getCarrierName;

// Check which carrier we have
+ (NSString *) getCarrierSpeed;

// Check the strength of the signal
+ (NSNumber *) getSignalRaw;

// Check if we are in airplane mode
+ (NSNumber *) isAirplane;

@end

