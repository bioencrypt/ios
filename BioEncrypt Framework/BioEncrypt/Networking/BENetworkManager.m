//
//  BENetworkManager.m
//  BioEncrypt
//
//  Created by Ivo Leko on 08/04/16.
//

#import "BENetworkManager.h"
#import "BEHTTPSessionManager.h"
#import "BEStartupStore.h"
#import "BEPolicyParser.h"
#import "BEStartup.h"
#import "NSObject+ObjectMap.h"
#import <sys/utsname.h>


@interface BENetworkManager()
@property (nonatomic, strong) BEHTTPSessionManager *sessionManager;

@end

@implementation BENetworkManager

+ (BENetworkManager *) shared {
    static BENetworkManager* _shared_Network_Manager = nil;
    static dispatch_once_t onceToken_Network_Manager;
    
    dispatch_once(&onceToken_Network_Manager, ^{
        _shared_Network_Manager = [[BENetworkManager alloc] init];
        
        //create our session manager based on AFNetworking
        _shared_Network_Manager.sessionManager = [[BEHTTPSessionManager alloc] init];
        
    });
    
    return _shared_Network_Manager;
}

- (NSString *) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}


- (void) checkForNewPolicyWithEmail: (NSString *) email withCallback: (CheckPolicyBlock) callback {
    NSError *error;
    
    //get current startup
    BEStartup *currentStartup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, error);
        return;
    }

    
    //get current policy
    BEPolicy *currentPolicy = [[BEPolicyParser sharedPolicy] getPolicy:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, error);
        return;
    }
    
    // prepare dictionary (JSON) for sending
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    // Get app version
    NSString * currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    // Get platform
    // platform 0 = iOS
    NSNumber *platform = [NSNumber numberWithInt:0];
    
    /*
     Prepare POST parameters
     */
    [dic setObject:currentPolicy.policyID forKey:@"current_policy_id"];
    [dic setObject:currentPolicy.revision forKey:@"current_policy_revision"];
    [dic setObject:platform forKey:@"platform"];
    [dic setObject:email forKey:@"user_activation_id"];
    [dic setObject:@[] forKey:@"run_history_objects"]; //empty array
    [dic setObject:currentStartup.deviceSaltString forKey:@"device_salt"];
    [dic setObject:[self deviceName] forKey:@"phone_model"];
    [dic setObject:currentVersion forKey:@"app_version"];
    
     [self.sessionManager uploadReport:dic withCallback:^(BOOL success, id responseObject, NSError *error) {
         if (error) {
             callback (NO, NO, NO, error);
         }
         else {
             NSDictionary *newPolicy = responseObject[@"data"][@"newPolicy"];
             BOOL policyOrganisationExist = [responseObject[@"data"][@"policyOrganizationExists"] boolValue];
             
             if (newPolicy && ![newPolicy isEqual:[NSNull null]]) {
                 
                 
                 // new policy exists, need to replace old policy with this one
                 BEPolicy *policy = [[BEPolicyParser sharedPolicy] parsePolicyJSONobject:newPolicy withError:&error];
                 
                 if (error) {
                     //something went wrong...
                     if (callback)
                         callback (NO, NO, NO, error);
                     
                     return;
                 }
                 
                 // save new policy
                 [[BEPolicyParser sharedPolicy] saveNewPolicy:policy withError:&error];

                 
                 if (error) {
                     //something went wrong...
                     if (callback)
                         callback (NO, NO, NO, error);
                     
                     return;
                 }
                 
                 //everything succesfull
                 if (callback) {
                     //we can use private api
                     if ([policy.allowPrivateAPIs intValue]==1) {
                         [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"allowPrivate"];
                         [[NSUserDefaults standardUserDefaults] synchronize];
                     }
                     
                     callback (YES, YES, policyOrganisationExist, nil);
                 }
                 
             }
             else {
                 //no new policy
                 callback (YES, NO, policyOrganisationExist, nil);
             }
         }
     }];
}


- (void) uploadRunHistoryObjectsAndCheckForNewPolicyWithCallback: (RunHistoryBlock) callback {
    
    NSError *error;
    
    //get current startup
    BEStartup *currentStartup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, NO, error);
        return;
    }
    
    //get current policy
    BEPolicy *currentPolicy = [[BEPolicyParser sharedPolicy] getPolicy:&error];
    
    //if any error, stop it
    if (error) {
        if (callback)
            callback(NO, NO, NO, NO, error);
        return;
    }
    
    //check if any runHistoryObjects exists (for example, it will be 0 if running app for the first time)
    /*
    if (currentStartup.runHistoryObjects.count == 0) {
        if (callback)
            callback(YES, NO, NO, nil);
        return;
    }
    */
    
    //get current runCount, because it can be changed while waiting for server response
    NSInteger runCount = currentStartup.runCount;
    
    
    BOOL needToUploadData = false;
    
    // check if run count from last upload is higher/equal than defined upload run frequency in policy
    if (currentPolicy.statusUploadRunFrequency.integerValue
        <= (runCount - currentStartup.runCountAtLastUpload)) {
        needToUploadData = YES;
    }
    
    // check if delta time from last upload is higher than time defined in policy. If this is first upload, it will also proceed.
    else if ((currentPolicy.statusUploadTimeFrequency.integerValue * 86400.0)
        <= ([[NSDate date] timeIntervalSince1970] - [currentStartup dateTimeOfLastUpload])) {
        needToUploadData = YES;
    }
        
    
    if (needToUploadData) {
        
        //get JSONObject of entire startup (needed later)
        id currentStartupJSONobject = [NSJSONSerialization JSONObjectWithData:[currentStartup JSONData] options:kNilOptions error:nil];
        
        // prepare dictionary (JSON) for sending
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        //need to add history objects
        NSArray *oldRunHistoryObjects = [NSArray arrayWithArray: currentStartup.runHistoryObjects];
        
        
        //get email
        NSString *email = currentStartup.email;
        if (!email)
            email = @"";
        
        // Get app version
        NSString * currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        
        // Get platform
        // platform 0 = iOS
        NSNumber *platform = [NSNumber numberWithInt:0];
        
        
        /*
         Prepare POST parameters
         */
        
        [dic setObject:currentPolicy.policyID forKey:@"current_policy_id"];
        [dic setObject:currentPolicy.revision forKey:@"current_policy_revision"];
        [dic setObject:platform forKey:@"platform"];
        [dic setObject:email forKey:@"user_activation_id"];
        [dic setObject:currentStartupJSONobject[@"runHistoryObjects"] forKey:@"run_history_objects"];
        [dic setObject:currentStartup.deviceSaltString forKey:@"device_salt"];
        [dic setObject:[self deviceName] forKey:@"phone_model"];
        [dic setObject:currentVersion forKey:@"app_version"];
        
        

        [self.sessionManager uploadReport:dic withCallback:^(BOOL success, NSDictionary *responseObject, NSError *error) {
            if (!success) {
                //request failed
                if (callback)
                    callback (NO, NO, NO, NO, error);
            }
            else {
                
                BOOL policyOrganisationExist = [responseObject[@"data"][@"policyOrganizationExists"] boolValue];

                //succesfully uploaded, need to update status variables
                currentStartup.dateTimeOfLastUpload = [[NSDate date] timeIntervalSince1970];
                currentStartup.runCountAtLastUpload = runCount;
                
                //need to remove old run history objects
                [self removeOldRunHistoryObjects:oldRunHistoryObjects fromStartup:currentStartup];
                
                
                NSDictionary *newPolicy = responseObject[@"data"][@"newPolicy"];
                if (newPolicy && ![newPolicy isEqual:[NSNull null]]) {
                    
                    // new policy exists, need to replace old policy with this one
                    BEPolicy *policy = [[BEPolicyParser sharedPolicy] parsePolicyJSONobject:newPolicy withError:&error];
                    
                    if (error) {
                        //something went wrong...
                        if (callback)
                            callback (NO, YES, NO, NO, error);
                        
                        return;
                    }
                    
                    // save new policy
                    [[BEPolicyParser sharedPolicy] saveNewPolicy:policy withError:&error];
                    
                    if (error) {
                        //something went wrong...
                        if (callback)
                            callback (NO, YES, NO, NO, error);
                        
                        return;
                    }
                    
                    //everything succesfull
                    if (callback) {
                        //if we got new policy that specified we should use private APIs set new flag to NSUserDefaults
                        if ([policy.allowPrivateAPIs intValue]==1) {
                            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"allowPrivate"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        
                        callback (YES, YES, YES, policyOrganisationExist, nil);
                    }
                }
                else {
                    //succesfully uploaded, but there is no new policy
                    if (callback)
                        callback (YES, YES, NO, policyOrganisationExist, nil);
                }
            }
        }];
    }
    else {
        // do not need to upload
        if (callback)
            callback (YES, NO, NO, NO, nil);
    }
}

- (void) removeOldRunHistoryObjects: (NSArray *) oldRunHistoryObjects fromStartup: (BEStartup *) startup  {
    
    //current runHistoryObjects
    NSMutableArray *currentRunHistoryObjects = [NSMutableArray arrayWithArray: startup.runHistoryObjects];
   
    //remove old objects (that are already sent) from array
    [currentRunHistoryObjects removeObjectsInArray:oldRunHistoryObjects];
    
    startup.runHistoryObjects = [NSArray arrayWithArray:currentRunHistoryObjects];
}

@end
