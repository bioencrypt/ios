//
//  BEBiometricManager.h
//  BioEncrypt
//
//  Created by Ivo Leko on 10/10/16.
//

#import <Foundation/Foundation.h>
#import "BECoreDetection.h"

#define serviceName @"BioEncrypt_Biometric_Service"


@import LocalAuthentication;



typedef void (^ResultBlock)(BOOL successful, NSError *error);
typedef void (^BiometricResultBlock)(BiometricResultType resultType, NSError *error);
typedef void (^BiometricGetResultBlock)(BiometricResultType resultType, NSString *password, NSError *error);


@interface BEBiometricManager : NSObject

//flag for stroing information if TouchID/FaceID item is invalidated
@property (nonatomic, readonly) BOOL biometricItemInvalidated;


+ (BEBiometricManager *) shared;

- (BOOL) checkIfBiometricIsAvailableWithError: (NSError **) error;
- (void) checkForBiometricAuthWithMessage: (NSString *) message withCallback: (BiometricResultBlock) block;
- (void) addBiometricPasswordToKeychain: (NSString *) password withCallback: (BiometricResultBlock) block;
- (void) removeBiometricPasswordFromKeychainWithCallback: (BiometricResultBlock) block;
- (void) getBiometricPasswordFromKeychainwithMessage:(NSString *) message withCallback: (BiometricGetResultBlock) block;
- (void) invalidate;

//helper method
- (void) createBiometricWithDecryptedMasterKey: (NSData *) decryptedMasterKey withCallback: (ResultBlock) block;

@end
