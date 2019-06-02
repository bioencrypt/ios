//
//  NSDate+TimeElapsed.m
//  BioEncrypt iOS
//
//  Created by Ivo Leko on 18/05/2019.
//

#import "NSDate+TimeElapsed.h"


typedef NS_ENUM(NSUInteger, DateAgoValues){
    YearsAgo,
    MonthsAgo,
    WeeksAgo,
    DaysAgo,
    HoursAgo,
    MinutesAgo,
};

@implementation NSDate (TimeElapsed)


- (NSString *) timeAgoSinceNow {
    NSDate *date = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    
    // if timeAgo < 24h => compare DateTime else compare Date only
    NSUInteger upToHours = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    NSDateComponents *difference = [calendar components:upToHours fromDate:earliest toDate:latest options:0];
    
    if (difference.hour < 24) {
        if (difference.hour >= 1) {
            return [self localizedStringForValueType:HoursAgo value:difference.hour];
        } else if (difference.minute >= 1) {
            return [self localizedStringForValueType:MinutesAgo value:difference.minute];
        } else {
            return @"Just now";
        }
        
    } else {
        NSUInteger bigUnits = NSCalendarUnitTimeZone | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents *components = [calendar components:bigUnits fromDate:earliest];
        earliest = [calendar dateFromComponents:components];
        
        components = [calendar components:bigUnits fromDate:latest];
        latest = [calendar dateFromComponents:components];
        
        difference = [calendar components:bigUnits fromDate:earliest toDate:latest options:0];
        
        if (difference.year >= 1) {
            return [self localizedStringForValueType:YearsAgo value:difference.year];
        } else if (difference.month >= 1) {
            return [self localizedStringForValueType:MonthsAgo value:difference.month];
        } else if (difference.weekOfYear >= 1) {
            return [self localizedStringForValueType:WeeksAgo value:difference.weekOfYear];
        } else {
            return [self localizedStringForValueType:DaysAgo value:difference.day];
        }
    }
}




- (NSString *)localizedStringForValueType:(DateAgoValues)valueType value:(NSInteger)value {
  
    switch (valueType) {
        case YearsAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@years ago" withValue:value];
            } else {
                return @"Last year";
            }
        case MonthsAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@months ago" withValue:value];
            } else {
                return @"Last month";
            }
        case WeeksAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@weeks ago" withValue:value];
            } else {
                return @"Last week";
            }
        case DaysAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@days ago" withValue:value];
            } else {
                return @"Yesterday";
            }
        case HoursAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@hours ago" withValue:value];
            } else {
                return @"An hour ago";
            }
        case MinutesAgo:
            if (value >= 2) {
                return [self logicLocalizedStringFromFormat:@"%%d %@minutes ago" withValue:value];
            } else {
                return @"A minute ago";
            }
    }
    return nil;
}



- (NSString *) logicLocalizedStringFromFormat:(NSString *)format withValue:(NSInteger)value{
    NSString * localeFormat = [NSString stringWithFormat:format, [self getLocaleFormatUnderscoresWithValue:value]];
    return [NSString stringWithFormat:localeFormat, value];
}

- (NSString *)getLocaleFormatUnderscoresWithValue:(double)value{
    NSString *localeCode = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    // Russian (ru) and Ukrainian (uk)
    if([localeCode isEqualToString:@"ru"] || [localeCode isEqualToString:@"uk"]) {
        int XY = (int)floor(value) % 100;
        int Y = (int)floor(value) % 10;
        
        if(Y == 0 || Y > 4 || (XY > 10 && XY < 15)) {
            return @"";
        }
        
        if(Y > 1 && Y < 5 && (XY < 10 || XY > 20))  {
            return @"_";
        }
        
        if(Y == 1 && XY != 11) {
            return @"__";
        }
    }
    
    // Add more languages here, which are have specific translation rules...
    
    return @"";
}

@end
