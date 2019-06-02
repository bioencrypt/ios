//
//  BEHTTPSessionManager.m
//  BioEncrypt
//
//  Created by Ivo Leko on 07/04/16.
//

#import "BEHTTPSessionManager.h"
#import "BEStartup.h"
#import "BEPolicy.h"
#import "NSObject+ObjectMap.h"
#import "BEConstants.h"
#import "BEJSONResponseSerializer.h"




@implementation BEHTTPSessionManager

- (id) init {
    
    //define session configuration (some of the optional parameters are listed below)
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    //OPTIONAL: how long (in seconds) to wait for an entire resource to transfer before giving up (default: 7 days)
    //sessionConfiguration.timeoutIntervalForResource =
    
    //OPTIONAL: how long (in seconds) a task should wait for additional data to arrive before giving up (default 60 seconds)
    //sessionConfiguration.timeoutIntervalForRequest =
    
    //OPTIONAL: dictionary of additional headers that are added to all tasks
    //sessionConfiguration.HTTPAdditionalHeaders =
    
    
    //define baseURL
    NSURL *baseURL = [NSURL URLWithString:kBaseURLstring];
    
    //initialise our manager
    self = [super initWithBaseURL:baseURL sessionConfiguration:sessionConfiguration];
    
    //set our custom serialiser
    [self setResponseSerializer:[BEJSONResponseSerializer serializer]];
    
    
    if (self) {
        //call this to enable certificate pinning
        [self configureSecurityPolicy];
    }
    return self;
}


#pragma mark - private methods

// configuration for certificate pinning
- (void) configureSecurityPolicy {
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    
    //loading certificate from string
    NSData *certificateData_1 = [self dataOfPublicKeyCert];

    //possible to add mutliple certificates, currently only one
    securityPolicy.pinnedCertificates = [NSSet setWithObjects:certificateData_1, nil];
    securityPolicy.validatesDomainName = NO;
    
    //to allow self-signed certificates
    [securityPolicy setAllowInvalidCertificates:YES];
    
    self.securityPolicy = securityPolicy;
}


- (NSData *) dataOfPublicKeyCert {
    NSData *data = [NSData base64DataFromString:[self base64StringOfPublicKeyCert]];
    return data;
}

- (NSString *) base64StringOfPublicKeyCert {
    //base64 string of cer
    
    return
    @"";
}



#pragma mark - public methods

- (void) uploadReport:(NSDictionary *) parameters withCallback: (NetworkBlock) callback {
    
    //use this line to send HTTP request as POST JSON
    self.requestSerializer = [AFJSONRequestSerializer serializer];

    // relative path
    NSString *apiCall = @"api/check-in";
    
    
    [self POST:apiCall parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        callback(YES, responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"Error BEHTTPSession_Manager: %@\n%@", error.localizedDescription, error.userInfo);
        }
        else {
            //this should never happen (it would be some serious bug in AFNetworking)
            NSLog(@"Error BEHTTPSession_Manager: Undefined Network Error");
        }
        
        callback(NO, nil, error);
    }];
}







@end

