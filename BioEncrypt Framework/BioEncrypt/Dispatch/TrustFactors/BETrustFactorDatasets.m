//
//  BETrustFactorDatasets.m
//  BioEncrypt
//
//

#import "BETrustFactorDatasets.h"

// These populate the datasets generated in this class which are not done in AppDelegate
#import "BETrustFactorDataset_Routes.h"
#import "BETrustFactorDataset_CPU.h"
#import "BETrustFactorDataset_Application.h"
#import "BETrustFactorDataset_Process.h"
#import "BETrustFactorDataset_Netstat.h"
#import "BETrustFactorDataset_Wifi.h"
#import "BETrustFactorDataset_Cell.h"
#import "BETrustFactorDataset_Motion.h"
#import "BETrustFactorDataset_StatusBar.h"
#import "BETrustFactorDataset_Config.h"

@implementation BETrustFactorDatasets

#pragma mark - Singleton Methods

// Singleton shared instance
static BETrustFactorDatasets *sharedTrustFactorDatasets = nil;
static dispatch_once_t onceToken;

+ (id)sharedDatasets {
    dispatch_once(&onceToken, ^{
        sharedTrustFactorDatasets = [[self alloc] init];
    });
    return sharedTrustFactorDatasets;
}

// Init (Defaults)
- (id)init {
    if (self = [super init]) {
        //Set epoch (runtime) to be used all over the place but consistent for the same run
        _runTimeEpoch = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

// Only used for demo re-run of core detection, otherwise the cached datasets are used
+ (void)selfDestruct {
    // TODO: Get rid of this crappy code (sorry Jason)
    
    // Don't just destroy the token, destroy the entire object
    sharedTrustFactorDatasets = nil;
    onceToken = 0;
}

#pragma mark - TrustFactors Implementation Helpers

// Share payload validation routine for TFs that should have payload items
- (BOOL)validatePayload:(NSArray *)payload {
    
    // Check if the payload is empty
    if (!payload || payload == nil || payload.count < 1) {
        return NO;
    }
    
    // Return Valid
    return YES;
}

#pragma mark - Dataset Helpers

// Device level password
- (NSNumber *)getPassword {
    
    // If dataset is not populated
    if(!self.hasPassword || self.hasPassword == nil) {
        
        // Get device moving info
        self.hasPassword = [BETrustFactorDataset_Config hasPassword];
        
        // Return moving info
        return self.hasPassword;
        
    } else {
        
        // Return moving info
        return self.hasPassword;
    }
}

// Statusbar Dictionary
- (NSDictionary *)getStatusBar {
    
    // When dataset is not populated
    if(!self.statusBar) {
        
        // Set self status bar
        self.statusBar = [BETrustFactorDataset_StatusBar getStatusBarInfo];
        
        // Set DNE if it errored
        if(self.statusBar == nil){
            self.statusBarDNEStatus = DNEStatus_error;
        }
        
        // Return status bar
        return self.statusBar;
        
    } else {
        
        // Return status bar
        return self.statusBar;
    }
}

// CPU usage
- (float)getCPUUsage {
    
    // When dataset is not populated
    if(!self.cpuUsage) {
        
        // Set self cpu usage
        self.cpuUsage = [BETrustFactorDataset_CPU getCPUUsage];
        
        // Return cpu usage
        return self.cpuUsage;
        
    } else {
        
        // Return cpu usage
        return self.cpuUsage;
    }
}

// Battery state
- (NSString *)getBatteryState {
    
    // If dataset isn't populated
    if(!self.batteryState || self.batteryState == nil) {
        
        // Set device to current device
        UIDevice *Device = [UIDevice currentDevice];
        
        // Enable battery monitoring
        Device.batteryMonitoringEnabled = YES;
        
        // Set battery state
        UIDeviceBatteryState battery = [Device batteryState];
        NSString* state;
        
        switch (battery) {
                
                // Plugged in, less than 100%
            case UIDeviceBatteryStateCharging:
                state = @"pluggedCharging";
                break;
                
                // Plugged in, at 100%
            case UIDeviceBatteryStateFull:
                state = @"pluggedFull";
                break;
                
                // On battery, discharging
            case UIDeviceBatteryStateUnplugged:
                state = @"unplugged";
                break;
                
                // Unknown state
            default:
                state = @"unknown";
                break;
        }
        
        // Set battery state
        self.batteryState = state;
        
        // Return battery state
        return self.batteryState;
        
    } else {
        
        // Return battery state
        return self.batteryState;
    }
}

// Device orientation
- (NSString *)getDeviceOrientation {
    
    // If dataset is not populated
    if(!self.deviceOrientation || self.deviceOrientation == nil) {
        
        // Get device orientation
        self.deviceOrientation = [BETrustFactorDataset_Motion orientation];
        
        // Return device orientation
        return self.deviceOrientation;
        
    } else {
        
        // Return device orientation
        return self.deviceOrientation;
    }
}

// Device orientation
- (NSNumber *)getGripMovement {
    
    // If dataset is not populated
    if(!self.gripMovement || self.gripMovement == nil) {
        
        // Get device moving info
        self.gripMovement = [BETrustFactorDataset_Motion gripMovement];
        
        // Return moving info
        return self.gripMovement;
        
    } else {
        
        // Return moving info
        return self.gripMovement;
    }
}

// User Movement
- (NSString *)getUserMovement {
    
    // If dataset is not populated
    if(!self.userMovement || self.userMovement == nil) {
        
        // Get device moving info
        self.userMovement = [BETrustFactorDataset_Motion userMovement];
        
        // Return moving info
        return self.userMovement;
        
    } else {
        
        // Return moving info
        return self.userMovement;
    }
}

// Time information
- (NSString *)getTimeDateStringWithHourBlockSize:(NSInteger)blockSize withDayOfWeek:(BOOL)day {
    
    
    // If dataset isn't populated
    if(!self.hourOfDay || !self.dayOfWeek) {
        
        // Get day of week
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekDay = [comps weekday];
        
        NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[NSDate date]];
        
        // Set minutes
        NSInteger minutes = [components minute];
        
        // Set hours
        NSInteger hours = [components hour];
        
        // Set dayOfWeek dataset
        self.dayOfWeek = weekDay;
        
        // Set hourOfDay dataset
        self.hourOfDay = hours;
        
        // Round up if needed
        if(minutes > 30){
            
            // Round up hour of day
            self.hourOfDay = hours+1;
        }
        
        // Avoid midnight as 0/blocksize will equal 0 and ceil will not round up
        if(hours == 0) {
            
            // Sets hour of day to 1 when midnight
            self.hourOfDay = 1;
        }
        
        // Only return day of week
        if(blockSize==0 && day==YES){
            
            // Return formatted with day of week and time
            return [NSString stringWithFormat:@"DAY_%ld",(long)self.dayOfWeek];
            
        }
        else{ // return only hour or hour + day of week
            
            // Hours partitioned by dividing by block size, adjust accordingly but it does impact multiple rules
            int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
            
            // If day is provided
            if(day == YES) {
                
                // Return formatted with day of week and time
                return [NSString stringWithFormat:@"DAY_%ld_HOUR_%ld",(long)self.dayOfWeek,(long)hourBlock];
                
            } else {
                
                // Return just time
                return [NSString stringWithFormat:@"HOUR_%ld",(long)hourBlock];
            }
            
            
        }
        
        
    } else {
        
        // Only return day of week
        if(blockSize==0 && day==YES){
            
            // Return formatted with day of week and time
            return [NSString stringWithFormat:@"DAY_%ld",(long)self.dayOfWeek];
            
        }
        else{ // return only hour or hour + day of week
            
            // Hours partitioned by dividing by block size, adjust accordingly but it does impact multiple rules
            int hourBlock = ceilf((float)self.hourOfDay / (float)blockSize);
            
            // If day is provided
            if(day == YES) {
                
                // Return formatted with day of week and time
                return [NSString stringWithFormat:@"DAY_%ld_HOUR_%ld",(long)self.dayOfWeek,(long)hourBlock];
                
            } else {
                
                // Return just time
                return [NSString stringWithFormat:@"HOUR_%ld",(long)hourBlock];
            }
            
            
        }
    }
}

// Installed App Info
- (NSArray *)getInstalledAppInfo {
    
    // If dataset isn't populated
    if(!self.installedApps || self.installedApps == nil) {
        
        // Get the list of user apps
        @try {
            
            // Set installed apps to user apps
            self.installedApps = [BETrustFactorDataset_Application getUserAppInfo];
            
            // Return installed apps
            return self.installedApps;
        }
        
        @catch (NSException * ex) {
            
            // Error
            return nil;
        }
        
        // If already populated
    } else {
        
        // Return installed apps
        return self.installedApps;
    }
}

// Process information
- (NSArray *)getProcessInfo {
    
    // If dataset is not populated
    if(!self.runningProcesses || self.runningProcesses ==nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set running processes
            self.runningProcesses  = [BETrustFactorDataset_Process getProcessInfo];
            
            // Return running processes
            return self.runningProcesses;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If already populated
    } else {
        
        // Return running processes
        return self.runningProcesses ;
    }
}

// PID
- (NSNumber *)getOurPID {
    
    // If dataset is not populated
    if(!self.ourPID || self.ourPID ==nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set our PID
            self.ourPID = [BETrustFactorDataset_Process getOurPID];
            
            // Return our PID
            return self.ourPID;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return our PID
        return self.ourPID ;
    }
}

// Network Route Info
- (NSArray *)getRouteInfo {
    
    // If dataset is not populated
    if(!self.networkRoutes || self.networkRoutes == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set network routes
            self.networkRoutes = [BETrustFactorDataset_Routes getRoutes];
            
            // Return network routes
            return self.networkRoutes;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return network routes
        return self.networkRoutes;
    }
}

// Data transfer information
- (NSDictionary *)getDataXferInfo {
    
    // If dataset is not populated
    if(!self.interfaceBytes || self.interfaceBytes == nil) {
        
        // Get interface size in form of bytes
        @try {
            
            // Set interface size in the form of bytes
            self.interfaceBytes = [BETrustFactorDataset_Netstat getInterfaceBytes];
            
            // Return interfacce bytes
            return self.interfaceBytes;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return interface bytes
        return self.interfaceBytes;
    }
}

// NetStat Info
- (NSArray *)getNetstatInfo {
    
    //Do we any data yet?
    if (!self.netstatData || self.netstatData == nil) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if ([self netstatDataDNEStatus] == DNEStatus_expired) {
            return self.netstatData;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if (self.netstatData != nil) {
                
                NSLog(@"Got netstat data after waiting..");
                
                // Return location
                return self.netstatData;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Netstat data timer expired");
        [self setNetstatDataDNEStatus:DNEStatus_expired];
        
        // Return Location
        return self.netstatData;
    }
    
    // We already have the data
    NSLog(@"Got netstat data without waiting...");
    
    // Return location
    return self.netstatData;
    
}

// Location information
- (CLLocation *)getLocationInfo {
    
    //Do we any data yet?
    if(self.location == nil) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self locationDNEStatus]==DNEStatus_expired){
            return self.location;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.location != nil) {
                
                NSLog(@"Got location GPS after waiting..");
                
                // Return location
                return self.location;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Location GPS timer expired");
        [self setLocationDNEStatus:DNEStatus_expired];
        
        // Return Location
        return self.location;
    }
    
    // We already have the data
    NSLog(@"Got location GPS without waiting...");
    
    // Return location
    return self.location;
}

// Placemark information
- (CLPlacemark *)getPlacemarkInfo {
    
    //Do we any data yet?
    if(self.placemark == nil) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self placemarkDNEStatus]==DNEStatus_expired){
            return self.placemark;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.50;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.placemark != nil) {
                
                NSLog(@"Got location placemark after waiting..");
                
                // Return location placemark
                return self.placemark;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Location placemark timer expired");
        [self setPlacemarkDNEStatus:DNEStatus_expired];
        
        // Return location placemark
        return self.placemark;
    }
    
    // We already have the data
    NSLog(@"Got location placemark without waiting...");
    
    // Return location placemark
    return self.placemark;
}

// Previous activity information
- (NSArray *)getPreviousActivityInfo {
    
    //Do we any data yet?
    if(self.previousActivities == nil || self.previousActivities.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self activityDNEStatus]==DNEStatus_expired){
            return self.previousActivities;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.previousActivities.count > 0) {
                NSLog(@"Got Activity after waiting..");
                
                // Return previous activities
                return self.previousActivities;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Activity timer expired");
        [self setActivityDNEStatus:DNEStatus_expired];
        
        // Return previous activities
        return self.previousActivities;
    }
    
    // We already have the data
    NSLog(@"Got Activity without waiting...");
    
    // Return previous activities
    return self.previousActivities;
}

// Gyro information
- (NSArray *)getGyroRadsInfo {
    
    //Do we any data yet?
    if(self.gyroRads == nil || self.gyroRads.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self gyroMotionDNEStatus]==DNEStatus_expired){
            return self.gyroRads;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.2;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.gyroRads.count > 0){
                NSLog(@"Got Gyro rads after waiting..");
                return self.gyroRads;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Gyro rads timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        
        // Return gyro
        return self.gyroRads;
    }
    
    // We already have the data
    NSLog(@"Got Gyro rads without waiting...");
    
    // Return gyro
    return self.gyroRads;
}

// motion information
- (NSArray *)getUserMovementInfo {
    
    //Full data yet?
    if(self.userMovementInfo == nil || self.userMovementInfo.count < 50) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self userMovementDNEStatus]==DNEStatus_expired){
            return self.userMovementInfo;
        }
        
        //Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.userMovementInfo.count > 0){
                NSLog(@"Got user movement after waiting..");
                return self.userMovementInfo;
                
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"User movement timer expired");
        [self setUserMovementDNEStatus:DNEStatus_expired];
        
        // Return motion
        return self.userMovementInfo;
    }
    
    // We already have the data
    NSLog(@"Got user movement without waiting...");
    
    // Return motion
    return self.userMovementInfo;
    
}


// Gyro pitch information
- (NSArray *)getGyroPitchInfo {
    
    // Do we any pitch info yet?
    if(self.gyroRollPitch == nil || self.gyroRollPitch.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self gyroMotionDNEStatus]==DNEStatus_expired){
            return self.gyroRollPitch;
        }
        
        // Nope, wait for data
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.25;
        
        while ((currentTime-startTime) < waitTime) {
            
            // If its greater than 0 return
            if(self.gyroRollPitch.count > 0) {
                
                NSLog(@"Got Gyro roll pitch  after waiting..");
                
                // Return gyro pitch
                return self.gyroRollPitch;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Gyro roll pitch timer expired");
        [self setGyroMotionDNEStatus:DNEStatus_expired];
        
        // Return gyro pitch
        return self.gyroRollPitch;
    }
    
    // We already have the data
    NSLog(@"Got Gyro roll pitch without waiting...");
    
    // Return gyro pitch
    return self.gyroRollPitch;
}

// Acceleration info
- (NSArray *)getAccelRadsInfo {
    
    // Do we any rads yet?
    if(self.accelRads == nil || self.accelRads.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self accelMotionDNEStatus]==DNEStatus_expired){
            return self.accelRads;
        }
        
        // Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.1;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.accelRads.count > 0) {
                
                NSLog(@"Got accel rads after waiting..");
                
                // Return acceleration rads
                return self.accelRads;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires
        NSLog(@"Accel rads timer expired");
        [self setAccelMotionDNEStatus:DNEStatus_expired];
        
        // Return acceleration rads
        return self.accelRads;
    }
    
    // We already have the data
    NSLog(@"Got accel rads without waiting...");
    
    // Return acceleration rads
    return self.accelRads;
}



// Magnetic Headings information
- (NSArray *)getMagneticHeadingsInfo {
    
    //Do we any headings yet?
    if(self.magneticHeading == nil || self.magneticHeading.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self magneticHeadingDNEStatus]==DNEStatus_expired){
            return self.magneticHeading;
        }
        
        //Nope, wait for rads
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.5;
        
        while ((currentTime-startTime) < waitTime){
            
            // If its greater than 0 return
            if(self.magneticHeading.count > 0) {
                
                NSLog(@"Got magnetic headings after waiting..");
                
                // Return headings
                return self.magneticHeading;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer Expires
        NSLog(@"Headings timer expired");
        [self setMagneticHeadingDNEStatus:DNEStatus_expired];
        
        // Return headings
        return self.magneticHeading;
    }
    
    // We alreaady have the data
    NSLog(@"Got magnetic headings without waiting...");
    
    // Return headings
    return self.magneticHeading;
}



// Wifi information
- (NSDictionary *)getWifiInfo {
    
    // If dataset is not populated
    if(!self.wifiData || self.wifiData == nil) {
        
        // Try for wifi data
        @try {
            
            // Get wifi data and set it
            self.wifiData = [BETrustFactorDataset_Wifi getWifi];
            
            // Return wifi data
            return self.wifiData;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return wifi data
        return self.wifiData;
    }
}

//wifi encryption status
- (NSArray *) getWifiEncryption {
    // If dataset is not populated
    if(!self.wifiEncryption || self.wifiEncryption == nil) {
        
        // Try for
        @try {
            
            // Get wifi encryption and set it
            self.wifiEncryption = [BETrustFactorDataset_Wifi getWifiEncryption];
            
            // Return wifi data
            return self.wifiEncryption;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return wifi data
        return self.wifiEncryption;
    }
    
}


// Wifi enabled
-(NSNumber *)isWifiEnabled {
    
    // If dataset is not populated
    if(self.wifiEnabled == nil) {
        
        // Try to enable wifi
        @try {
            
            // Set whether wifi is enabled or not
            self.wifiEnabled = [BETrustFactorDataset_Wifi isWiFiEnabled];
            
            // Return information about whether wifi is enabled
            return self.wifiEnabled;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If the dataset is already populated
    } else {
        
        // Return information about whether wifi is enabled
        return self.wifiEnabled;
    }
}

// BLE information
- (NSArray *)getConnectedBLEInfo {
    //Do we any devices yet?
    if(self.connectedBLEDevices == nil || self.connectedBLEDevices.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self connectedBLESDNEStatus]==DNEStatus_expired){
            return self.connectedBLEDevices;
        }
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        
        //If we don't wait long enough we may never find the same device twice in a row
        float waitTime = 0.05;
        
        while ((currentTime-startTime) < waitTime) {
            
            
            // If its greater than 10 return, otherwise we always wait
            if(self.connectedBLEDevices.count > 0){
                NSLog(@"Got connected BLE devices after waiting..");
                
                // Return the BLE devices
                return self.connectedBLEDevices;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires, for BT don't set to expired as we don't want a penaly, just noData
        NSLog(@"Connected BLE devices timer expired");
        if(self.connectedBLEDevices.count<1){
            [self setConnectedBLESDNEStatus:DNEStatus_expired];
        }
        
        // Return the BLE devices
        return self.connectedBLEDevices;
    }
    
    // We already have the data
    NSLog(@"Got connected BLE devices without waiting...");
    
    // Return the BLE devices
    return self.connectedBLEDevices;
}


// BLE information
- (NSArray *)getDiscoveredBLEInfo {
    
    //Do we any devices yet?
    if(self.discoveredBLEDevices == nil || self.discoveredBLEDevices.count < 2) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self discoveredBLESDNEStatus]==DNEStatus_expired){
            return self.discoveredBLEDevices;
        }
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        
        //If we don't wait long enough we may never find the same device twice in a row
        float waitTime = 1.0;
        
        while ((currentTime-startTime) < waitTime) {
            
            // Mandatory wait because BLE scan is funky
            
            // If its greater than 10 return, otherwise we always wait
            /*
             if(self.discoveredBLEDevices.count > 4){
             NSLog(@"Got discovered BLE devices after waiting..");
             
             // Return the BLE devices
             return self.discoveredBLEDevices;
             }
             */
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires, for BT don't set to expired as we don't want a penaly, just noData
        NSLog(@"Discovered BLE devices timer expired");
        if(self.discoveredBLEDevices.count<1){
            [self setDiscoveredBLESDNEStatus:DNEStatus_expired];
        }
        
        // Return the BLE devices
        return self.discoveredBLEDevices;
    }
    
    // We already have the data
    NSLog(@"Got discovered BLE devices without waiting...");
    
    // Return the BLE devices
    return self.discoveredBLEDevices;
}

// BT information
- (NSArray *)getClassicBTInfo {
    
    //Do we any devices yet?
    if(self.connectedClassicBTDevices == nil || self.connectedClassicBTDevices.count < 1) {
        
        // If the dataset expired during a previous TF attempt, don't wait again, just exit.
        // This ensures that we still try if TFs later in the policy require the data and perhaps its populated by then
        // but we are not waiting again
        
        if([self connectedClassicDNEStatus]==DNEStatus_expired){
            return self.connectedClassicBTDevices;
        }
        
        //Nope, wait for devices
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        CFAbsoluteTime currentTime = startTime;
        float waitTime = 0.05;
        
        while ((currentTime-startTime) < waitTime) {
            
            // If its greater than 0 return
            if(self.connectedClassicBTDevices.count > 0){
                NSLog(@"Got discovered classic BT devices after waiting..");
                
                // Return connected BT devices
                return self.connectedClassicBTDevices;
            }
            
            [NSThread sleepForTimeInterval:0.01];
            
            // Update timer
            currentTime = CFAbsoluteTimeGetCurrent();
        }
        
        // Timer expires, for BT don't set to expired as we don't want a penaly, just noData
        NSLog(@"Connected classic BT device timer expired");
        [self setConnectedClassicDNEStatus:DNEStatus_expired];
        
        // Return connected BT devices
        return self.connectedClassicBTDevices;
    }
    
    // We already have the data
    NSLog(@"Got connected classic BT devices without waiting...");
    
    // Return connected BT devices
    return self.connectedClassicBTDevices;
}

// Wifi signal
- (NSNumber *)getWifiSignal {
    
    // If dataset is not populated
    if(!self.wifiSignal || self.wifiSignal == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set the wifi signal
            self.wifiSignal = [BETrustFactorDataset_Wifi getSignal];
            
            // Return wifi signal
            return self.wifiSignal;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return wifi signal
        return self.wifiSignal;
    }
}


// Raw cellular signal
- (NSNumber *)getCelluarSignalRaw {
    
    // If dataset is not populated
    if(!self.celluarSignalRaw || self.celluarSignalRaw == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set raw signal
            self.celluarSignalRaw = [BETrustFactorDataset_Cell getSignalRaw];
            
            // Return raw signal
            return self.celluarSignalRaw;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If it is already populated
    } else {
        
        // Return raw signal
        return self.celluarSignalRaw;
    }
}

// Carrier connection name
- (NSString *)getCarrierConnectionName {
    
    // If dataset is not populated
    if(!self.carrierConnectionName || self.carrierConnectionName == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set carrier connection information
            self.carrierConnectionName = [BETrustFactorDataset_Cell getCarrierName];
            
            // Return carrier connection information
            return self.carrierConnectionName;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return carrier connection information
        return self.carrierConnectionName;
    }
}

// Carrier connection name
- (NSString *)getCarrierConnectionSpeed {
    
    // If dataset is not populated
    if(!self.carrierConnectionSpeed || self.carrierConnectionSpeed == nil) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set carrier connection information
            self.carrierConnectionSpeed = [BETrustFactorDataset_Cell getCarrierSpeed];
            
            // Return carrier connection information
            return self.carrierConnectionSpeed;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return carrier connection information
        return self.carrierConnectionSpeed;
    }
}

// AirplaneMode information
-(NSNumber *)isAirplaneMode {
    
    // If dataset is not populated
    if(!self.airplaneMode) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set AirplaneMode information
            self.airplaneMode = [BETrustFactorDataset_Cell isAirplane];
            
            // Return AirplaneMode information
            return self.airplaneMode;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return AirplaneMode information
        return self.airplaneMode;
    }
}

// Tethering information
-(NSNumber *)isTethering {
    
    // If dataset is not popoulated
    if(!self.tethering) {
        
        // Get the list of processes and all information about them
        @try {
            
            // Set if device is tethering
            self.tethering = [BETrustFactorDataset_Wifi isTethering];
            
            // Return tethering information
            return self.tethering;
        }
        
        @catch (NSException * ex) {
            // Error
            return nil;
        }
        
        // If dataset is already populated
    } else {
        
        // Return tethering information
        return self.tethering;
    }
}

@end
