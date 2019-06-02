//
//  BETrustFactorDataset_StatusBar.m
//  BioEncrypt
//
//

#import "BETrustFactorDataset_StatusBar.h"
#import <UIKit/UIKit.h>
@import AVFoundation;

@implementation BETrustFactorDataset_StatusBar

// USES PRIVATE API
+ (NSDictionary *)getStatusBarInfo {
    
        // Get the list of processes and all information about them
        @try {

            // Set datapoint variables
            NSNumber *wifiSignal = [NSNumber numberWithInt:0];
            NSNumber *cellSignal = [NSNumber numberWithInt:0];
            NSNumber *isTethering = [NSNumber numberWithInt:0];
            NSNumber *isAirplaneMode = [NSNumber numberWithInt:0];
            NSNumber *isBackingUp = [NSNumber numberWithInt:0];
            NSString *cellServiceString = @"";
            NSString *lastApp = @"";
            NSNumber *isOnCall = [NSNumber numberWithInt:0];
            NSNumber *isNavigating = [NSNumber numberWithInt:0];
            NSNumber *isUsingYourLocation = [NSNumber numberWithInt:0];
            NSNumber *doNotDisturb = [NSNumber numberWithInt:0];
            NSNumber *orientationLock = [NSNumber numberWithInt:0];

            //avoid calling status bar if were not allowing private APIs
            NSNumber *allowPrivate = [[NSUserDefaults standardUserDefaults] objectForKey:@"allowPrivate"];
            if (allowPrivate == nil || allowPrivate.boolValue == NO) {
                //do nothing
            }
            else {
                // Get the main status Bar
                UIView* statusBarForegroundView;
                NSString *statusBarString = [NSString stringWithFormat:@"%@ar", @"_statusB"];
                UIView* statusBar = [[UIApplication sharedApplication] valueForKey:statusBarString];
                
                for (UIView* view in statusBar.subviews)
                {
                    if ([view isKindOfClass:NSClassFromString(@"UIStatusBarForegroundView")])
                    {
                        statusBarForegroundView = view;
                        break;
                    }
                }
                
                // Status bar strings (split for security)
                
                // WiFi
                NSString *WiFiClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"DataNet", @"workItemView"]; //Orig: UIStatusBarDataNetworkItemView
                NSString *WiFiKey = [NSString stringWithFormat:@"%@%@", @"_wifiStre", @"ngthRaw"]; //Orig: _wifiStrengthRaw
                
                // Cell Signal
                NSString *cellClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"SignalStr", @"engthItemView"]; //Orig: UIStatusBarSignalStrengthItemView
                NSString *cellKey = [NSString stringWithFormat:@"%@%@", @"_signalStre", @"ngthRaw"]; //Orig: _signalStrengthRaw
                
                // Airplane mode status
                NSString *airplaneClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Airplane", @"ModeItemView"]; //Orig: UIStatusBarAirplaneModeItemView
                
                // Syncing
                NSString *syncingClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Activity", @"ItemView"]; //Orig: UIStatusBarActivityItemView
                NSString *syncingKey = [NSString stringWithFormat:@"%@%@", @"_sync", @"Activity"]; //Orig: _syncActivity
                
                // Carrier service
                NSString *serviceProviderClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Service", @"ItemView"]; //Orig: UIStatusBarServiceItemView
                NSString *serviceProviderKey = [NSString stringWithFormat:@"%@%@", @"_service", @"String"]; //Orig: _serviceString
                
                // Last app
                NSString *lastAppClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Breadcrumb", @"ItemView"]; //Orig: UIStatusBarBreadcrumbItemView
                NSString *lastAppKey = [NSString stringWithFormat:@"%@%@", @"_destination", @"Text"];
                
                // Do not disturb
                NSString *quietModeClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Quiet", @"ModeItemView"]; //Orig: UIStatusBarQuietModeItemView
                
                // Portrait orientation lock
                NSString *indicatorClass = [NSString stringWithFormat:@"%@%@%@%@", @"UIStatus", @"Bar", @"Indicator", @"ItemView"]; //Orig: UIStatusBarIndicatorItemView
                
                // Check for tethering
                NSString *doubleHeightKey = [NSString stringWithFormat:@"%@%@", @"_currentDouble", @"HeightText"]; //Orig: _currentDoubleHeightText
                
                
                // Get necessary values from status bar
                for (UIView* view in statusBarForegroundView.subviews)
                {
                    // Wifi Signal
                    if ([view isKindOfClass:NSClassFromString(WiFiClass)]) {
                        wifiSignal = [NSNumber numberWithInt:[[view valueForKey:WiFiKey] intValue]];
                    }
                    
                    // Cell Signal
                    else if ([view isKindOfClass:NSClassFromString(cellClass)]) {
                        cellSignal = [NSNumber numberWithInt:[[view valueForKey:cellKey] intValue]];
                    }
                    
                    // Airplane mode status
                    else if ([view isKindOfClass:NSClassFromString(airplaneClass)]) {
                        isAirplaneMode=[NSNumber numberWithInt:1];
                    }
                    
                    // If syncing
                    else if ([view isKindOfClass:NSClassFromString(syncingClass)]) {
                        
                        if((BOOL)[view valueForKey:syncingKey] == TRUE) {
                            isBackingUp=[NSNumber numberWithInt:1];
                        }
                    }
                    
                    // Which service
                    else if ([view isKindOfClass:NSClassFromString(serviceProviderClass)]) {
                        cellServiceString = (NSString *)[view valueForKey:serviceProviderKey];
                    }
                    
                    
                    // Last app
                    else if ([view isKindOfClass:NSClassFromString(lastAppClass)]) {
                        lastApp = (NSString *)[view valueForKey:lastAppKey];
                    }
                    
                    // Do not disturb
                    else if ([view isKindOfClass:NSClassFromString(quietModeClass)]) {
                        doNotDisturb = [NSNumber numberWithInt:1];
                    }
                    
                    // Portrait orientation lock
                    else if ([view isKindOfClass:NSClassFromString(indicatorClass)]) {
                        if ([[[view valueForKey:@"_item"] valueForKey:@"indicatorName"] isEqualToString:@"RotationLock"])
                            orientationLock = [NSNumber numberWithInt:1];
                    }
                    
                }
                
                // Check for tethering
                
                NSString *text = [statusBar valueForKey:doubleHeightKey];
                if([text containsString:@"Hotspot"]){
                    
                    isTethering = [NSNumber numberWithInt:1];
                } // Check for in-call
                else if([text containsString:@"return to call"]){
                    
                    isOnCall = [NSNumber numberWithInt:1];
                } // Check for navigation
                else if([text containsString:@"return to Navigation"]){
                    
                    isNavigating = [NSNumber numberWithInt:1];
                }
                else if ([text containsString:@"is Using Your Location"]){
                    
                    isUsingYourLocation = [NSNumber numberWithInt:1];
                }
                
                // Temp for testing
                //TODO: Unused: BOOL isOtherAudioPlaying = [[AVAudioSession sharedInstance] isOtherAudioPlaying];
            }
            
            
            
            
            // Create the dictionary
            NSDictionary *dict = @{
                                   @"wifiSignal"            : wifiSignal,
                                   @"cellSignal"            : cellSignal,
                                   @"isTethering"           : isTethering,
                                   @"isAirplaneMode"        : isAirplaneMode,
                                   @"isBackingUp"           : isBackingUp,
                                   @"cellServiceString"     : cellServiceString,
                                   @"lastApp"               : lastApp,
                                   @"isOnCall"              : isOnCall,
                                   @"isNavigating"          : isNavigating,
                                   @"isUsingYourLocation"   : isUsingYourLocation,
                                   @"doNotDisturb"          : doNotDisturb,
                                   @"orientationLock"       : orientationLock
                                   };
            
            
            return dict;
        }
    
        @catch (NSException * ex) {
            // Error
            return nil;
        }
   
}


@end
