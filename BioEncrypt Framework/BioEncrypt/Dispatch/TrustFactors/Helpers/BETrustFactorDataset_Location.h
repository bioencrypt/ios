//
//  BETrustFactorDataset_Location.h
//  BioEncrypt
//
//  Created by Jason Sinchak on 7/19/15.
//

// Import Constants
#import "BEConstants.h"

// Headers
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BETrustFactorDataset_Location : NSObject

// Get the users location
+ (void)getLocation;


@end

