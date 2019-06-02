//
//  BETrustScoreComputation.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>
#import "BEPolicy.h"
#import "BEClassification.h"


// Authentication Modules
#import "BEAuthentication.h"

// Startup
#import "BETransparentAuth_Object.h"

#import "BELoginResponse_Object.h"


@interface BETrustScoreComputation : NSObject

#pragma mark - Debug

// Tracking not learned
@property (nonatomic) NSArray *userTrustFactorsNotLearned;
@property (nonatomic) NSArray *systemTrustFactorsNotLearned;

// Tracking triggered rules
@property (nonatomic) NSArray *userTrustFactorsAttributingToScore;
@property (nonatomic) NSArray *systemTrustFactorsAttributingToScore;

// Tracking errors
@property (nonatomic) NSArray *userTrustFactorsWithErrors;
@property (nonatomic) NSArray *systemTrustFactorsWithErrors;

// All Output
@property (nonatomic) NSArray *userAllTrustFactorOutputObjects;
@property (nonatomic) NSArray *systemAllTrustFactorOutputObjects;


#pragma mark - Classification Types

//@property (nonatomic) BEPolicy *policy;

// After we figure out what classification is which we assign them here in order to map protect mode actions

@property (nonatomic) BEClassification *systemBreachClass;
@property (nonatomic) BEClassification *systemPolicyClass;
@property (nonatomic) BEClassification *systemSecurityClass;
@property (nonatomic) BEClassification *userAnomalyClass;
@property (nonatomic) BEClassification *userPolicyClass;

#pragma mark - Classification Scores

// System Breach
@property (nonatomic) int systemBreachScore;

// Device Policy Violation
@property (nonatomic) int systemPolicyScore;

// System Security (Anomaly)
@property (nonatomic) int systemSecurityScore;

// User Policy Violation
@property (nonatomic) int userPolicyScore;

// User Anomaly
@property (nonatomic) int userAnomalyScore;



#pragma mark - Composite System Score

// Dashboard Text
@property (nonatomic) NSString* dashboardText;

// System Score
@property (nonatomic) int systemScore;

// System Trusted
@property (nonatomic) BOOL systemTrusted;

// System subClassResultObjects
@property (nonatomic) NSArray *systemSubClassResultObjects;

// System Issue Messages
@property (nonatomic) NSArray *systemIssues;

// System Suggestion Messages
@property (nonatomic) NSArray *systemSuggestions;

#pragma mark - Composite User Score

// User Score
@property (nonatomic) int userScore;

// User Trusted
@property (nonatomic) BOOL userTrusted;

// User subClassResultObjects
@property (nonatomic) NSArray *userSubClassResultObjects;

// User Issue Messages
@property (nonatomic) NSArray *userIssues;

// User Suggestion Messages
@property (nonatomic) NSArray *userSuggestions;




#pragma mark - Composite Device Score

// Device Score
@property (nonatomic) int deviceScore;

// device Trusted
@property (nonatomic) BOOL  deviceTrusted;



#pragma mark - Core Detection Results and Action Code

// Classification responsible for causing protect mode
@property (nonatomic) NSInteger attributingClassID;

// Set warn title/desc here such that it can be pulled from classifications or auth modules if the attributing is user anomaly
@property (nonatomic) NSString *warnTitle;
@property (nonatomic) NSString *warnDesc;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger authenticationAction;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger postAuthenticationAction;

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger coreDetectionResult;


#pragma mark - Authentication Results and Action Code

// Action to take (e.g., prompt user or admin pin)
@property (nonatomic) NSInteger authenticationResult;

// User Authentication Method Attempted to be used
@property (nonatomic) BEAuthentication* authenticationModuleEmployed;

#pragma mark - Crypto

// Decrypted master key, only populated after a pre authentication action
@property (nonatomic) NSData* decryptedMasterKey;


#pragma mark - login response

@property (nonatomic, strong) BELoginResponse_Object *loginResponseObject;


#pragma mark - Core Detection Whitelists


// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *userTrustFactorWhitelist;

// Holds the trustFactorOutputObjects to whitelist during protect mode deactivation
@property (nonatomic) NSArray *systemTrustFactorWhitelist;



#pragma mark - Transparent Authentication

// Holds the trustFactorOutputObjects for use in transparent authentication
@property (nonatomic) NSArray *transparentAuthenticationTrustFactorOutputObjects;

// Transparent authentication result
@property (nonatomic) NSInteger  transparentAuthenticationAction;

// Transparent authentication high entropy rule count
@property (nonatomic) NSInteger  entropyCount;

// Found a matching stored transparent key
@property (nonatomic) BOOL  foundTransparentMatch;

// Identified matching transparent auth master key data to be decrypted later (only present if transparent auth was attempted)

@property (nonatomic) BETransparentAuth_Object* matchingTransparentAuthenticationObject;

// Candidate Transparent Auth materials temporarily stored if transparent authentication attempt failed and user must provide password
// This is then used to create a new transparent auth key
@property (nonatomic) NSData* candidateTransparentKey;

// Candidate key after raw output was feed through PBKDF2 and reduced in size through SHA1

@property (nonatomic) NSString* candidateTransparentKeyHashString;


// Compute the systemScore and the UserScore from the trust scores and the assertion storage objects
+ (instancetype)performTrustFactorComputationWithPolicy:(BEPolicy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorAssertions withError:(NSError **)error;

@end
