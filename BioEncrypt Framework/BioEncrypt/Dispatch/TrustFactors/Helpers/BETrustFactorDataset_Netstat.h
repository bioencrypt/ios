//
//  SystemMonitor.h
//  SystemMonitor
//
//  Created by Ren, Alice on 7/24/14.
//
//

#import <Foundation/Foundation.h>
//#import "otherHeaders.h"

@interface BETrustFactorDataset_Netstat : NSObject

// TCP connections
+ (NSArray *) getTCPConnections;

// Interface size
+ (NSDictionary *)getInterfaceBytes;

@end
