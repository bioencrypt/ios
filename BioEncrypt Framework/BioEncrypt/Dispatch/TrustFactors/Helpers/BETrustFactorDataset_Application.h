//
//  BETrustFactorDataset_Application.h
//  BioEncrypt
//
//

// Import Constants
#import "BEConstants.h"

// Headers
#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

@interface BETrustFactorDataset_Application : NSObject

// USES PRIVATE API
+ (NSArray *)getUserAppInfo;

@end
