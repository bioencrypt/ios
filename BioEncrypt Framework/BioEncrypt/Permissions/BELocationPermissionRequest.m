//
//  BELocationPermissionRequest.m
//  BioEncrypt
//
//  Created by Ivo Leko on 04/05/2019.
//

#import "BELocationPermissionRequest.h"

@import CoreLocation;


@interface BELocationPermissionRequest () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL initialChangeAuthorizationStatusCallWasIgnored;
@property (nonatomic, copy) PermissionRequestCompletionBlock completionBlock;

@end

@implementation BELocationPermissionRequest

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        [_locationManager setDelegate:self];
    }
    
    return _locationManager;
}

- (void)dealloc {
    [_locationManager setDelegate:nil];
}


- (PermissionState)permissionState {
    CLAuthorizationStatus systemState = [CLLocationManager authorizationStatus];
    
    switch (systemState) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return PermissionState_Authorized;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            return PermissionState_Denied;
        default:
            return PermissionState_Unknown;
    }
}


- (void)requestUserPermissionWithCompletionBlock:(PermissionRequestCompletionBlock)completion {
    
    self.completionBlock = completion;
    [self.locationManager requestWhenInUseAuthorization];
}

+ (BOOL)grantedWhenInUse {
    return ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    BOOL notDetermined = (status == kCLAuthorizationStatusNotDetermined);

    
    if (notDetermined) {
        /* early calls to this delegate method are ignored, if this is not the change we are waiting for.
         e.g. the location manager calls this method immediately when requesting always permissions,
         if WhenInUse was already granted.
         */
        if (!self.initialChangeAuthorizationStatusCallWasIgnored) {
            self.initialChangeAuthorizationStatusCallWasIgnored = YES;
            return;
        }
    }
    
    [self handleCompletionBlock];
    
}

- (void)handleCompletionBlock {
    if (!self.completionBlock) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PermissionState currentState = self.permissionState;
        self.completionBlock(currentState, nil);
        self.completionBlock = nil;
    });
}


@end
