//
//  BEActivityPermissionRequest.h
//  BioEncrypt
//
//  Created by Ivo Leko on 05/05/2019.
//

#import <Foundation/Foundation.h>
#import "BEPermissionRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface BEActivityPermissionRequest : BEPermissionRequest
- (PermissionState)permissionState;

@end

NS_ASSUME_NONNULL_END
