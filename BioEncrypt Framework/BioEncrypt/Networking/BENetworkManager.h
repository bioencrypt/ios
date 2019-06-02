//
//  BENetworkManager.h
//  BioEncrypt
//
//  Created by Ivo Leko on 08/04/16.
//

#import <Foundation/Foundation.h>

typedef void (^RunHistoryBlock)(BOOL successfullyExecuted, BOOL successfullyUploaded, BOOL newPolicyDownloaded, BOOL policyOrganisationExists, NSError *error);
typedef void (^CheckPolicyBlock)(BOOL successfullyExecuted, BOOL newPolicyDownloaded, BOOL policyOrganisationExists, NSError *error);


@interface BENetworkManager : NSObject

+ (BENetworkManager *) shared;

- (void) uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback: (RunHistoryBlock) callback;
- (void) checkForNewPolicyWithEmail: (NSString *) email  withCallback: (CheckPolicyBlock) callback;

@end
