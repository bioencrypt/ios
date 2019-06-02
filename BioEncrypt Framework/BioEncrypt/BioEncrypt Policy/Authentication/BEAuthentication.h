//
//  BEAuthentication.h
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//

#import <Foundation/Foundation.h>

@interface BEAuthentication : NSObject


@property (nonatomic,retain) NSNumber *identification;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *warnDesc;
@property (nonatomic,retain) NSString *warnTitle;
@property (nonatomic,retain) NSString *dashboardText;
@property (nonatomic,retain) NSNumber *activationRange;
@property (nonatomic,retain) NSNumber *authenticationAction;
@property (nonatomic,retain) NSNumber *postAuthenticationAction;


@end

