//
//  BELoginAction.h
//  BioEncrypt
//
//

/*!
 *  Login action activates the different login actions and sets trustfactors to whitelist
 */

#import <Foundation/Foundation.h>

// Policy
#import "BEPolicy.h"

// Login Response Object
#import "BELoginResponse_Object.h"


@interface BELoginAction : NSObject

/*!
 *  sharedLogin
 *
 *  @return Singleton Instance
 */
+ (id)sharedLogin;

#pragma mark - Pre Auth function
/*!
 *  attempt login returns the decrypted master key for transparent auth and interactive
 *
 *  @param action specifies what to do
 *
 *  @return Whether the protect mode was deactived or not
 */

- (BELoginResponse_Object *)attemptLoginWithTransparentAuthentication:(NSError **)error;

- (BELoginResponse_Object *)attemptLoginWithPassword:(NSString *)Userinput andError:(NSError **)error;

- (BELoginResponse_Object *)attemptLoginWithBiometricpassword:(NSString *)biometricPassword andError:(NSError **)error;

- (BELoginResponse_Object *)attemptLoginWithBlockAndWarn:(NSError **)error;


@end
