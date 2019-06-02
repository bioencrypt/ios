//
//  ActiveConnection.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ActiveConnection : NSObject
@property (nonatomic, copy) NSString              *localIP;
@property (nonatomic, copy) NSNumber             *localPort;
@property (nonatomic, copy) NSString              *localPortService;

@property (nonatomic, copy) NSString              *remoteIP;
@property (nonatomic, copy) NSString              *remoteHost;
@property (nonatomic, copy) NSNumber              *remotePort;
@property (nonatomic, copy) NSString              *remotePortService;


@property (nonatomic, copy) NSString                *status;

@property (nonatomic, assign) CGFloat               totalTX;
@property (nonatomic, assign) CGFloat               totalRX;
@end
