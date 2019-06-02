//
//  BioEncrypt.h
//  BioEncrypt
//
//  Created by Ivo Leko on 03/03/2019.
//

#import <UIKit/UIKit.h>

//! Project version number for BioEncrypt.
FOUNDATION_EXPORT double BioEncryptVersionNumber;

//! Project version string for BioEncrypt.
FOUNDATION_EXPORT const unsigned char BioEncryptVersionString[];


#import "BELocationPermissionRequest.h"
#import "BEActivityPermissionRequest.h"
#import "BEPermissionRequest.h"

// Constants
#import "BEConstants.h"

// Core Detection
#import "BECoreDetection.h"

// Policy
#import "BEPolicy.h"

// Did not execute modifiers
#import "BEDNEModifiers.h"

// Trustscore computation and information about the score
#import "BETrustScoreComputation.h"

// TrustFactor - Basically a rule that gets run
#import "BETrustFactor.h"

// TrustFactor Output Object - Assertion
#import "BETrustFactorOutputObject.h"

// TrustFactor Stored Object - Stored information about the assertion
#import "BEStoredTrustFactorObject.h"

#import "BESubClassResult_Object.h"

#import "BECrypto.h"

#import "BEStartup.h"
