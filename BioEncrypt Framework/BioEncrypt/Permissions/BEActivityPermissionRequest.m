//
//  ActivityPermissionRequest.m
//  BioEncrypt
//
//  Created by Ivo Leko on 05/05/2019.
//

#import "BEActivityPermissionRequest.h"

@import CoreMotion;


@interface BEActivityPermissionRequest ()
@property (nonatomic, strong) CMMotionActivityManager *activityManager;
@property (nonatomic, strong) NSOperationQueue *motionActivityQueue;
@property (nonatomic) PermissionState internalPermissionState;
@end


@implementation BEActivityPermissionRequest

- (PermissionState)permissionState {
    if (![CMMotionActivityManager isActivityAvailable]) {
        return PermissionState_Unsupported;
    }
    
    return self.internalPermissionState;
}


- (void)requestUserPermissionWithCompletionBlock:(PermissionRequestCompletionBlock)completion {
   
    [self setInternalPermissionState:PermissionState_DoNotAskAgain]; // avoid asking again
    self.activityManager = [[CMMotionActivityManager alloc] init];
    self.motionActivityQueue = [[NSOperationQueue alloc] init];
    [self.activityManager queryActivityStartingFromDate:[NSDate distantPast] toDate:[NSDate date] toQueue:self.motionActivityQueue withHandler:^(NSArray *activities, NSError *error) {
        PermissionState currentState = PermissionState_Unknown;
        NSError *externalError = [self externalErrorForError:error validationDomain:CMErrorDomain denialCodes:[NSSet setWithObjects:@(CMErrorMotionActivityNotAuthorized), @(CMErrorNotAuthorized), nil]];
        
        if (error && !externalError) {
            currentState = PermissionState_Denied;
        } else if (activities || !error) {
            currentState = PermissionState_Authorized;
        }
        
        [self setInternalPermissionState:currentState];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(currentState, externalError);
        });
        
        [self setActivityManager:nil];
        [self setMotionActivityQueue:nil];
    }];
}

- (nullable NSError *)externalErrorForError:(nullable NSError *)error validationDomain:(nonnull NSString *)requiredDomain denialCodes:(nonnull NSSet<NSNumber *> *)denialCodes {
    if (![error.domain isEqualToString:requiredDomain]) {
        return nil;
    }
    if ([denialCodes containsObject:@(error.code)]) {
        return nil;
    }
    return error;
}

@end
