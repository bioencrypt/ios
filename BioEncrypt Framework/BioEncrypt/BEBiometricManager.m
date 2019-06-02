//
//  BEBiometricManager.m
//  BioEncrypt
//
//  Created by Ivo Leko on 10/10/16.
//

#import "BEBiometricManager.h"
#import "BECrypto.h"
#import "BEStartupStore.h"
#import "BEConstants.h"

@interface BEBiometricManager ()

@property (nonatomic, strong) LAContext *context;

@end

@implementation BEBiometricManager

+ (BEBiometricManager *) shared {
    static BEBiometricManager* _sharedBiometricManager = nil;
    static dispatch_once_t onceTokenBiometricManager;
    
    dispatch_once(&onceTokenBiometricManager, ^{
        _sharedBiometricManager = [[BEBiometricManager alloc] init];
        _sharedBiometricManager.context = [[LAContext alloc] init];
    });
    
    return _sharedBiometricManager;
}

- (void) invalidate {
    [self.context invalidate];
}


- (void) createBiometricWithDecryptedMasterKey: (NSData *) decryptedMasterKey withCallback: (ResultBlock) block {
    
    //generate random password with BECrypto
    NSData *randomSalt = [[BECrypto sharedCrypto] generateSalt256];
    NSError *error;
    NSString *randomPassword = [[BECrypto sharedCrypto] convertDataToHexString:randomSalt withError:&error];
    
    if (error) {
        block (NO, error);
        return;
    }
    
    //first we want for sure delete old keychain item (if any) that can remain from previous installation of the app
    [self removeBiometricPasswordFromKeychainWithCallback:^(BiometricResultType resultType, NSError *error) {
        
        //we succesfully deleted old keychain item, or item does not even exists
        if (resultType == BiometricResultType_ItemNotFound || resultType == BiometricResultType_Success) {
            //store new password into TouchID/FaceID keychain
            [self addBiometricPasswordToKeychain:randomPassword withCallback:^(BiometricResultType resultType, NSError *error) {
                
                if (resultType == BiometricResultType_Success && !error) {
                    
                    [[BEStartupStore sharedStartupStore] updateStartupFileWithBiometricPassoword:randomPassword masterKey:decryptedMasterKey withError:&error];
                    
                    if (error) {
                        //TODO: error message for user
                        [[BEBiometricManager shared] removeBiometricPasswordFromKeychainWithCallback:nil];
                        block(NO, error);
                        return;
                    }
                    block(YES, nil);
                }
                else if (resultType == BiometricResultType_DuplicateItem) {
                    //scenario that should not happen
                    NSError *error;
                    
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"TouchID/FaceID already exists.", nil),
                                                   };
                    
                    // Set the error
                    error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                    block(NO, error);

                }
                else {
                    block(NO, error);
                }
            }];
        }
        else
            block(NO, error);
    }];

}


- (BOOL) checkIfBiometricIsAvailableWithError: (NSError **) error {
    return [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:error];
}

- (void) checkForBiometricAuthWithMessage: (NSString *) message withCallback: (BiometricResultBlock) block {
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:message reply:^(BOOL success, NSError * _Nullable error) {
        
        if (block == nil)
            return;
        
        if (success)
            block (BiometricResultType_Success, nil);
        else {
            if (error.code == LAErrorUserCancel)
                block (BiometricResultType_UserCanceled, error);
            else if (error.code == LAErrorAuthenticationFailed)
                block (BiometricResultType_FailedAuth, error);
            else
                block (BiometricResultType_Error, error);
        }
    }];
}

- (void) addBiometricPasswordToKeychain: (NSString *) password withCallback: (BiometricResultBlock) block {
    
    CFErrorRef error = NULL;
    
    
    SecAccessControlRef sacObject;
    if (@available(iOS 11.3, *)) {
         sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                     kSecAccessControlBiometryCurrentSet, &error);
    } else {
        sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                    kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                    kSecAccessControlTouchIDCurrentSet, &error);
    }

    
   
    if (sacObject == NULL || error != NULL) {
        NSString *errorString = [NSString stringWithFormat:@"SecItemAdd can't create sacObject: %@", error];
        NSLog(@"%@", errorString);
        NSError *errorT = (__bridge NSError *)error;

        if (block == nil)
            return;
        block (BiometricResultType_Error, errorT);
        return;
    }
    

    NSData *secretPasswordTextData = [password dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributes = @{
                                 (id)kSecClass: (id)kSecClassGenericPassword,
                                 (id)kSecAttrService: serviceName,
                                 (id)kSecValueData: secretPasswordTextData,
                                 (id)kSecUseAuthenticationUI: (id)kSecUseAuthenticationUIAllow,
                                 (id)kSecAttrAccessControl: (__bridge_transfer id)sacObject
                                 };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
       
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (block == nil)
                return;
            
            switch (status) {
                case errSecSuccess:
                    self->_biometricItemInvalidated = NO;
                    block (BiometricResultType_Success, nil);
                    break;
                    
                case errSecDuplicateItem:
                    block (BiometricResultType_DuplicateItem, nil);
                    break;
                    
                default: {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                   };
                    
                    NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                    block(BiometricResultType_Error, error);
                }
                    break;
            }
        });
    });
}

- (void) removeBiometricPasswordFromKeychainWithCallback: (BiometricResultBlock) block {
    NSDictionary *query = @{
                            (id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrService: serviceName
                            };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block == nil)
                return;
            
            switch (status) {
                case errSecSuccess:
                    block (BiometricResultType_Success, nil);
                    break;
                    
                case errSecItemNotFound:
                    block (BiometricResultType_ItemNotFound, nil);
                    break;
                    
                default: {
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                   };
                    
                    NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                    block(BiometricResultType_Error, error);
                }
                    break;
            }
            
        });
    });
}

- (void) getBiometricPasswordFromKeychainwithMessage:(NSString *) message withCallback: (BiometricGetResultBlock) block {
    
    NSDictionary *query = @{
                            (id)kSecClass: (id)kSecClassGenericPassword,
                            (id)kSecAttrService: serviceName,
                            (id)kSecReturnData: @YES,
                            (id)kSecUseOperationPrompt: message,
                            };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFTypeRef dataTypeRef = NULL;
        
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &dataTypeRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block == nil)
                return;
            
            if (status == errSecSuccess) {
                NSData *resultData = (__bridge_transfer NSData *)dataTypeRef;
                NSString *result = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                
                block (BiometricResultType_Success, result, nil);
            }
            else {
                switch (status) {
                        
                    case errSecItemNotFound:
                        self->_biometricItemInvalidated = YES;
                        block (BiometricResultType_ItemNotFound, nil, nil);
                        break;
                        
                    case errSecAuthFailed:
                        block (BiometricResultType_FailedAuth, nil, nil);
                        break;
                        
                    case errSecUserCanceled:
                        block (BiometricResultType_UserCanceled, nil, nil);
                        break;
                        
                        
                    default: {
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"SecItemAdd failed with status code: %d", (int)status]
                                                       };
                        
                        NSError *error = [NSError errorWithDomain:serviceName code:status userInfo:errorDetails];
                        block(BiometricResultType_Error, nil, error);
                    }
                        break;
                }

            }

        });
    });
}


@end
