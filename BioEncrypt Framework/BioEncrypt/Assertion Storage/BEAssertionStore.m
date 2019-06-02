//
//  BEAssertionStore.m
//  BioEncrypt
//
//

#import "BEAssertionStore.h"
#import "BEAssertionStore+Helper.h"
#import "BEConstants.h"

@implementation BEAssertionStore

// Initialize
- (id)init {
    
    // Check if self exists
    self = [super init];
    if (self) {
        
        // Set the stored TrustFactor Objects to nil
        _storedTrustFactorObjects = [NSArray array];
    }
    return self;
}

// Add multiple new StoredTrustFactorObjects to the store
- (BOOL)addMultipleObjectsToStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    
    // Check if we received StoredTrustFactorObjects
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Recieve storedTrustFactorObjects.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No Stored Trust Factor Object Provided.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid Stored TrustFactor Output Object", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to Recieve storedTrustFactorObjects: %@", errorDetails);
        
        // Don't return anything
        return NO;
    }
    
    // Run through provided array of storedTrustFactorObjects
    for (BEStoredTrustFactorObject *newStoredTrustFactorObject in storedTrustFactorObjects) {
        
        // Add the new StoredTrustFactorObject into the array
        if (![self addSingleObjectToStore:newStoredTrustFactorObject withError:error]) {
            
            // Error out, no trustfactors set
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Add the New storedTrustFactorObject.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to add storedTrustFactorObject into the array.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid Stored TrustFactor Output Object.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:assertionStoreDomain code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
            
            // Log Error
            NSLog(@"Failed to Add the New storedTrustFactorObject: %@", errorDetails);
            
            // Return NO
            return NO;
        }

    }
    // Return yes
    return YES;
}

// Add a single new StoredTrustFactorObject to the store
- (BOOL)addSingleObjectToStore:(BEStoredTrustFactorObject *)newStoredTrustFactorObject withError:(NSError **)error {
    
    // Check that the passed StoredTrustFactorObject is valid
    if (!newStoredTrustFactorObject || newStoredTrustFactorObject == nil) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Stored Trust Factor Object Provided.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to retrieve Trust Factor Object.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a Trust Factor Object.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Stored Trust Factor Object Provided: %@", errorDetails);
        
        // Don't return anything
        return NO;
    }
    
    // BETA2 - Nick's Additions = Added this back
    // Add the new StoredTrustFactorObject into the array
    //[[self storedTrustFactorObjects] addObject:newStoredTrustFactorObject];
    NSMutableArray *storedTrustFactorObjectsArray = [self.storedTrustFactorObjects mutableCopy];
    
    // Check if the stored array is valid
    if (!storedTrustFactorObjectsArray || storedTrustFactorObjectsArray == nil) {
        
        // Array is empty
        
        // Set the array
        storedTrustFactorObjectsArray = [NSMutableArray arrayWithObject:newStoredTrustFactorObject];
        
    } else {
        
        // Array has values in it already
        
        // Add the StoredTrustFactorObject into the array
        [storedTrustFactorObjectsArray addObject:newStoredTrustFactorObject];
        
    }
    
    // Set the StoredTrustFactorObjects
    [self setStoredTrustFactorObjects:[storedTrustFactorObjectsArray copy]];
    
    // Return YES
    return YES;
}

// Replace multiple storedTrustFactorObjets in the master list
- (BOOL)replaceMultipleObjectsInStore:(NSArray *)existingStoredTrustFactorObjects withError:(NSError **)error {
    
    // Check if we received assertions
    if (!existingStoredTrustFactorObjects || existingStoredTrustFactorObjects.count < 1) {
        
        // Error out, no assertions received
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Replace StoredTrustFactorObjects Failed.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Invalid StoredTrustFactorObjects objects provided for replacement.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid Stored TrustFactor Object", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SAInvalidStoredTrustFactorObjectsProvided userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Replace StoredTrustFactorObjects Failed: %@", errorDetails);
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of storedTrustFactorObjects
    for (BEStoredTrustFactorObject *existingStoredTrustFactorObject in existingStoredTrustFactorObjects) {
        
        // Check to make sure the storedTrustFactorObject was added to the store
        if (![self replaceSingleObjectInStore:existingStoredTrustFactorObject withError:error]) {
            
            // Error out, unable to add storedTrustFactorObject into the store
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Replace storedTrustFactorObject Failed in the Store.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to replace storedTrustFactorObject in the store.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try Passing A Valid Stored TrustFactor Object", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:assertionStoreDomain code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
            
            // Log Error
            NSLog(@"Replace storedTrustFactorObjects Failed in the Store: %@", errorDetails);
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

// Replace a single storedTrustFactorObject in the store
- (BOOL)replaceSingleObjectInStore:(BEStoredTrustFactorObject *)storedTrustFactorObject withError:(NSError **)error {
    
    if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
        
        // Error out, no storedTrustFactorObjects received
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Replacement of storedTrustFactorObject Object Failed.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing provided storedTrustFactorObject object during replacement.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a storedTrustFactorObject object to replace.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Replacement of storedTrustFactorObject Object Failed: %@", errorDetails);
        
        // Don't return anything
        return NO;
    }
    
    // Make sure it already exists before replacement
    BOOL exists;
    BEStoredTrustFactorObject *existing = [self getStoredTrustFactorObjectWithFactorID:storedTrustFactorObject.factorID doesExist:&exists withError:error];
    if (existing || existing != nil || exists) {
        
        // Remove the original storedTrustFactorObject from the array
        if (![self removeSingleObjectFromStore:existing withError:error]) {
            
            // Error out, unable to remove StoredTrustFactorObject
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Removal of storedTrustFactorObject Failed.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to remove storedTrustFactorObject.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try removing storedTrustFactorObject.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:assertionStoreDomain code:SAUnableToRemoveAssertion userInfo:errorDetails];
            
            // Log Error
            NSLog(@"Removal of storedTrustFactorObject Failed: %@", errorDetails);
            
            // Return NO
            return NO;
        }
    }
    
    // Add the new StoredTrustFactorObject into the array
    if (![self addSingleObjectToStore:storedTrustFactorObject withError:error]) {
        
        // Error out, unable to add the StoredTrustFactorObject into the store
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Addition of storedTrustFactorObject Failed.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to add storedTrustFactorObject.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try adding storedTrustFactorObject.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SAUnableToAddStoreTrustFactorObjectsIntoStore userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Addition of storedTrustFactorObject Failed: %@", errorDetails);
        
        // Return NO
        return NO;
    }

    // Return YES
    return YES;
}

// Remove the single provided storedTrustFactorObject  from the store - returns whether it passed or failed
- (BOOL)removeSingleObjectFromStore:(BEStoredTrustFactorObject *)storedTrustFactorObject withError:(NSError **)error {
    
    // Check that the passed storedTrustFactorObject is valid
    if (!storedTrustFactorObject || storedTrustFactorObject == nil) {
        
        // Error out, no assertion object provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Assertons object not provided.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No storedTrustFactorObjects provided for removal.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Provide an assertion object for removal.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Assertions object not provided: %@", errorDetails);
        
        // Return NO
        return NO;
    }
    
    // Check to see if the storedTrustFactorObject already exists
    BOOL exists;
    if ([self getStoredTrustFactorObjectWithFactorID:storedTrustFactorObject.factorID doesExist:&exists withError:error] != nil || exists) {
        
        // BETA2 - Nick's Additions = Added this back
        // Remove the storedTrustFactorObject from the array
        NSMutableArray *storedTrustFactorObjectArray = [self.storedTrustFactorObjects mutableCopy];
        
        // Remove the storedTrustFactorObject from the array
        [storedTrustFactorObjectArray removeObject:storedTrustFactorObject];
        //[[self storedTrustFactorObjects] removeObject:storedTrustFactorObject];
        
        // Set the storedTrustFactorObjects
        [self setStoredTrustFactorObjects:[storedTrustFactorObjectArray copy]];
        
    } else {
        // Error out, no matching storedTrustFactorObjects  found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Matching storedTrustFactorObjects not found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No matching storedTrustFactorObjects object found for removal.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Provide a matching storedTrustFactorObjects assertion.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoMatchingAssertionsFound userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Matching storedTrustFactorObjects not found: %@", errorDetails);
        
        // Return NO
        return NO;
    }
    
    // Return YES
    return YES;
    
}

// Remove provided storedTrustFactorObjects from the store - returns whether it passed or failed
- (BOOL)removeMultipleObjectsFromStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error {
    // Check if we received assertions
    if (!storedTrustFactorObjects || storedTrustFactorObjects.count < 1) {
        
        // Error out, no assertions received
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed getting storedTrustFactorObjects object.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No storedTrustFactorObjects provided.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Provide a storedTrustFactorObjects object.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:assertionStoreDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed getting storedTrustFactorObjects object: %@", errorDetails);
        
        // Don't return anything
        return NO;
    }
    
    // Run through this array of assertions
    for (BEStoredTrustFactorObject *storedTrustFactorObject in storedTrustFactorObjects) {
        
        // Check to make sure the storedTrustFactorObject was added to the store
        if (![self removeSingleObjectFromStore:storedTrustFactorObject withError:error]) {
            
            // Error out, unable to add storedTrustFactorObject into the store
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Remove storedTrustFactorObject.", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to remove storedTrustFactorObject from the store.", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try locating a valid object in storedTrustFactorObjects to remove.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:assertionStoreDomain code:SAUnableToRemoveAssertion userInfo:errorDetails];
            
            // Log Error
            NSLog(@"Failed to Remove storedTrustFactorObject: %@", errorDetails);
            
            // Return NO
            return NO;
        }
    }
    
    // Return yes
    return YES;
}

@end
