//
//  NSDate-Components.m
//  Sim68K
//
//  Created by Robert Bartlett-Schneider on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate-Components.h"

@implementation NSDate (Components)

// -----------------------------------------------------------------
// components
// breaks a date object into its components 
// -----------------------------------------------------------------
- (NSDateComponents *)components {
    unsigned unitFlags = NSEraCalendarUnit    | NSYearCalendarUnit    |
                         NSMonthCalendarUnit  | NSDayCalendarUnit     |
                         NSHourCalendarUnit   | NSMinuteCalendarUnit  |
                         NSSecondCalendarUnit | NSWeekCalendarUnit    |
                         NSWeekCalendarUnit   | NSWeekdayCalendarUnit |
                         NSWeekdayOrdinalCalendarUnit |
                         NSQuarterCalendarUnit;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:unitFlags fromDate:self];
    
    return comp;
}

@end
