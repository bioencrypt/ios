//
//  BETrustFactorDispatch_File.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_File.h"
#import <sys/stat.h>

@implementation BETrustFactorDispatch_File

// Check for bad files
+ (BETrustFactorOutputObject *)blacklisted:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets]  validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Get the filemanager singleton
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    // Run through all the files in the payload
    for (NSString *path in payload) {
        
        // Check if they exist
        if ([fileMan fileExistsAtPath:path]) {
            
            // If the bad file exists, mark it in the array
            [outputArray addObject:path];
            
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// File size change check
+ (BETrustFactorOutputObject *)sizeChange:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets]  validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Get the filemanager singleton
    NSFileManager *fileMan = [NSFileManager defaultManager];
    
    // Create the output array
    NSMutableArray *fileSizes = [[NSMutableArray alloc] initWithCapacity:payload.count];
    

    
    // Run through all the files in the payload
    for (NSString *path in payload) {
        
        // struct stat buffer;
        //stat([path UTF8String], &buffer);
        
        // long long size = buffer.st_size;
        
        //FILE *f = fopen([path UTF8String], "r");
        //if (errno == ENOENT)
        // {
        // device is NOT jailbroken
        //    fclose(f);
        //    NSLog(@"no");
        //    return NO;
        //}
        //else {
        // device IS jailbroken
        //fclose(f);
        //NSLog(@"yes");
        //return YES;
        
        //}
        
        // if(stat(, &buffer) == 0){
        
        // }
        
        // Check if they exist
        if ([fileMan fileExistsAtPath:path]) {
            
            // Found the file
            
            // Create an error object
            NSError *error;
            
            // Get the filesize (in bytes) of the given file
            unsigned long long fileSize = [[fileMan attributesOfItemAtPath:path error:&error] fileSize];
            
            // Check if there was an error
            if (error || error != nil) {
                // Error
                
                // Log it
                NSLog(@"Error found in TrustFactor: sizeChange, Error: %@", error.localizedDescription);
                
                // Set the output status code to bad
                [trustFactorOutputObject setStatusCode:DNEStatus_error];
                
            } else {
                // No error
                
                // Add the file size to the output array
                [fileSizes addObject:[path stringByAppendingString:[[NSNumber numberWithUnsignedLongLong:fileSize] stringValue]]];
            }
            
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:fileSizes];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}

// For future use
+ (BOOL)doFstabSize {
    struct stat sb;
    stat("/etc/fstab", &sb);
    long long size = sb.st_size;
    if (size == 80){
        return NO;
    }
    return YES;
    
}

@end
