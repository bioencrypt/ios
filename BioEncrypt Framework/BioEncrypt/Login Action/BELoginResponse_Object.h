//
//  BETrustFactorDataset_Process.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

@interface BELoginResponse_Object : NSObject

// Device Score
@property (nonatomic, assign) NSInteger authenticationResponseCode;

// Trust Score
@property (nonatomic, retain) NSData *decryptedMasterKey;

// Trust Score
@property (nonatomic, retain) NSString *responseLoginTitle;

// User Score
@property (nonatomic, retain) NSString *responseLoginDescription;

@end
