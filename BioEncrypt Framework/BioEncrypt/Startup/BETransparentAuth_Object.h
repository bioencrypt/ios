//
//  BETrustFactorDatasets.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

@interface BETransparentAuth_Object : NSObject

// Transparent Key Hash
@property (nonatomic, strong) NSString* transparentKeyPBKDF2HashString;

// User Password Encrypted Master Key IV
@property (nonatomic, strong) NSString* transparentKeyEncryptedMasterKeyBlobString;

// User Password Encrypted Master Key Blob
@property (nonatomic, strong) NSString* transparentKeyEncryptedMasterKeySaltString;

// Hit Counter
@property (atomic,strong) NSNumber *hitCount;

// Date and Time of last hit
@property (atomic,strong) NSNumber *lastTime;

// Date and Time first created
@property (atomic,strong) NSNumber *created;

// How many time to learn from
@property (atomic) double decayMetric;


@end
