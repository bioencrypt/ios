//
//  BEHTTPSessionManager.h
//  BioEncrypt
//
//  Created by Ivo Leko on 07/04/16.
//

#import "AFNetworking.h"

typedef void (^NetworkBlock)(BOOL success, id responseObject, NSError *error);


@class BEStartup;
@class BEPolicy;


//subclass of the main AFNetworking manager class
@interface BEHTTPSessionManager : AFHTTPSessionManager

- (id) init;

// upload startup file to the server and download new policy
- (void) uploadReport:(NSDictionary *) parameters withCallback: (NetworkBlock) callback;



@end
