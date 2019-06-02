//
//  BEPolicy.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//

#import "BEPolicy.h"

@implementation BEPolicy


#pragma mark - Override setters


// Policy ID
- (void)setPolicyID:(NSString *)policyID{
    _policyID = policyID;
}


// Debug
- (void)setDebugEnabled:(NSNumber *)debugEnabled{
    _debugEnabled = debugEnabled;
}

// TransparentAuthDecayMetric
- (void)setTransparentAuthDecayMetric:(NSNumber *)transparentAuthDecayMetric{
    _transparentAuthDecayMetric = transparentAuthDecayMetric;
}


// Revision
- (void)setRevision:(NSNumber *)revision{
    _revision = revision;
}

// Revision
- (void)setContinueOnError:(NSNumber *)continueOnError{
    _continueOnError = continueOnError;
}

// Private APIs
- (void)setAllowPrivateAPIs:(NSNumber *)allowPrivateAPIs{
    _allowPrivateAPIs = allowPrivateAPIs;
}

// SystemThreshold
- (void)setSystemThreshold:(NSNumber *)systemThreshold{
    _systemThreshold = systemThreshold;
}

// ContactPhone
- (void)setContactPhone:(NSString *)contactPhone{
    _contactPhone  = contactPhone;
}

// ContactURL
- (void)setContactURL:(NSString *)contactURL{
    _contactURL = contactURL;
}

// ContactEmail
- (void)setContactEmail:(NSString *)contactEmail{
    _contactEmail = contactEmail;
}

// DNEModifiers
- (void)setDNEModifiers:(BEDNEModifiers *)DNEModifiers{
    _DNEModifiers = DNEModifiers;
}

// Authentication Modules
- (void)setAuthenticationModules:(NSArray *)authenticationModules{
    _authenticationModules = authenticationModules;
}

// Classifications
- (void)setClassifications:(NSArray *)classifications{
    _classifications = classifications;
}

// Subclassifications
- (void)setSubclassifications:(NSArray *)subclassifications{
    _subclassifications = subclassifications;
}

// TrustFactors
- (void)setTrustFactors:(NSArray *)trustFactors{
    _trustFactors = trustFactors;
}

// Status Upload Run Frequency
- (void) setStatusUploadRunFrequency:(NSNumber *)statusUploadRunFrequency {
    _statusUploadRunFrequency = statusUploadRunFrequency;
}

// Status Upload Time Frequency
- (void) setStatusUploadTimeFrequency:(NSNumber *)statusUploadTimeFrequency {
    _statusUploadTimeFrequency = statusUploadTimeFrequency;
}

//password requirements
- (void) setPasswordRequirements:(NSDictionary *)passwordRequirements {
    _passwordRequirements = passwordRequirements;
}

- (void) setApplicationVersionID:(NSString *)applicationVersionID {
    _applicationVersionID = applicationVersionID;
}

- (void) setUseDefaultAsBackup:(NSNumber *)useDefaultAsBackup {
    _useDefaultAsBackup = useDefaultAsBackup;
}


// about, support and privacy
- (void) setAbout:(NSDictionary *)about {
    _about = about;
}

- (void) setPrivacy:(NSDictionary *)privacy {
    _privacy = privacy;
}

- (void) setWelcome:(NSDictionary *)welcome {
    _welcome = welcome;
}

@end
