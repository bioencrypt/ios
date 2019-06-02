//
//  BETrustFactorDispatcher.m
//  BioEncrypt
//
//

// TODO: Fix the way NSError's are passed back between running multiple trustfactors and just one
#import "BETrustFactorDispatcher.h"
#import "BETrustFactor.h"
#import "BEConstants.h"
#import "BECoreDetection.h"
#import "BEStartupStore.h"
// Parser
#import "BEPolicyParser.h"
#import "BEPolicy.h"

// Import the objc runtime to get class by name
#import <objc/runtime.h>

// Pod for hashing
#import "NSString+Hashes.h"

@implementation BETrustFactorDispatcher

// Run an array of trustfactors and generate candidate assertions
+ (NSArray *)performTrustFactorAnalysis:(NSArray *)trustFactors withTimeout:(NSTimeInterval)timeout andError:(NSError **)error {
    
    // Set the current state of Core Detection
    [[BEStartupStore sharedStartupStore] setCurrentState:@"Performing TrustFactor Analysis"];
    
    // Get the current date
    NSDate *startTime = [NSDate date];
    
    // Create a bool for the timeout
    BOOL timeoutHit = NO;
    
    
    // Get the policy to set privateAPI
    BEPolicy *policy = [[BEPolicyParser sharedPolicy] getPolicy:error];
    
    int allowPrivateAPIs = [policy.allowPrivateAPIs intValue];
    
    // Make an array to pass back
    NSMutableArray *processedTrustFactorArray = [NSMutableArray arrayWithCapacity:trustFactors.count];
    
    // First, check if the array is valid
    if (trustFactors.count < 1 || !trustFactors) {
        
        // Error, no trustfactors received
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform TrustFactor Analysis Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactors received for dispatch", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing in TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoTrustFactorsReceived userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform TrustFactor Analysis Unsuccessful: %@", errorDetails);
    }
    
    // Next, run through the array of trustFactors to be executed
    for (BETrustFactor *trustFactor in trustFactors) {
        
        // Check if timeout is hit
        if (timeoutHit) {
            
            // Timeout already hit
            
            // Create an trustFactorOutputObject with just the error in it
            BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
            
            // Set the DNE Status Code to expired
            [trustFactorOutputObject setStatusCode:DNEStatus_expired];
            
            // Add trustfactor to trustFactorOutput object
            trustFactorOutputObject.trustFactor = trustFactor;
            
            // Add trustfactor ID to trustFactorOutput object
            trustFactorOutputObject.factorID = trustFactor.identification.integerValue;
            
            // Add the trustFactorOutput object to the output array
            [processedTrustFactorArray addObject:trustFactorOutputObject];
            
            // Continue
            continue;
        }
        
        // Deep check for timeout hit
        
        // Get the current time and the start time for the timeout
        NSTimeInterval timeStarted = [startTime timeIntervalSince1970];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        
        // Get the difference (in seconds)
        NSTimeInterval timeDifference = (currentTime - timeStarted);
        
        // Check if the difference is greater than or equal to the timeout
        if (timeDifference >= timeout) {
            
            // Set timeout hit
            timeoutHit = YES;
            
            // Error, timeout hit
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Perform TrustFactor Analysis Unsuccessful", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Timeout hit", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please allow more time to run Core Detection", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoTrustFactorsReceived userInfo:errorDetails];
            
            // Log it
            NSLog(@"Perform TrustFactor Analysis unsuccessful: %@", errorDetails);
            
            // Create an trustFactorOutputObject with just the error in it
            BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
            
            // Set the DNE Status Code to expired
            [trustFactorOutputObject setStatusCode:DNEStatus_expired];
            
            // Add trustfactor to trustFactorOutput object
            trustFactorOutputObject.trustFactor = trustFactor;
            
            // Add trustfactor ID to trustFactorOutput object
            trustFactorOutputObject.factorID = trustFactor.identification.integerValue;
            
            // Add the trustFactorOutput object to the output array
            [processedTrustFactorArray addObject:trustFactorOutputObject];
            
            // Continue
            continue;
        }
        
        // Skip privateAPI TFs - if privateAPI is off
        if (allowPrivateAPIs == 0 && trustFactor.privateAPI.intValue == 1) {
            
            
            continue;
        }
        
        // Run the TrustFactor and populate output object
        BETrustFactorOutputObject *trustFactorOutputObjects = [self executeTrustFactor:trustFactor withError:error];
        
        // Add the trustFactorOutput object to the output array
        [processedTrustFactorArray addObject:trustFactorOutputObjects];
    }
    
    // Return the output array
    return [NSArray arrayWithArray:processedTrustFactorArray];
}

// Executes the TrustFactor with given rule
+ (BETrustFactorOutputObject *)executeTrustFactor:(BETrustFactor *)trustFactor withError:(NSError **)error {
    
    // Create an output object
    BETrustFactorOutputObject *trustFactorOutputObject;
    
    // Try to run implementation
    @try {
        
        // Log the start time
        NSDate *methodStart = [NSDate date];
        
        // Run the trustfactor implementation and get trustFactorOutputObject
        trustFactorOutputObject = [self runTrustFactorWithDispatch:trustFactor.dispatch andImplementation:trustFactor.implementation withPayload:trustFactor.payload andError:error];
        
        // Log the finish time
        NSDate *methodFinish = [NSDate date];
        
        // Get the execution Time
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        
        // Log the TrustFactor Execution Time
        NSLog(@"%@ %@ Execution Time = %f seconds", trustFactor.dispatch, trustFactor.implementation, executionTime);
    }
    @catch (NSException *exception) {
        
        // Something happened inside the implementation
        // Reset our object and set the DNE Status Code to error
        trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Error when a specified TrustFactor caused an exception
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Executing TrustFactor: %@ Caused Exception", trustFactor.name],
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An exception occured when executing the TrustFactor", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that the TrustFactor exists, has valid input, and that the implementation is valid", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoTrustFactorOutputObjectGenerated userInfo:errorDetails];
        
        // Log it
        NSLog(@"%@", [@"Error executing TrustFactor implementation for:" stringByAppendingString:trustFactor.name]);
        
        // Return the object
        return trustFactorOutputObject;
    }
    
    // Add trustfactor to trustFactorOutput object
    trustFactorOutputObject.trustFactor = trustFactor;
    
    // Add trustfactor ID to trustFactorOutput object
    trustFactorOutputObject.factorID = trustFactor.identification.integerValue;
    
    // Validate trustFactorOutputObject
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        
        // Error out, no trustFactorOutputObject generated
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No Output Generated for TrustFactor: %@", trustFactor.name],
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No output was generated for the TrustFactor", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that the TrustFactor exists", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoTrustFactorOutputObjectGenerated userInfo:errorDetails];
        
        // Create an trustFactorOutputObject with just the error
        trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Log it
        NSLog(@"%@", [@"No trustFactorOutputObject generated for trustfactor:" stringByAppendingString:trustFactor.name]);
        
        // Return the assertion
        return trustFactorOutputObject;
    }


    if(trustFactorOutputObject.output.count > 0){
        
        [trustFactorOutputObject setAssertionObjectsFromOutputWithError:error];
    }

    
    // Return the output object
    return trustFactorOutputObject;
}

// Run a TrustFactor by its name with a given payload
+ (BETrustFactorOutputObject *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error {
    
    // Validate the dispatch and implementation
    if (!dispatch || dispatch.length < 1 || dispatch == nil || !implementation || implementation.length < 1 || implementation == nil) {
        
        // No dispatch or implementation name received, error out
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Dispatch or Implementation Name Received", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No dispatch or implementation name received to call", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please ensure that dispatch and implementation names are set correctly in the policy", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoImplementationOrDispatchReceived userInfo:errorDetails];
        
        // Log it
        NSLog(@"No Dispatch or Implementation Name Received: %@", errorDetails);
        
        // Create an trustFactorOutputObject with just the error in it
        BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
        
        // Set the DNE Status Code
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
    }
    
    // Get the class dynamically
    NSString *className = [NSString stringWithFormat:kTrustFactorDispatch, dispatch];
    Class dispatchClass = NSClassFromString(className);

    // Validate the class
    if (!dispatchClass || dispatchClass == nil) {
        
        // No dispatch class found, error out
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No Dispatch Class Found for Class: %@", className],
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No valid dispatch class found", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that the dispatch class exists and is set correctly in the policy - ensure case sensitivity", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoDispatchClassFound userInfo:errorDetails];
        
        // Log it
        NSLog(@"No Dispatch Class Found for Class: %@ for error: %@", className, errorDetails);
        
        // Create an assertion with just the error in it
        BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
        
        // Set the DNE Status Code
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutputObject;
    }
    
    // Get the selector dynamically
    SEL implementationSelector = NSSelectorFromString(implementation);

    // Validate the selector
    if (!implementationSelector || implementationSelector == nil) {
        
        // No implementation selector found, error out
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"No Implementation Selector Found for Selector: %@", implementation],
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No valid implementation selector found", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that the implmentation selector exists and is set correctly in the policy - ensure case sensitivity", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SANoImplementationSelectorFound userInfo:errorDetails];
        
        // Create an assertion with just the error in it
        BETrustFactorOutputObject *trustFactorOutput = [[BETrustFactorOutputObject alloc] init];
        
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_unsupported];
        
        // Log it
        NSLog(@"%@", [@"No valid implementation selector found" stringByAppendingString:implementation]);
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    //NSLog([NSString stringWithFormat:@"%@ %@ %@", @"Trying to run:", dispatchClass, implementation]);
    // Check if the dispatch class responds to the selector for the dispatch name
    if ([dispatchClass respondsToSelector:NSSelectorFromString(implementation)]) {
        
        // Call the method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [dispatchClass performSelector:implementationSelector withObject:payload];
#pragma clang diagnostic pop
    } else {
        
        // No check recognized, error out
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Dispatch Class Does Not Respond to Selector: %@", implementation],
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No valid TrustFactor function found", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Ensure that the dispatch class responds to the implementation and is set correctly in the policy - ensure case sensitivity", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:trustFactorDispatcherDomain code:SAInvalidTrustFactorName userInfo:errorDetails];
        
        // Log it
        NSLog(@"Dispatch Class Does Not Respond to Selector: %@ Error: %@", implementation, errorDetails);
        
        // Create an assertion with just the error in it
        BETrustFactorOutputObject *trustFactorOutput = [[BETrustFactorOutputObject alloc] init];
        
        // Set the DNE Status Code
        [trustFactorOutput setStatusCode:DNEStatus_error];
        
        // Return the assertion
        return trustFactorOutput;
    }
    
    // Return nothing
    return nil;
}

@end
