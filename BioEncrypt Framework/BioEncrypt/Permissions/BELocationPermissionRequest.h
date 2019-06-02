//
//  BELocationPermissionRequest.h
//  BioEncrypt
//
//  Created by Ivo Leko on 04/05/2019.
//

#import <Foundation/Foundation.h>
#import "BEPermissionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BELocationPermissionRequest : BEPermissionRequest
- (PermissionState)permissionState;
@end

NS_ASSUME_NONNULL_END
