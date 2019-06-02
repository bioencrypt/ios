//
//  BETrustFactorStorage.m
//  BioEncrypt
//
//

//TODO: Find a good way to save and retrieve the global store security token

#import "BETrustFactorStorage.h"
#import "BEConstants.h"

// DCObjectMapping
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "DCParserConfiguration.h"
#import "NSObject+ObjectMap.h"

@implementation BETrustFactorStorage

// Singleton method
+ (id)sharedStorage {
    static BETrustFactorStorage *sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

// reset assertion store
- (void) resetAssertionStoreWithError: (NSError **) error {
    //Check if the startup file exists, if it does delete it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self assertionStoreFilePath]]) {
        
        //remove startup file
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self assertionStoreFilePath] error:error];
        
        if (!success) {
            NSLog(@"Assertion Store Error: assertion file cannot be deleted.");
            
            if (*error) {
                return;
            }
            else {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSFileReadCorruptFileError
                                         userInfo:@{@"More Information": @"Assertion Store File JSON cannot be deleted."}];
                return;
            }
        }
    }
    
    self.currentStore = nil;
}


// Assertion Store File Path
- (NSString *)assertionStoreFilePath {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our startup file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kAssertionStoreFileName];
}



// Get the startup file
- (BEAssertionStore *)getAssertionStoreWithError:(NSError **)error {
    
    // Check if the assertion file exists
    
    // Print out the assertion file path
    //NSLog(@"Assertion File Path: %@", filePath);
    
    // Did we already create a startup store instance of the object?
    if(self.currentStore == nil || !self.currentStore){
        
        // Check if the assertion file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self assertionStoreFilePath]]) {
            
            // Startup file does NOT exist (yet)
            BEAssertionStore *assertionStore = [[BEAssertionStore alloc] init];
            
            // Set the current store
            self.currentStore = assertionStore;
            
            // Save the file
            [self setAssertionStoreWithError:error];
            
            // Check for errors
            if (*error || *error != nil) {
                
                // Encountered an error saving the file
                return nil;
                
            }
            
            // Saved the file, no errors, return the reference
            return assertionStore;
            
        } else {
            
            // Assertion file does exist, just not yet parsed
            
            // Get the contents of the file
            NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self assertionStoreFilePath]]
                                                                       options:NSJSONReadingMutableContainers error:error];
            
            // Check the parsed startup file
            if (jsonParsed.count < 1 || jsonParsed == nil) {
                
                // Check if the error is set
                if (!*error || *error == nil) {
                    
                    // Assertion store came back empty, and so did the error
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Assertion Store Failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse assertion store, unknown error", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try fixing the format of the assertion store", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"Parse Assertion Store Failed: %@", errorDetails);
                    
                    // Don't return anything
                    return nil;
                }
            }
            
                // Map BioEncrypt Assertion Store Class
            DCArrayMapping *mapper = [DCArrayMapping mapperForClassElements:[BEStoredTrustFactorObject class] forAttribute:kStoredTrustFactorObjectMapping onClass:[BEAssertionStore class]];
            DCArrayMapping *mapper2 = [DCArrayMapping mapperForClassElements:[BEStoredAssertion class] forAttribute:kAssertionObjectMapping onClass:[BEStoredTrustFactorObject class]];
                
                // Set up the parser configuration for json parsing
            DCParserConfiguration *config = [DCParserConfiguration configuration];
                [config addArrayMapper:mapper];
                [config addArrayMapper:mapper2];
                
                // Set up the date parsing configuration
                config.datePattern = OMDateFormat;
                
                // Set the parser and include the configuration
                DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BEAssertionStore class] andConfiguration:config];
                
                // Get the policy from the parsing
                BEAssertionStore *store = [parser parseDictionary:jsonParsed];

            
            // Make sure the class is valid
            if (!store || store == nil) {
                
                // Assertion store Class is invalid!
                
                // Assertion store came back empty, and so did the error
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Parse Assertion Store Failed", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to parse assertion store, unknown error", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try fixing the format of the assertion store", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnknownError userInfo:errorDetails];
                
                // Log it
                NSLog(@"Parse Assertion Store Failed: %@", errorDetails);
                
                // Don't return anything
                return nil;

                
            }
            
            // Return the object
            self.currentStore = store;
            return self.currentStore;
            
        }
        
        
    }
    else{
        return self.currentStore;
    }
    
    // Not found
    return nil;
}


    
// Set the assertion file
- (void)setAssertionStoreWithError:(NSError **)error {
    
    // Make sure the class is valid
    if (!self.currentStore || self.currentStore == nil) {
        
        // Startup Class is invalid!
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Assertion Store File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Assertion Store Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid assertion store object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
    }
    
    // Save the assertion store file to disk (as json)
    NSData *data = [self.currentStore JSONData];
    
    // Validate the data
    if (!data || data == nil) {
        
        
        // No valid assertion store
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Assertion Store File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Assertion store class reference does not parse to JSON correctly", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid JSON assertion store object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
    }
    
    // Write the data out to the path
    BOOL outFileWrite = [data writeToFile:[self assertionStoreFilePath] options:NSDataWritingFileProtectionComplete error:error];
    
    // Validate that the write was successful
    if (!outFileWrite ) {
        
        // Check if error passed back was empty
        if (!*error || *error == nil) {
            
            // Unable to write out startup file!!
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Assertion Store file", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write assertion file", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct assertion store to write out.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToWriteStore userInfo:errorDetails];
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);
        
    }
    
}



@end
