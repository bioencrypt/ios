//
//  BETrustFactorDispatch_File.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch File is a rule that checks for bad files that may have been added to the device
 *  of the user in addition to size changes that are out of the ordinary
 */
#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_File : NSObject 

// Check for bad files
+ (BETrustFactorOutputObject *)blacklisted:(NSArray *)payload;

// File size change check
+ (BETrustFactorOutputObject *)sizeChange:(NSArray *)payload;

@end
