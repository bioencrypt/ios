//
//  BETrustFactorDataset_Motion.m
//  BioEncrypt
//
//

// Import header file
#import "BETrustFactorDataset_Motion.h"

@implementation BETrustFactorDataset_Motion

// Checking if device is moving
+(NSNumber*)gripMovement{
    
    //Determine if device is moving during grip check
    
     NSArray *gyroRads = [[[BETrustFactorDatasets sharedDatasets] getGyroRadsInfo] copy];
     
//     float xThreshold = 0.5;
//     float yThreshold = 0.5;
//     float zThreshold = 0.3;
//
//     float xDiff = 0.0;
//     float yDiff = 0.0;
//     float zDiff = 0.0;
    
     float lastX = 0.0;
     float lastY = 0.0;
     float lastZ = 0.0;
    
    float dist = 0.0;
    int measurementCount = 0;
     
     // Run through all the samples we collected prior to stopping motion
    
     for (NSDictionary *sample in gyroRads) {
         
         float x = [[sample objectForKey:@"x"] floatValue];
         float y = [[sample objectForKey:@"y"] floatValue];
         float z = [[sample objectForKey:@"z"] floatValue];
         
         // This is the first sample, just record last and go to nexy
         if(lastX == 0.0) {
             lastX = x;
             lastY = y;
             lastZ = z;
             continue;
         }
         
         float dx = (x - lastX);
         float dy = (y - lastY);
//         float dz = (z - lastZ);
         dist = dist + sqrt(dx*dx + dy*dy + dx*dx);
         measurementCount++;
         
         // Add up differences to detect motion, take absolute value to prevent
         //xDiff = xDiff + (fabsf(lastX) - fabsf(x));
         //yDiff = yDiff + (fabsf(lastY) - fabsf(y));
         //zDiff = zDiff + (fabsf(lastZ) - fabsf(z));
     }
    // calculate average distance, subtract 1 from count as we can't measure the first
    float averageDist = dist / (float) measurementCount;
     
     // Check against thresholds?
    /*
     if(xDiff > xThreshold || yDiff > yThreshold || zDiff > zThreshold){
         return [NSNumber numberWithInt:1];
         
     } else {
         return [NSNumber numberWithInt:0];
     }
    */
   
    return [NSNumber numberWithFloat:averageDist];

}

// Total movement of user and device
+ (NSString *) userMovement {
    NSArray *arrayM = [NSArray arrayWithArray: [[BETrustFactorDatasets sharedDatasets] getUserMovementInfo]];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    CGFloat accelerationMagnitude3D = 0;
    CGFloat accelerationMagnitude2D = 0;
    CGFloat rotationMagnitude = 0;
    CGFloat gravityMagnitude = 0;
    CGFloat gravX, gravY, gravZ;
    CGFloat accX, accY, accZ;

    gravX = 0;
    gravY = 0;
    gravZ = 0;
    
    accX = 0;
    accY = 0;
    accZ = 0;
    
    // lets check orientation of device but for this purpose
    NSInteger filteredOrientation = 0;
    CMDeviceMotion *lastMotion = [arrayM lastObject];
    
    // In portrait
    if (orientation == 1 || orientation == 2 || (orientation >= 5 && fabs(lastMotion.gravity.y) > fabs(lastMotion.gravity.x))) {
        filteredOrientation = 1;
    }
    
    // In landscape
    else if (orientation == 3 || orientation == 4 || (orientation >= 5 && fabs(lastMotion.gravity.x) > fabs(lastMotion.gravity.y))) {
        filteredOrientation = 2;
        
    // Unknown orientation
    } else {
        filteredOrientation = 3;
    }
    
    
    for (CMDeviceMotion *motion in arrayM) {
        
        // gravity by elements
        gravX = gravX + motion.gravity.x;
        gravY = gravY + motion.gravity.y;
        gravZ = gravZ + motion.gravity.z;
        
        
        // 3D acceleration
        CGFloat acc3D =
        motion.userAcceleration.x * motion.userAcceleration.x +
        motion.userAcceleration.y * motion.userAcceleration.y +
        motion.userAcceleration.z * motion.userAcceleration.z;
        
        acc3D = sqrt(acc3D);
        accelerationMagnitude3D += acc3D;
        
        
        // 2D acceleration
        CGFloat acc2D;
        if (filteredOrientation == 1) {
            // We need only Z and Y axis for portriat
            acc2D = motion.userAcceleration.y * motion.userAcceleration.y + motion.userAcceleration.z * motion.userAcceleration.z;
            
        } else if (filteredOrientation == 2) {
            // We need only Z and X axis for landscape
            acc2D = motion.userAcceleration.x * motion.userAcceleration.x + motion.userAcceleration.z * motion.userAcceleration.z;
            
        } else {
            acc2D =
            motion.userAcceleration.x * motion.userAcceleration.x +
            motion.userAcceleration.y * motion.userAcceleration.y +
            motion.userAcceleration.z * motion.userAcceleration.z;
        }
        
        acc2D = sqrt(acc2D);
        accelerationMagnitude2D += acc2D;
        NSLog(@"ACC %lf", acc2D);
        
        NSLog(@"ACC final %lf", accelerationMagnitude2D);

        // Rotation
        CGFloat rotationSpeed = (motion.rotationRate.x*motion.rotationRate.x + motion.rotationRate.y*motion.rotationRate.y + motion.rotationRate.z*motion.rotationRate.z);
        rotationSpeed = sqrt(rotationSpeed);
        rotationMagnitude += rotationSpeed;
        
        // Acceleration by elements
        accX += motion.userAcceleration.x;
        accY += motion.userAcceleration.y;
        accZ += motion.userAcceleration.z;
    }
    
    // Finding final gravity magnitude by avarage of all axis
    gravX = gravX / (CGFloat) arrayM.count;
    gravY = gravY / (CGFloat) arrayM.count;
    gravZ = gravZ / (CGFloat) arrayM.count;
    gravityMagnitude = gravX*gravX + gravY*gravY + gravZ*gravZ;
    gravityMagnitude = sqrt(gravityMagnitude);
    
    // Acceleration
    accelerationMagnitude3D = accelerationMagnitude3D / (CGFloat) arrayM.count;
    accelerationMagnitude2D = accelerationMagnitude2D / (CGFloat) arrayM.count;
    accX = accX / (CGFloat) arrayM.count;
    accY = accY / (CGFloat) arrayM.count;
    accZ = accZ / (CGFloat) arrayM.count;
    
    // Rotation
    rotationMagnitude = rotationMagnitude / (CGFloat) arrayM.count;
    
    // 0 - Standing still, 1 - Walking, 2 - Running
    NSInteger statusMoving = 0;
    
    if (accelerationMagnitude2D < 0.09)
        statusMoving = 0;
    else if (accelerationMagnitude2D < 0.22)
        statusMoving = 1;
    else
        statusMoving = 2;
    
    
    // 0 - No error, 1 - Changing orientation, 2 - Rotating or Shaking
    NSInteger errorObserving = 0;

    if (gravityMagnitude < 0.955)
        errorObserving = 1;
    else if (rotationMagnitude > 1.0)
        errorObserving = 2;

    // One of the examples of final statement
    if (errorObserving == 0) {
        if (statusMoving == 0)
            return @"StandingStill";
        else if (statusMoving == 1)
            return @"Walking";
        else
            return @"Running";
    }
    
    else if (errorObserving == 1)
        return @"ChangingOrientation";
    
    else
        return @"RotatingOrShaking";

}

// Checking orientation of device
+ (NSString *)orientation {

    UIDeviceOrientation orientation;
    
    // Use the API which does not require motion authorization if there was an error in motion (i.e., not authorized)
    if ([[BETrustFactorDatasets sharedDatasets] accelMotionDNEStatus] != 0 ) {
        
        // Set the device to the current device
        UIDevice *device = [UIDevice currentDevice];
        orientation = device.orientation;
        
    } else {
        
        // Use custom mechanism for increased accuracy (the non-motion API is designed for GUIs not user auth)
        NSArray *gryoRads = [[[BETrustFactorDatasets sharedDatasets] getAccelRadsInfo] copy];
        
        float xAverage;
        float yAverage;
        float zAverage;
        
        float xTotal = 0.0;
        float yTotal = 0.0;
        float zTotal = 0.0;
        
        float count=0;
        
        for (NSDictionary *sample in gryoRads) {
            
            count++;
            xTotal = xTotal + [[sample objectForKey:@"x"] floatValue];
            yTotal = yTotal + [[sample objectForKey:@"y"] floatValue];
            zTotal = zTotal + [[sample objectForKey:@"z"] floatValue];
            
        }
        
        // We don't have any samples? avoid dividing by 0 use default API
        if(count < 1) {
            
            // Set the device to current device
            UIDevice *device = [UIDevice currentDevice];
            orientation = device.orientation;
            
        } else {
        
            xAverage = xTotal / count;
            yAverage = yTotal / count;
            zAverage = zTotal / count;
            
            
            if (xAverage >= 0.35 && (yAverage <= 0.7 && yAverage >=-0.7)) {
                
                orientation = UIDeviceOrientationLandscapeLeft;
                
            } else if (xAverage <= -0.35 && (yAverage <= 0.7 && yAverage >=-0.7)) {
                
                orientation = UIDeviceOrientationLandscapeRight;
                
            } else if (yAverage <= -0.15 && (xAverage <= 0.7 && xAverage >= -0.7)) {
                
                orientation = UIDeviceOrientationPortrait;
                
            } else if (yAverage >= 0.15 && (xAverage <= 0.7 && xAverage >= -0.7)) {
                
                orientation = UIDeviceOrientationPortraitUpsideDown;
                
            } else if ((xAverage <= 0.15 && xAverage >= -0.15) && (yAverage <= 0.15 && yAverage >= -0.15) && zAverage<0) {
                
                orientation = UIDeviceOrientationFaceUp;
                
            } else if ((xAverage <= 0.15 && xAverage >= -0.15) && (yAverage <= 0.15 && yAverage >= -0.15) && zAverage>0) {
                
                orientation = UIDeviceOrientationFaceDown;
                
            } else {
                
                orientation = UIDeviceOrientationUnknown;
            }
        }
    }

    NSString *orientationString;

    switch (orientation) {
            
        // Portrait Orientation
        case UIDeviceOrientationPortrait:
            orientationString =  @"Portrait";
            break;
          
        // Landscape Right Orientation
        case UIDeviceOrientationLandscapeRight:
            orientationString =  @"Landscape_Right";
            break;
            
        // Portrait Upside Down
        case UIDeviceOrientationPortraitUpsideDown:
            orientationString =  @"Portrait_Upside_Down";
            break;
            
        // Landscape Left
        case UIDeviceOrientationLandscapeLeft:
            orientationString =  @"Landscape_Left";
            break;
            
        // Face Up
        case UIDeviceOrientationFaceUp:
            orientationString =  @"Face_Up";
            break;
            
        // Face Down
        case UIDeviceOrientationFaceDown:
            orientationString =  @"Face_Down";
            break;
           
        // Orientation Unknown
        case UIDeviceOrientationUnknown:
            //Error
            orientationString =  @"unknown";
            break;
            
        default:
            //Error
            orientationString =  @"error";
            break;
    }
    return orientationString;
}

@end
