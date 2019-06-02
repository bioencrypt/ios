//
//  BETrustFactorDataset_Motion.h
//  BioEncrypt
//
//

// System Frameworks
#import <Foundation/Foundation.h>

// Import Constants
#import "BEConstants.h"

// Headers
#import "BETrustFactorDatasets.h"

// Location Info
@interface BETrustFactorDataset_Motion : NSObject

// Moving function
+ (NSNumber *) gripMovement;

// Orientation function
+ (NSString *) orientation;

// Total movement of user and device
+ (NSString *) userMovement;

@end

