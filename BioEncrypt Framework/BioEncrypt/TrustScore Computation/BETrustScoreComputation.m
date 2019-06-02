//
//  BETrustScoreComputation.m
//  BioEncrypt
//
//

#import "BETrustScoreComputation.h"
#import "BEConstants.h"
#import "BETrustFactor.h"
#import "BETrustFactorStorage.h"
#import "BEClassification.h"
#import "BESubclassification.h"

// GUI
#import "BESubClassResult_Object.h"


// Transparent Authentication
#import "BETransparentAuthentication.h"


// Categories
#import "BEClassification+Computation.h"
#import "BESubclassification+Computation.h"

@implementation BETrustScoreComputation

@synthesize systemScore = _systemScore, userScore = _userScore, deviceScore = _deviceScore;

/* calulate partial weight with formula:
 penaltyPercent (X) = (maxDecayMeter - X) / (maxDecayMeter - decayMeterThreshold)
 
 where:
 - penaltyPercent is function calculated in interval between 0.0 and 1.0, where 1 present 100%.
 - maxDecayMeter - decayMeter of the first (biggest) stored assertion
 - decayMeterThreshold - decayMeter defined in the policy
 - X - decayMeter of the chosen assertion
 */


/* To understand why we are adding all trustfactoroutputobjects to the transparent key
 * regardless of whether they actually matched something think about the process that takes place
 * during transparent auth:
 *
 *  1) TrustScore is high so candidate transparent key is constructed
 *  2) On the following successful login by user we get access to MASTER_KEY
 *  3) we now actually create the transparent key AND all the trustfactors that were not
 *      matching when we created the canidate key are now whitelisted
 *  4) this is where a problem can reside, our cadidate key now does not include
 *      trustfactors that we just whitelisted, this means once those trustfactor assertions
 *      match the next time, the previously created transparent key will not work
 *
 *  As a result, we add all user trustfactors, regardless of match to the candidate key
 *  this prevents that situation and also allows us opportunity to add system trustfactors
 *  adding system trustfactors adds security as it ensures that if the system changes (such as compromise)
 *  the transparent keys will no longer work. We're not currently doing this because it complicates
 *  debugging transparent auth for performance reasons. Currently its just user.
 *
 */

+ (double) weightPercentForTrustFactorOutputObject: (BETrustFactorOutputObject *) trustFactorOutputObject  {
    // Partial penalities work well for TrustFactors that are likely to exhaust all possiblities, this allows us
    // to apply a relative weight based on the other stored assertions. For TrustFactors that will never exhaust
    // such as Bluetooth or WiFi this is not necessary. The risk when applied to TrustFactors that don't exhaust
    // is such that if one particular WiFi AP or Bluetooth device is used heavily the others diminish in value
    // for example, only applying 4% of their value even though this is a paired device that we automatically trust
    
    BEStoredAssertion *highestStoredAssertion = trustFactorOutputObject.storedTrustFactorObject.assertionObjects.firstObject;
    BEStoredAssertion *highestMatchingAssertion;
    
    // If there is more than one matched assertion use the one with highest decay metric (biggest score boost)
    // This generally only comes into play with bluetooth scanning
    double highestStoredAssertionDecayMetric = highestStoredAssertion.decayMetric;
    double trustFactorPolicyDecayMetric = trustFactorOutputObject.trustFactor.decayMetric.doubleValue;
    double currentAssertionDecayMetric = 0;
    
    if(trustFactorOutputObject.storadeAssertionObjectsMatched.count > 1){
        
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                     ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        NSArray *sortedArray;
        
        // Sort the array
        sortedArray = [trustFactorOutputObject.storadeAssertionObjectsMatched sortedArrayUsingDescriptors:sortDescriptors];
        
        highestMatchingAssertion = sortedArray.firstObject;
        currentAssertionDecayMetric = highestMatchingAssertion.decayMetric;
        
        
    }
    else{
        
        highestMatchingAssertion = trustFactorOutputObject.storadeAssertionObjectsMatched.firstObject;
        currentAssertionDecayMetric = highestMatchingAssertion.decayMetric;
        
    }
   
       //abs just in case highest stored is ever less than current
    double percent = fabs(1-((highestStoredAssertionDecayMetric - currentAssertionDecayMetric) / (highestStoredAssertionDecayMetric - trustFactorPolicyDecayMetric)));
    
    return percent;
    
    // If there is more than one matched assertion, average the decay metrics
    /*
    
    double currentAssertionDecayMetricTotal = 0;
    double currentAssertionDecayMetricAverage = 0;
    double highestStoredAssertionDecayMetric = highestStoredAssertion.decayMetric;
    double trustFactorPolicyDecayMetric = trustFactorOutputObject.trustFactor.decayMetric.doubleValue;
    
    for(BEStoredAssertion *matchedStoredAssertion in trustFactorOutputObject.storadeAssertionObjectsMatched) {
        currentAssertionDecayMetricTotal = currentAssertionDecayMetricTotal + matchedStoredAssertion.decayMetric;
    }
    
    currentAssertionDecayMetricAverage = currentAssertionDecayMetricTotal / trustFactorOutputObject.storadeAssertionObjectsMatched.count;
    
    //abs just in case highest stored is ever less than current
    double percent = fabs(1-((highestStoredAssertionDecayMetric - currentAssertionDecayMetricAverage) / (highestStoredAssertionDecayMetric - trustFactorPolicyDecayMetric)));
    
    return percent;
     
     */
    
}


// Compute the systemScore and the UserScore from the policy
+ (instancetype)performTrustFactorComputationWithPolicy:(BEPolicy *)policy withTrustFactorOutputObjects:(NSArray *)trustFactorOutputObjects withError:(NSError **)error {
    
    // Make sure we got a policy
    if (!policy || policy == nil || policy.policyID < 0) {
        
        // Error out, no trustfactors set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Policy Provided.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to set TrustFactors.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing a policy to set TrustFactors.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SACoreDetectionNoPolicyProvided userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Policy Provided: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Error out, no assertion objects set
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No TrustFactorOutputObjects found to compute.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to set assertion objects.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing trustFactorOutputObjects.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SANoTrustFactorOutputObjectsReceived userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No TrustFactorOutputObjects found to compute: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate the classifications
    if (!policy.classifications || policy.classifications.count < 1) {
        
        // Failed, no classifications found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Classifications Found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to find classifications in the policy.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking if the policy has valid classifications.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SANoClassificationsFound userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Classifications Found: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // Validate the subclassifications
    if (!policy.subclassifications || policy.subclassifications.count < 1) {
        
        // Failed, no classifications found
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No Subclassifications found.", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to find subclassifications in the policy.", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking if the policy has valid subclassifications.", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SANoSubClassificationsFound userInfo:errorDetails];
        
        // Log Error
        NSLog(@"No Subclassifications Found: %@", errorDetails);
        
        // Don't return anything
        return nil;
    }
    
    // DEBUG lists attached Per-Class
    NSMutableArray *trustFactorsNotLearnedInClass;
    NSMutableArray *trustFactorsAttributingToScoreInClass;
    NSMutableArray *trustFactorsWithErrorsInClass;
    
    // Per-Class TrustFactor sorting
    NSMutableArray *trustFactorsInClass;
    NSMutableArray *subClassesInClass; //User for score computation later
    NSMutableArray *trustFactorsToWhitelistInClass;
    NSMutableArray *trustFactorsForTransparentAuthInClass;
    
    // Per-Class list of subClassResultObjects
    NSMutableArray *subClassResultObjectsInClass;
    
    // Per-Class issue/suggestion reporting
    NSMutableArray *trustFactorSuggestionsInClass;
    NSMutableArray *trustFactorIssuesInClass;
    
    // Per-Subclass TrustFactor sorting
    NSMutableArray *trustFactorsInSubClass;

    
    // Per-Subclass issue/suggestion reporting
    NSMutableArray *trustFactorSuggestionsInSubClass;
    NSMutableArray *trustFactorIssuesInSubClass;
    
    // Per-Subclass  errors
    NSMutableArray *subClassDNECodes;
    
    // Per-Subclass indicators
    // Used to avoid creating a subclass result object if no TFs existed in it
    BOOL subClassContainsTrustFactor;
    
    // Determines if any error existed in any TF within the subclass
    BOOL subClassAnalysisIncomplete;
    
    // Determines if all of the trustfactors in the subclass are learned
    BOOL subClassIsFullyLearned;
    
    
    // For each classification in the policy
    for (BEClassification *class in policy.classifications) {
        
        // Per-Class TrustFactor sorting
        trustFactorsInClass = [NSMutableArray array];
        subClassesInClass = [NSMutableArray array];
        trustFactorsToWhitelistInClass = [NSMutableArray array];
        
        // Per-Class list of subClassResultObjects
        subClassResultObjectsInClass = [NSMutableArray array];
        
        // Per-Class issue/suggestion reporting
        trustFactorSuggestionsInClass = [NSMutableArray array];
        trustFactorIssuesInClass = [NSMutableArray array];
        
        // Transparent auth
        trustFactorsForTransparentAuthInClass = [NSMutableArray array];
        
        // DEBUG
        trustFactorsNotLearnedInClass = [NSMutableArray array];
        trustFactorsAttributingToScoreInClass = [NSMutableArray array];
        trustFactorsWithErrorsInClass = [NSMutableArray array];
        
        // Run through all the subclassifications that are in the policy
        for (BESubclassification *subClass in policy.subclassifications) {
            
            // Zero out subclass score for each classification
            subClass.score = 0;
            subClass.totalPossibleScore = 0;
            
            // Per-Subclass TrustFactor sorting
            trustFactorsInSubClass = [NSMutableArray array];
            
            // Per-Subclass issues/suggestions
            trustFactorIssuesInSubClass = [NSMutableArray array];
            trustFactorSuggestionsInSubClass = [NSMutableArray array];
            
            // Used to avoid creating a subclass result object if no TFs existed in it
            subClassContainsTrustFactor=NO;
            
            // Determines if any error existed in any TF within the subclass
            subClassAnalysisIncomplete=NO;
            
            // Determines if all of the trustfactors in the subclass are learned
            subClassIsFullyLearned=YES;
            
            // Keep list of all errors occured inside a subclass
            subClassDNECodes = [NSMutableArray array];
            
            // Run through all trustfactors
            for (BETrustFactorOutputObject *trustFactorOutputObject in trustFactorOutputObjects) {
                
                // Check if the TF class id and subclass id match (we may have no TFs in the current subclass otherwise)
                if (([trustFactorOutputObject.trustFactor.classID intValue] == [[class identification] intValue]) && ([trustFactorOutputObject.trustFactor.subClassID intValue] == [[subClass identification] intValue])) {
                    
                    //At least one TF exists in this subclass
                    subClassContainsTrustFactor=YES;
                    
                    // Blended user+system subclass totalPossible (not really user anymore)
                    subClass.totalPossibleScore = subClass.totalPossibleScore + [trustFactorOutputObject.trustFactor.weight integerValue];
                    

                    
                    // Ignores TFs that have no output,not learned, etc determined during baseline analysis
                    if(trustFactorOutputObject.forComputation==YES){
                        
                        // Check if the TF was executed successfully
                        if (trustFactorOutputObject.statusCode == DNEStatus_ok) {
                            
                            // Do not count TF if its not learned yet
                            if(trustFactorOutputObject.storedTrustFactorObject.learned==NO){
                                
                                // Update, to be used during gui object creation and reflected in status
                                subClassIsFullyLearned=NO;
                                
                                // We still want to add assertions to the store while its in learning mode
                                [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                                
                                //FOR DEBUG OUTPUT
                                [trustFactorsNotLearnedInClass addObject:trustFactorOutputObject];
                                
                                //go to next TF
                                continue;
                            }
                            
                            if(trustFactorOutputObject.matchFound==YES){
                                

                                // If the computation method is 1 (additive score) (e.g., only User anomaly uses this)
                                if([[class computationMethod] intValue]==1){
                                    

                                    //Add  TF to attributing list
                                    [trustFactorsAttributingToScoreInClass addObject:trustFactorOutputObject];
                                
                                    
                                    // Determine if the TF should apply partial weight or full weight
                                    if([trustFactorOutputObject.trustFactor.partialWeight intValue]==1){
                                        
                                        // apply partial weight of TF
                                        double percent = [self weightPercentForTrustFactorOutputObject:trustFactorOutputObject];
                                        NSInteger partialWeight = (NSInteger)(percent * trustFactorOutputObject.trustFactor.weight.integerValue);
                                        subClass.score = (subClass.score + partialWeight);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = partialWeight;
                                        trustFactorOutputObject.percentAppliedWeight = percent;
                                        
                                        // apply issues and suggestions even though there was a match if the partial weight is very low comparatively such that the user knows how to improve score
                                        
                                        if(partialWeight < (trustFactorOutputObject.trustFactor.weight.integerValue * 0.25)){
                                            
                                            // Add issues and suggestions for all TrustFactors since no match is always a bad thing
                                            // Check if the TF contains a custom issue message
                                            if(trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage.length != 0)
                                            {
                                                // Check if we already have the issue in the our list
                                                if(![trustFactorIssuesInSubClass containsObject:trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage]){
                                                    
                                                    // Add it
                                                    [trustFactorIssuesInSubClass addObject:trustFactorOutputObject.trustFactor.lowConfidenceIssueMessage];
                                                }
                                            }
                                            
                                            // Check if the TF contains a custom suggestion message
                                            if(trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage.length != 0)
                                            {
                                                // Check if the we already have the issue in our list
                                                if(![trustFactorSuggestionsInSubClass containsObject:trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage]){
                                                    
                                                    // Add it
                                                    [trustFactorSuggestionsInSubClass addObject:trustFactorOutputObject.trustFactor.lowConfidenceSuggestionMessage];
                                                }
                                            }
                                        }
                                        
                                        /*
                                         * Transparent Auth Elections
                                         */
                                        
                                        if(trustFactorOutputObject.trustFactor.transparentEligible.intValue == 1){
                                            
                                            // Removed denial of partial weight trustfactors into the transparent key, this causes transparent auth not function as often
                                            //if(partialWeight >= (trustFactorOutputObject.trustFactor.weight.integerValue * 0.25)){
                                                
                                                // Avoids making transparent keys from values that may be sledom hit again
                                                // Add TF to transparent auth list
                                                [trustFactorsForTransparentAuthInClass addObject:trustFactorOutputObject];
                                                
                                        }
  

                                    }else{ //end partial weight calculation
                                        
                                        
                                        
                                        /*
                                         * Transparent Auth Elections
                                         */
                                        
                                        // This is not a partial weighted rule, always add these to transparent auth
                                        // Avoids making transparent keys that are sledom to be hit again
                                        // Add TF to transparent auth list
                                        if(trustFactorOutputObject.trustFactor.transparentEligible.intValue == 1){
                                            [trustFactorsForTransparentAuthInClass addObject:trustFactorOutputObject];
                                            
                                            
                                        }
                                        
                                        // apply full weight of TF
                                        subClass.score = (subClass.score + trustFactorOutputObject.trustFactor.weight.integerValue);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = trustFactorOutputObject.trustFactor.weight.integerValue;
                                        trustFactorOutputObject.percentAppliedWeight = 1;
                                    }
                                    
                                    
                                    
                                }else{
                                    
                                    // Computation method of 0 (subtractive score) does nothing when a match is found
                                    
                                }
                                
                                
                                
                                
                                
                            }
                            else{ // No Match found
                                
                                
                                
                                // If no match found, regardless of TF type - they are added to whitelist if "whitelistable"
                                
                                if(trustFactorOutputObject.trustFactor.whitelistable.intValue == 1) {
                                    
                                [trustFactorsToWhitelistInClass addObject:trustFactorOutputObject];
                                    
                                }
                                

                                
                                // If the computation method is 0 (subtractive scoring) (e.g., System classifications and User Policy)
                                if([[class computationMethod] intValue]==0){
                                    
                                    // Add to triggered list
                                    [trustFactorsAttributingToScoreInClass addObject:trustFactorOutputObject];
                                    
                                    // Determine if the TF should apply partial weight or full weight
                                    if([trustFactorOutputObject.trustFactor.partialWeight intValue]==1){
                                        
                                        // apply partial weight of TF
                                        double percent = [self weightPercentForTrustFactorOutputObject:trustFactorOutputObject];
                                        NSInteger partialWeight = (NSInteger)(percent * trustFactorOutputObject.trustFactor.weight.integerValue);
                                        subClass.score = (subClass.score + partialWeight);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = partialWeight;
                                        trustFactorOutputObject.percentAppliedWeight = percent;
                                        
                                        
                                        
                                    }else{
                                        
                                        // apply full weight of TF
                                        subClass.score = (subClass.score + trustFactorOutputObject.trustFactor.weight.integerValue);
                                        
                                        // Stored for debug purposes
                                        trustFactorOutputObject.appliedWeight = trustFactorOutputObject.trustFactor.weight.integerValue;
                                        trustFactorOutputObject.percentAppliedWeight = 1;
                                    }
                                }
                                else{
                                    // Computation method of 1 (additive scoring) does nothing when there is no match found
                                }
                                
                                // Add issues and suggestions for all TrustFactors since no match is always a bad thing
                                // Check if the TF contains a custom issue message
                                if(trustFactorOutputObject.trustFactor.notFoundIssueMessage.length != 0)
                                {
                                    // Check if we already have the issue in the our list
                                    if(![trustFactorIssuesInSubClass containsObject:trustFactorOutputObject.trustFactor.notFoundIssueMessage]){
                                        
                                        // Add it
                                        [trustFactorIssuesInSubClass addObject:trustFactorOutputObject.trustFactor.notFoundIssueMessage];
                                    }
                                }
                                
                                // Check if the TF contains a custom suggestion message
                                if(trustFactorOutputObject.trustFactor.notFoundSuggestionMessage.length != 0)
                                {
                                    // Check if the we already have the issue in our list
                                    if(![trustFactorSuggestionsInSubClass containsObject:trustFactorOutputObject.trustFactor.notFoundSuggestionMessage]){
                                        
                                        // Add it
                                        [trustFactorSuggestionsInSubClass addObject:trustFactorOutputObject.trustFactor.notFoundSuggestionMessage];
                                    }
                                }
                                
                                
                            } // End No Match found
                            
                            
                            // TrustFactor did not run successfully -> Did Not Execute
                        } else {
                            
                            // FOR DEBUG OUTPUT
                            [trustFactorsWithErrorsInClass addObject:trustFactorOutputObject];
                            
                            // Record all DNE status codes within the subclass
                            [subClassDNECodes addObject:[NSNumber numberWithInt:trustFactorOutputObject.statusCode]];
                            
                            // Mark subclass as incomplete since not all TFs ran
                            subClassAnalysisIncomplete=YES;
                            
                            // If a user TrustFactor than only add suggestions, no weight is applied (since that would boost the score)
                            if ([[class computationMethod] intValue]==1){
                                
                                [self addSuggestionsForSubClass:subClass withSuggestions:trustFactorSuggestionsInSubClass forTrustFactorOutputObject:trustFactorOutputObject];
                                
                            }
                            // Record suggetions AND apply modified DNE penalty (SYSTEM classes only)
                            else if([[class computationMethod] intValue]==0)
                            {
                                
                                // Do not penalize for WiFi rules that did not run within system-based classifications
                                // This is because WiFi is considered dangerous from a system perspective and should not penalize
                                if (![subClass.name containsString:@"WiFi"]) {
                                    
                                    [self addSuggestionsAndCalcWeightForSubClass:subClass withPolicy:policy withSuggestions:trustFactorSuggestionsInSubClass forTrustFactorOutputObject:trustFactorOutputObject];
                                    
                                }
                                
                                
                            }
                        }
                        
                        
                        // Add TrustFactor to classification
                        [trustFactorsInClass addObject:trustFactorOutputObject.trustFactor];
                        
                        // Add TrustFactor to subclass
                        [trustFactorsInSubClass addObject:trustFactorOutputObject.trustFactor];
                        
                    }
                    // End if ForComputation
                    
                    
                    
                }
                // End trustfactors loop
                
                
            } // End subclass loop
            

            
            // If any trustFactors existed within this subClass
            if(subClassContainsTrustFactor==YES) {
                
                // Add the subclass issues identified to the overall class
                [trustFactorIssuesInClass addObjectsFromArray:trustFactorIssuesInSubClass];
                [trustFactorSuggestionsInClass addObjectsFromArray:trustFactorSuggestionsInSubClass];
                
                // Create a subclass result object
                BESubClassResult_Object *subClassResultObject = [[BESubClassResult_Object alloc] init];
                
                // Store total possible and score for use when multiple subclass objects are found for hte same subclass and must be merged later
                [subClassResultObject setTotalPossibleScore:subClass.totalPossibleScore];
                [subClassResultObject setTotalScore:subClass.score];
                
                // Set stuff we already know
                [subClassResultObject setClassID:[[class identification] integerValue]];
                [subClassResultObject setSubClassID:[[subClass identification] integerValue]];
                [subClassResultObject setSubClassTitle:subClass.name];
                [subClassResultObject setSubClassIconID:[[subClass iconID] integerValue]];
                [subClassResultObject setSubClassExplanation:subClass.explanation];
                [subClassResultObject setSubClassSuggestion:subClass.suggestion];

                
                // Add issues and suggestions gathered from trustFactors iterated within this subclass
                [subClassResultObject setTrustFactorIssuesInSubClass:trustFactorIssuesInSubClass];
                [subClassResultObject setTrustFactorSuggestionInSubClass:trustFactorSuggestionsInSubClass];
                
                // Save all error codes
                [subClassResultObject setErrorCodes:subClassDNECodes];
                
                // No errors, update analysis message with subclass complete
                if(subClassAnalysisIncomplete==NO) {
                    
                    // Check if TFs didnt run because they were not learned yet to ensure we don't call it trusted
                    if(subClassIsFullyLearned==YES){
                        [subClassResultObject setSubClassStatusText:@"Complete"];
                    }
                    else{
                        // set status to still learning and untrusted
                        [subClassResultObject setSubClassStatusText:@"Learning"];
                    }

                    
                    // Subclass contains TFs with issues, identify which, if there are multiple the first (higher priority one is used)
                } else {
                    
                    
                    if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_disabled]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Disabled"];

                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_nodata]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Complete"];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unauthorized]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Unauthorized"];

                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_expired]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Expired"];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unsupported]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Unsupported"];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_unavailable]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Unavailable"];
                        
                    }
                    else if([subClassDNECodes containsObject:[NSNumber numberWithInt:DNEStatus_invalid]]){
                        
                        [subClassResultObject setSubClassStatusText:@"Invalid"];
                        
                    }
                    else{
                        
                        [subClassResultObject setSubClassStatusText:@"Error"];
                    }
                    
                }
                
                
                // Add the subclass total weight to the classification's base weight
                class.score = class.score +  (subClass.score * [subClass.weight integerValue]);
                
                
                //subClass.totalWeight = (subClass.baseWeight * (1-(0.1 * subClass.weight.integerValue)) );
                
                // Add trustFactors to the list of trusfactors in a subclass
                [subClass setTrustFactors:trustFactorsInSubClass];
                
                // Add the subclass to list of subclasses in class
                [subClassesInClass addObject:subClass];
                
                // Add the subClassResultObjects to the class
                [subClassResultObjectsInClass addObject:subClassResultObject];
            }
            
            // End subclassifications loop
        }
        
        // Link subclassification list to classification
        [class setSubClassifications:subClassesInClass];
        
        // Link trustfactors to the classification
        [class setTrustFactors:trustFactorsInClass];
        
        // Add the trustfactors for protect mode to the classification
        [class setTrustFactorsToWhitelist:trustFactorsToWhitelistInClass];
        
        // Add the trustfactor for transparent auth to the classification
        [class setTrustFactorsForTransparentAuthentication:trustFactorsForTransparentAuthInClass];
        
        // Set GUI elements
        [class setSubClassResultObjects:subClassResultObjectsInClass];
        
        // Set debug elements
        [class setTrustFactorsNotLearned:trustFactorsNotLearnedInClass];
        [class setTrustFactorsTriggered:trustFactorsAttributingToScoreInClass];
        [class setTrustFactorsWithErrors:trustFactorsWithErrorsInClass];
        
        // Set issue/suggestion elements
        [class setTrustFactorIssues:trustFactorIssuesInClass];
        [class setTrustFactorSuggestions:trustFactorSuggestionsInClass];
        
        
    }// End classifications loop
    
    // Perform class-level computation
    
    // Object to return
    BETrustScoreComputation *computationResults = [[BETrustScoreComputation alloc]init];
    
    //computationResults.policy = policy;
    
    // GUI subClassResultObjects - System
    NSMutableSet *systemSubClassResultObjects = [[NSMutableSet alloc] init];
    
    // GUI subClassResultObjects - User
    NSMutableSet *userSubClassResultObjects = [[NSMutableSet alloc] init];
    
    // TrustFactor Sorting - System
    NSMutableArray *systemTrustFactorsAttributingToScore = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *systemAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorIssues = [[NSMutableArray alloc] init];
    NSMutableArray *systemTrustFactorSuggestions = [[NSMutableArray alloc] init];
    
    // TrustFactor Sorting - User
    NSMutableArray *userTrustFactorsAttributingToScore = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsNotLearned = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsWithErrors = [[NSMutableArray alloc] init];
    NSMutableArray *userAllTrustFactorOutputObjects = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorsToWhitelist = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorIssues = [[NSMutableArray alloc] init];
    NSMutableArray *userTrustFactorSuggestions = [[NSMutableArray alloc] init];
    
    // Transparent authentication
    NSMutableArray *allTrustFactorsForTransparentAuthentication = [[NSMutableArray alloc] init];
    
    int systemTrustScoreSum = 0;
    
    int userTrustScoreSum = 0;
    
    BOOL systemPolicyViolation=NO;
    BOOL userPolicyViolation=NO;
    
    
    // Iterate through all classifications populated in prior function
    for (BEClassification *class in policy.classifications) {
        
        // If its a system class
        if ([[class type] intValue] == 0) {
            
            // Calculate total penalty for System classifications
            systemTrustScoreSum = systemTrustScoreSum + (int)[class score];
            
            int currentScore=0;
            // This method starts at 100 and goes down to 0
            if([[class computationMethod] intValue] == 0){
                currentScore = MIN(100,MAX(0,100-(int)[class score]));
            }
            // This method starts at 0 and goes to 100
            else if([[class computationMethod] intValue] == 1){
                currentScore = MIN(100,(int)[class score]);
            }
            
            
            // Calculate individual class penalties
            switch ([[class identification] intValue]) {
                    
                case 1:
                    computationResults.systemBreachClass = class;
                    computationResults.systemBreachScore = currentScore;
                    break;
                    
                case 2:
                    computationResults.systemPolicyClass = class;
                    computationResults.systemPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        systemPolicyViolation=YES;
                    }
                    break;
                    
                case 3:
                    computationResults.systemSecurityClass = class;
                    computationResults.systemSecurityScore = currentScore;
                    break;
                default:
                    break;
            }
            
            // Tally system GUI elements
            // iterate through existing to ensure to check for duplicates
            BOOL exists;
            NSInteger percentOfTrust;
            for(BESubClassResult_Object *resultObjectInClass in [class subClassResultObjects]){
                
                exists=NO;
                for(BESubClassResult_Object *resultObjectInSystem in systemSubClassResultObjects){
                    
                    // If the object already exists in the total system tally then merge and update existing resultObjectInSystem
                    if([resultObjectInClass subClassID] == [resultObjectInSystem subClassID]){
                        exists=YES;
                        NSMutableArray *mutableArray;
                        NSOrderedSet *orderedSet;
                        
                        //merge trust percent
                        // Calculate trust percent for htis object only
                        // Should always be > 0 otherwise must be a policy error
                       if((resultObjectInClass.totalPossibleScore + resultObjectInSystem.totalPossibleScore) > 0){
                            
                            // Update resultObjectInSystem totalPossibleScore by adding current
                            [resultObjectInSystem setTotalPossibleScore:([resultObjectInSystem totalPossibleScore] + [resultObjectInClass totalPossibleScore])];
                            
                            // Update resultObjectInClass totalScore by adding current
                            [resultObjectInSystem setTotalScore:([resultObjectInSystem totalScore] + [resultObjectInClass totalScore])];
                            
                            percentOfTrust = ((resultObjectInSystem.totalScore / (float)resultObjectInSystem.totalPossibleScore)*100);
                            
                            //percentOfTrust = ((resultObjectInSystem.totalScore / (float)100)*100);
                        
                        // Divide by total curren amount of reduction in the system score
                        
                        //percentOfTrust = ((resultObjectInSystem.totalScore / (float)systemTrustScoreSum)*100);
                        
                        }
                        else{
                            percentOfTrust = 0;
                        }
                        
                        // Since this is the system class (non-additive scoring), we need to subtract from 1
                        percentOfTrust = 100 - percentOfTrust;
                        
                        // Updated percent of trust for GUI use
                        [resultObjectInSystem setTrustPercent:percentOfTrust];
                        
                        //merge issues
                        //mutuable version of  issues in current subclass array
                        mutableArray = [[resultObjectInClass trustFactorIssuesInSubClass] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInSystem trustFactorIssuesInSubClass]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        //Update the existing resultObjectInSystem object with the merged issues list
                        [resultObjectInSystem setTrustFactorIssuesInSubClass:orderedSet.array];
                        
                        
                        //merge suggestions
                        //mutuable version of  issues in current subclass array
                        mutableArray = [[resultObjectInClass trustFactorSuggestionInSubClass] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInSystem trustFactorSuggestionInSubClass]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        //Update the existing resultObjectInSystem object with the merged issues list
                        [resultObjectInSystem setTrustFactorSuggestionInSubClass:orderedSet.array];
                        
                        
                        //determine status text
                        //if the new subClass is not complete override the exisitng
                        if (![[resultObjectInClass subClassStatusText] isEqualToString:@"Complete"]){
                            
                            // update the existing with the class version
                            [resultObjectInSystem setSubClassStatusText:[resultObjectInClass subClassStatusText]];
                        }
                        
                        //merge status codes
                        mutableArray = [[resultObjectInClass errorCodes] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInSystem errorCodes]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        [resultObjectInSystem setErrorCodes:orderedSet.array];

                    }
                }
                
                if(exists==NO){
                    // Calculate trust percent for htis object only
                    // Should always be > 0 otherwise must be a policy error
                    if(resultObjectInClass.totalPossibleScore > 0){
                        
                        percentOfTrust = ((resultObjectInClass.totalScore / (float)resultObjectInClass.totalPossibleScore)*100);
                    
                    
                        //percentOfTrust = ((resultObjectInClass.totalScore / (float)100)*100);
                    
                    
                    // Divide by total curren amount of reduction in the system score
                    
                    //percentOfTrust = ((resultObjectInClass.totalScore / (float)systemTrustScoreSum)*100);
                    }
                    else{
                        percentOfTrust = 0;
                    }
                    
                    // Since this is the system class (non-additive scoring, we need to subtract from 1
                    percentOfTrust = 100 - percentOfTrust;
                    
                    // Updated percent of trust for GUI use
                    resultObjectInClass.trustPercent = percentOfTrust;
                    
                    // add to list
                    [systemSubClassResultObjects addObject:resultObjectInClass];
                }
  
            }

            
            //[systemSubClassResultObjects addObjectsFromArray:[class subClassResultObjects]];
            
            // Tally system issues
            [systemTrustFactorIssues addObjectsFromArray:[class trustFactorIssues]];
            
            // Tally system suggestions
            [systemTrustFactorSuggestions addObjectsFromArray:[class trustFactorSuggestions]];
            
            // Tally system debug data
            [systemTrustFactorsAttributingToScore addObjectsFromArray:[class trustFactorsTriggered]];
            [systemTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [systemTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [systemAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [systemTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
            
            // Add all transparent authentication trustfactors together
            [allTrustFactorsForTransparentAuthentication addObjectsFromArray:[class trustFactorsForTransparentAuthentication]];
            
            // When it's a user class
        } else {
            
            // Calculate total weight for User classifications
            userTrustScoreSum = userTrustScoreSum + (int)[class score];
            
            int currentScore=0;
            // This method starts at 100 and goes down to 0
            if([[class computationMethod] intValue] == 0){
                currentScore = MIN(100,MAX(0,100-(int)[class score]));
            }
            // This method starts at 0 and goes to 100
            else if([[class computationMethod] intValue] == 1){
                currentScore = MIN(100,(int)[class score]);
            }
            
            switch ([[class identification] intValue]) {
                    
                case 4:
                    
                    computationResults.userPolicyClass = class;
                    computationResults.userPolicyScore = currentScore;
                    
                    // Don't add policy scores to overall as it just inflates it
                    if(currentScore < 100){
                        userPolicyViolation=YES;
                    }
                    break;
                    
                    
                case 5:
                    computationResults.userAnomalyClass = class;
                    computationResults.userAnomalyScore = currentScore;
                    break;
                default:
                    break;
            }
            
            // Tally user GUI elements

            // iterate through existing to ensure to check for duplicates
            BOOL exists;
            NSInteger percentOfTrust;
            for(BESubClassResult_Object *resultObjectInClass in [class subClassResultObjects]){
                
                exists=NO;
                for(BESubClassResult_Object *resultObjectInUser in userSubClassResultObjects){
                    
                    // If the object already exists in the total system tally then merge and update existing resultObjectInSystem
                    if([resultObjectInClass subClassID] == [resultObjectInUser subClassID]){
                        exists=YES;
                        NSMutableArray *mutableArray;
                        NSOrderedSet *orderedSet;
                        
 
                        

                        //merge trust percent
                        // Calculate trust percent for htis object only
                        // Should always be > 0 otherwise must be a policy error
                        if((resultObjectInClass.totalPossibleScore + resultObjectInUser.totalPossibleScore) > 0){
                            
                            
                            //If this is Bluetooth total possible is simply the highest single TF is the total possible
                            //Hardcoded for pilot purposes
                            
                            if(resultObjectInUser.subClassID == 8){
                                
                                // Update resultObjectInSystem totalPossibleScore by adding current
                                [resultObjectInUser setTotalPossibleScore:30];
                                
                            }
                            else{
                                
                                // Update resultObjectInSystem totalPossibleScore by adding current
                                [resultObjectInUser setTotalPossibleScore:([resultObjectInUser totalPossibleScore] + [resultObjectInClass totalPossibleScore])];
                                
                            }
                            
                            // Update resultObjectInClass totalScore by adding current
                            [resultObjectInUser setTotalScore:([resultObjectInUser totalScore] + [resultObjectInClass totalScore])];
                            
                            percentOfTrust = ((resultObjectInUser.totalScore / (float)resultObjectInUser.totalPossibleScore)*100);
                        }
                        else{
                            percentOfTrust = 0;
                        }
                        
                        // Updated percent of trust for GUI use
                        [resultObjectInUser setTrustPercent:percentOfTrust];
                        
                        //merge issues
                        //mutuable version of  issues in current subclass array
                        mutableArray = [[resultObjectInClass trustFactorIssuesInSubClass] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInUser trustFactorIssuesInSubClass]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        //Update the existing resultObjectInSystem object with the merged issues list
                        [resultObjectInUser setTrustFactorIssuesInSubClass:orderedSet.array];
                        
                        
                        //merge suggestions
                        //mutuable version of  issues in current subclass array
                        mutableArray = [[resultObjectInClass trustFactorSuggestionInSubClass] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInUser trustFactorSuggestionInSubClass]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        //Update the existing resultObjectInSystem object with the merged issues list
                        [resultObjectInUser setTrustFactorSuggestionInSubClass:orderedSet.array];
                        
                        
                        //determine status text
                        //if the new subClass is not complete override the exisitng
                        if (![[resultObjectInClass subClassStatusText] isEqualToString:@"Complete"]){
                            
                            // update the existing with the class version
                            [resultObjectInUser setSubClassStatusText:[resultObjectInClass subClassStatusText]];
                        }
                        
                        //merge status codes
                        mutableArray = [[resultObjectInClass errorCodes] mutableCopy];
                        [mutableArray addObjectsFromArray:[resultObjectInUser errorCodes]];
                        // remove dupes
                        orderedSet = [NSOrderedSet orderedSetWithArray:mutableArray];
                        [resultObjectInUser setErrorCodes:orderedSet.array];
                        
                    }
                }
                
                if(exists==NO){
                    // Calculate trust percent for this object only
                    // Should always be > 0 otherwise must be a policy error
                    if(resultObjectInClass.totalPossibleScore > 0){
                        
                        // If Bluetooth use hardcoded total for now and overwrite possible
                        // For pilot purposes
                        if(resultObjectInClass.subClassID == 8){
                            
                            // Update resultObjectInSystem totalPossibleScore by adding current
                            [resultObjectInClass setTotalPossibleScore:30];
                            
                        }
                        
                        percentOfTrust = ((resultObjectInClass.totalScore / (float)resultObjectInClass.totalPossibleScore)*100);
                    }
                    else{
                        percentOfTrust = 0;
                    }
                    
                    // Updated percent of trust for GUI use
                    resultObjectInClass.trustPercent = percentOfTrust;

                    [userSubClassResultObjects addObject:resultObjectInClass];
                }
                
            }

            //[userSubClassResultObjects addObjectsFromArray:[class subClassResultObjects]];
            
            // Tally system issues
            [userTrustFactorIssues addObjectsFromArray:[class trustFactorIssues]];
            
            // Tally system suggestions
            [userTrustFactorSuggestions addObjectsFromArray:[class trustFactorSuggestions]];
            
            // Tally user debug data
            [userTrustFactorsAttributingToScore addObjectsFromArray:[class trustFactorsTriggered]];
            [userTrustFactorsNotLearned addObjectsFromArray:[class trustFactorsNotLearned]];
            [userTrustFactorsWithErrors addObjectsFromArray:[class trustFactorsWithErrors]];
            [userAllTrustFactorOutputObjects addObjectsFromArray:[class trustFactors]];
            
            // Add whitelists together
            [userTrustFactorsToWhitelist addObjectsFromArray:[class trustFactorsToWhitelist]];
            
            // Add all transparent authentication trustfactors together
            [allTrustFactorsForTransparentAuthentication addObjectsFromArray:[class trustFactorsForTransparentAuthentication]];
        }
    }
    
    // Set GUI messages (system)
    computationResults.systemSubClassResultObjects = [systemSubClassResultObjects allObjects];

    // Set GUI messages (user)
    computationResults.userSubClassResultObjects = [userSubClassResultObjects allObjects];
    
    // Set issues (system)
    computationResults.systemIssues = systemTrustFactorIssues;
    
    // Set suggestions (system)
    computationResults.systemSuggestions = systemTrustFactorSuggestions;
    
    // Set issues (user)
    computationResults.userIssues = userTrustFactorIssues;
    
    // Set suggestions (user)
    computationResults.userSuggestions = userTrustFactorSuggestions;

    // Set transparent authentication list
    computationResults.transparentAuthenticationTrustFactorOutputObjects = allTrustFactorsForTransparentAuthentication;
    
    // Set whitelists for system/user domains
    computationResults.userTrustFactorWhitelist = userTrustFactorsToWhitelist;
    computationResults.systemTrustFactorWhitelist = systemTrustFactorsToWhitelist;
    
    // DEBUG: Set trustfactor objects for system/user domains
    computationResults.userAllTrustFactorOutputObjects = userAllTrustFactorOutputObjects;
    computationResults.systemAllTrustFactorOutputObjects = systemAllTrustFactorOutputObjects;
    
    // DEBUG: Set triggered for system/user domains
    computationResults.userTrustFactorsAttributingToScore = userTrustFactorsAttributingToScore;
    computationResults.systemTrustFactorsAttributingToScore = systemTrustFactorsAttributingToScore;
    
    // DEBUG: Set not learned for system/user domains
    computationResults.userTrustFactorsNotLearned = userTrustFactorsNotLearned;
    computationResults.systemTrustFactorsNotLearned = systemTrustFactorsNotLearned;
    
    // DEBUG: Set errored for system/user domains
    computationResults.userTrustFactorsWithErrors = userTrustFactorsWithErrors;
    computationResults.systemTrustFactorsWithErrors = systemTrustFactorsWithErrors;
    
    
    // Set comprehensive scores
    // Gaurantee that a policy violataion will be zero (type 4 rules could technically overpower)
    if(systemPolicyViolation == YES) {
        
        computationResults.systemScore = 0;
        
    } else {
        
        computationResults.systemScore = MIN(100,MAX(0,100 - systemTrustScoreSum));
    }
    
    if (userPolicyViolation == YES) {
        
        computationResults.userScore = 0;
        
    } else {
        
        computationResults.userScore = MIN(100,userTrustScoreSum);
    }
    
    computationResults.deviceScore = (computationResults.systemScore + computationResults.userScore)/2;
    
    
    return computationResults;
}

#pragma mark - Private Helper Methods


+ (void)addSuggestionsForSubClass:(BESubclassification *)subClass withSuggestions:(NSMutableArray *)suggestionsInSubClass forTrustFactorOutputObject:(BETrustFactorOutputObject *)trustFactorOutputObject{
    
    // This is really only for inverse rules, thus we only cover a couple DNE errors
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_unauthorized:
            // Unauthorized
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnauthorized.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInSubClass addObject:subClass.dneUnauthorized];
                }
            }
        case DNEStatus_disabled:
            // Disabled
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneDisabled.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneDisabled]){
                    [suggestionsInSubClass addObject:subClass.dneDisabled];
                }
            }
            break;
        case DNEStatus_expired:
            // Expired
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneExpired.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneExpired]){
                    [suggestionsInSubClass addObject:subClass.dneExpired];
                }
            }
            break;
        case DNEStatus_nodata:
            // Expired
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneNoData.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneNoData]){
                    [suggestionsInSubClass addObject:subClass.dneNoData];
                }
            }
            break;
        case DNEStatus_invalid:
            // Invalid
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneInvalid.length != 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneInvalid]){
                    [suggestionsInSubClass addObject:subClass.dneInvalid];
                }
            }
            break;
        default:
            break;
    }
    
}

// Calculates penalty and adds suggestions
+ (void)addSuggestionsAndCalcWeightForSubClass:(BESubclassification *)subClass withPolicy:(BEPolicy *)policy withSuggestions:(NSMutableArray *)suggestionsInSubClass forTrustFactorOutputObject:(BETrustFactorOutputObject *)trustFactorOutputObject{
    
    // Create an int to hold the dnePenalty multiplied by the modifier
    double penaltyMod = 0;
    
    switch (trustFactorOutputObject.statusCode) {
        case DNEStatus_error:
            // Error
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            
            break;
            
        case DNEStatus_unauthorized:
            
            // Unauthorized
            penaltyMod = [policy.DNEModifiers.unauthorized doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnauthorized.length!= 0) {
                //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneUnauthorized]){
                    [suggestionsInSubClass addObject:subClass.dneUnauthorized];
                }
            }
            
            break;
            
        case DNEStatus_unsupported:
            
            // Unsupported
            penaltyMod = [policy.DNEModifiers.unsupported doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnsupported.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneUnsupported]){
                    [suggestionsInSubClass addObject:subClass.dneUnsupported];
                }
            }
            break;
            
        case DNEStatus_unavailable:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.unavailable doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneUnavailable.length!= 0) {
                
                // Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneUnavailable]){
                    [suggestionsInSubClass addObject:subClass.dneUnavailable];
                }
            }
            break;
            
        case DNEStatus_disabled:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.disabled doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneDisabled.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneDisabled]){
                    [suggestionsInSubClass addObject:subClass.dneDisabled];
                }
            }
            break;
            
        case DNEStatus_nodata:
            
            // Unavailable
            penaltyMod = [policy.DNEModifiers.noData doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneNoData.length!= 0)
            {   //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneNoData]){
                    [suggestionsInSubClass addObject:subClass.dneNoData];
                }
            }
            
            break;
            
        case DNEStatus_expired:
            
            // Expired
            penaltyMod = [policy.DNEModifiers.expired doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneExpired.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneExpired]){
                    [suggestionsInSubClass addObject:subClass.dneExpired];
                }
            }
            
            break;
        case DNEStatus_invalid:
            
            // Expired
            penaltyMod = [policy.DNEModifiers.invalid doubleValue];
            
            // Check if subclass contains custom suggestion for the current error code
            if(subClass.dneInvalid.length!= 0) {
                
                //Does suggestion already exist?
                if(![suggestionsInSubClass containsObject:subClass.dneInvalid]){
                    [suggestionsInSubClass addObject:subClass.dneInvalid];
                }
            }
            
            break;
        default:
            
            // Apply error by default
            penaltyMod = [policy.DNEModifiers.error doubleValue];
            break;
    }
    
    NSInteger weight = (trustFactorOutputObject.trustFactor.weight.integerValue * penaltyMod);
    
    // Apply DNE percent to the TFs normal penalty to reduce it (penaltyMode of 0 negates the rule completely)
    subClass.score = subClass.score + weight;
    
    // For debug;
    trustFactorOutputObject.appliedWeight = weight;
    trustFactorOutputObject.percentAppliedWeight = 1;
    
}

@end
