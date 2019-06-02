//
//  BETrustFactorDataset_Process.h
//  SenTest
//
//  Created by Nick Kramer on 2/7/15.
//

// Import Constants
#import "BEConstants.h"

// Headers
#import <Foundation/Foundation.h>
#import <sys/sysctl.h>

@interface BETrustFactorDataset_Process : NSObject

// List of process information including PID's, Names, PPID's, and Status'
+ (NSArray *)getProcessInfo;

// Get self PID
+ (NSNumber *) getOurPID;

@end
