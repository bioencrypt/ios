//
//  BEPolicy.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//

#import <Foundation/Foundation.h>
#import "BEDNEModifiers.h"

@interface BEPolicy : NSObject

@property (nonatomic,retain) NSString *policyID;
@property (nonatomic,retain) NSNumber *debugEnabled;
@property (nonatomic,retain) NSNumber *transparentAuthDecayMetric;
@property (nonatomic,retain) NSNumber *revision;
@property (nonatomic,retain) NSNumber *systemThreshold;
@property (nonatomic,retain) NSNumber *minimumTransparentAuthEntropy;
@property (nonatomic,retain) NSNumber *continueOnError;
@property (nonatomic,retain) NSNumber *timeout;
@property (nonatomic,retain) NSString *contactURL;
@property (nonatomic,retain) NSString *contactPhone;
@property (nonatomic,retain) NSString *contactEmail;
@property (nonatomic,retain) NSNumber *allowPrivateAPIs;
@property (nonatomic,retain) BEDNEModifiers *DNEModifiers;
@property (nonatomic,retain) NSArray *authenticationModules;
@property (nonatomic,retain) NSArray *classifications;
@property (nonatomic,retain) NSArray *subclassifications;
@property (nonatomic,retain) NSArray *trustFactors;
@property (nonatomic,retain) NSNumber *statusUploadRunFrequency;
@property (nonatomic,retain) NSNumber *statusUploadTimeFrequency;
@property (nonatomic,retain) NSDictionary *passwordRequirements;
@property (nonatomic, strong) NSString *applicationVersionID;
@property (nonatomic, strong) NSNumber *useDefaultAsBackup;

@property (nonatomic, strong) NSDictionary *privacy;
@property (nonatomic, strong) NSDictionary *about;
@property (nonatomic, strong) NSDictionary *welcome;


@end
