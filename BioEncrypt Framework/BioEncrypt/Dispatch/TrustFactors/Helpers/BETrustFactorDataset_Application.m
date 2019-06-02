 //
//  BETrustFactorDataset_Application.m
//  BioEncrypt
//
//

#import "BETrustFactorDataset_Application.h"
#include <objc/runtime.h>

//
// Private headers
//
//#import "LSApplicationWorkspace.h"
//#import "LSApplicationProxy.h"

@implementation BETrustFactorDataset_Application : NSObject

// USES PRIVATE API
+ (NSArray *)getUserAppInfo {
    
    
    
        // Get the list of processes and all information about them
        @try {
            //TODO: Check this URL out for obfuscation info on LSApplication stuff
            // https://github.com/neerajDamle/iOSApplicationBrowser/blob/5a2fcca7f1e0c4ed8dc35174d36638ab41daa325/iOSAppBrowser/iOSAppBrowser/AppList/BrowseAllInstalledApplication.m
            ////App types:
            //// $_LSUserApplicationType
            //// $_LSInternalApplicationType
            //// $_LSSystemApplicationType
            
            //_ApplicationType appType = $_LSUserApplicationType;
            
            ////This originally objc_getClass() LSApplicationWorkspace
            ////I broke up the string and added (__bridge void *) but now the API call returns nothing
            
            //NSString *appClass = [NSString stringWithFormat:@"%@%@%@", @"LSA", @"pplication", @"Workspace"];
            //NSArray* apps = [[NSClassFromString(appClass) defaultWorkspace] applicationsOfType:appType];
            
            //apps = [apps filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(LSApplicationProxy *evaluatedObject, NSDictionary *bindings)
                //{
                        //return [evaluatedObject localizedShortName].length > 0;
                //}]];
            
            //NSMutableArray* userApps = [NSMutableArray array];

            //for (LSApplicationProxy* application in apps)
            //{
                
                //// Create an array of the objects
                //NSArray *ItemArray = [NSArray arrayWithObjects:[application localizedShortName],[application bundleIdentifier], [application bundleVersion], nil];
    
                //// Create an array of keys
                //NSArray *KeyArray = [NSArray arrayWithObjects:@"name", @"bundleID", @"bundleVersion", nil];
                
                //// Create the dictionary
                //NSDictionary *dict = [[NSDictionary alloc] initWithObjects:ItemArray forKeys:KeyArray];
                
                //// Add the objects to the array
                //[userApps addObject:dict];

            //}
            
            //return userApps;
            return nil;
        }
        @catch (NSException * ex) {
            // Error
            return nil;
        }
}

@end
