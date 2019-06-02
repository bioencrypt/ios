//
//  BETrustFactorDatasets.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

@interface BEHistoryObject : NSObject

// Timestamp
@property (nonatomic, copy  ) NSDate    *timestamp;

// Violation Action
@property (nonatomic, assign) NSInteger preAuthenticationAction;

// Authentication  Action
@property (nonatomic, assign) NSInteger postAuthenticationAction;

// Core Detection Result
@property (nonatomic, assign) NSInteger coreDetectionResult;

// Core Detection Result
@property (nonatomic, assign) NSInteger authenticationResult;

// Device Score
@property (nonatomic, assign) NSInteger deviceScore;

// Trust Score
@property (nonatomic, assign) NSInteger trustScore;

// User Score
@property (nonatomic, assign) NSInteger userScore;

// User Issues
@property (nonatomic, strong) NSArray<NSString  *> *userIssues;

// System Issues
@property (nonatomic, strong) NSArray<NSString  *> *systemIssues;



@end
