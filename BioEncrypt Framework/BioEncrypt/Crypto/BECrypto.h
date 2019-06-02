//
//  BECrypto
//  BioEncrypt
//
//

/*!
 *  Crypto Module with hashing and cryptographic functionality
 */

// BECrypto Policy
#import "BEPolicy.h"

// Startup
#import "BEStartup.h"
#import "BETransparentAuth_Object.h"


// Common Crypto
#import <CommonCrypto/CommonKeyDerivation.h>
#import <CommonCrypto/CommonCryptor.h>




@interface BECrypto : NSObject

// Singleton instance
+ (id)sharedCrypto;

/*!
 *  AES POD properties defined to reduce multiple alloc/init for repeated encrypt/decrypt/hashing
 */

// User Derivation Functions
- (NSData *)getUserKeyForPassword:(NSString *)password withError:(NSError **)error;

// User Decryption Functions
- (NSData *)decryptMasterKeyUsingUserKey:(NSData *)userPBKDF2Key withError:(NSError **)error;

// Biometric Decryption Functions
- (NSData *)decryptMasterKeyUsingBiometricKey:(NSData *)userPBKDF2Key withError:(NSError **)error;


// User Creation Functions
- (NSString *)provisionNewUserKeyAndCreateMasterKeyWithPassword:(NSString *)userPassword withError:(NSError **)error;
- (BOOL)updateUserKeyForExistingMasterKeyWithPassword:(NSString *)userPassword withDecryptedMasterKey:(NSData *)masterKey withError:(NSError **)error;

// Biometric creations and update functions
- (BOOL)updateBiometricForExistingMasterKeyWithBiometricPassword:(NSString *)biometricPassword withDecryptedMasterKey:(NSData *)masterKey withError:(NSError **)error;



// Transparent Derivation Function
- (NSData *)getTransparentKeyForTrustFactorOutput:(NSString *)output withError:(NSError **)error;

// Transparent Decryption Functions
- (NSData *)decryptMasterKeyUsingTransparentAuthenticationWithError:(NSError **)error;

// Transparent Creation Functions
- (BETransparentAuth_Object *)createNewTransparentAuthKeyObjectWithError:(NSError **)error;

// Hashing Helper Functions
- (NSString *)createSHA1HashOfData:(NSData *)inputData withError:(NSError **)error;
- (NSString *)createSHA1HashofString:(NSString *)inputString withError:(NSError **)error;

// Data Conversion Helper Functions
- (NSString *)convertDataToHexString:(NSData *)inputData withError:(NSError **)error;
- (NSData *)convertHexStringToData:(NSString *)inputString withError:(NSError **)error;

// Key Derivation Helper Functions
- (NSData *)createPBKDF2KeyFromString:(NSString *)plaintextString withSaltData:(NSData *)saltString withRounds:(int)rounds withError:(NSError **)error;
- (int)benchmarkPBKDF2UsingExampleString:(NSString *)exampleString forTimeInMS:(int)time withError:(NSError **)error;

// Decryption Helper Functions
- (NSData *)decryptString:(NSString *)encryptedDataString withDerivedKeyData:(NSData *)keyData withSaltString:(NSString *)saltString withError:(NSError **)error;

// Encryption Helper Functions
- (NSString *)encryptData:(NSData *)plaintextData withDerivedKey:(NSData *)keyData withSaltData:(NSData *)saltData withError:(NSError **)error;

// Salt and key generation
- (NSData *)generateSalt256;

@end
