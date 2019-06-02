//
//  BETrustFactorDataset_Config.h
//  BioEncrypt
//
//

// Import Constants
#import "BEConstants.h"

// Headers
#import <Foundation/Foundation.h>

@interface BETrustFactorDataset_Config : NSObject

// Check if wdevice password set
+ (NSNumber *) hasPassword;

@end
