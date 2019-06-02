//
//  BEAssertionStore+Helper.h
//  BioEncrypt
//
//

#import "BEAssertionStore+Helper.h"

@implementation BEAssertionStore (Helper)

#pragma mark - Helper Methods (kind of)

// Create an assertion object from an assertion
- (BEStoredTrustFactorObject *)createStoredTrustFactorObjectFromTrustFactorOutput:(BETrustFactorOutputObject *)trustFactorOutputObject withError:(NSError **)error {
    
    // Check that the passed trustFactorOutputObject is valid
    if (!trustFactorOutputObject || trustFactorOutputObject == nil) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Create Stored TrustFactor Object from TrustFactor Output Failed.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No Trust Factor Output Object Provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid TrustFactor Output Object", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log error
        NSLog(@"Create Stored TrustFactor Object from TrustFactor Output Failed: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Create a new storedTrustFactorObject object for the provided trustFactorOutputObject
    BEStoredTrustFactorObject *storedTrustFactorObject = [[BEStoredTrustFactorObject alloc] init];
    [storedTrustFactorObject setFactorID:trustFactorOutputObject.trustFactor.identification];
    [storedTrustFactorObject setRevision:trustFactorOutputObject.trustFactor.revision];
    [storedTrustFactorObject setDecayMetric:trustFactorOutputObject.trustFactor.decayMetric];
    [storedTrustFactorObject setLearned:NO]; // Beta2: don't set that it has learned
    [storedTrustFactorObject setFirstRun:[NSDate date]];
    [storedTrustFactorObject setRunCount:[NSNumber numberWithInt:0]]; // Beta2: Set the run count to 0 because we're incrementing on comparison
    
    // Return the assertion object
    return storedTrustFactorObject;
}

// Get the stored trust factor object by its factorID
- (BEStoredTrustFactorObject *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error {
    
    // Check the factor id passed is valid
    if (!factorID || factorID == nil) {
        
        // Error out, no factor ID set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Get Stored TrustFactor Object from TrustFactor Output Failed.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No Trust Factor Output Object Provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid TrustFactor Output Object", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Get Stored TrustFactor Object from TrustFactor Output Failed: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Check if stored object is valid
    if (!self.storedTrustFactorObjects || self.storedTrustFactorObjects.count < 1) {
        // No assertions
        *exists = NO;
        return nil;
    }
    
    // Run through all the stored trustfactor objects and check for a matching factorID
    for (BEStoredTrustFactorObject *storedTrustFactorObject in self.storedTrustFactorObjects) {
        // Look for the matching assertion with the same factorID
        if ([storedTrustFactorObject.factorID isEqualToNumber:factorID]) {
            *exists = YES;
            return storedTrustFactorObject;
        }
    }
    
    // No trustfactor found
    *exists = NO;
    return nil;
}

@end
