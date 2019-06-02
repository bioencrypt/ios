//
//  BEPermissionRequest.h
//  BioEncrypt
//
//  Created by Ivo Leko on 05/05/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PermissionState_Unknown = 0,
    PermissionState_Unsupported,
    PermissionState_AskAgain,
    PermissionState_DoNotAskAgain,
    PermissionState_Denied,
    PermissionState_Authorized
    
} PermissionState;

typedef void (^PermissionRequestCompletionBlock)(PermissionState state, NSError * _Nullable error);


@interface BEPermissionRequest : NSObject

- (void)requestUserPermissionWithCompletionBlock:(PermissionRequestCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
