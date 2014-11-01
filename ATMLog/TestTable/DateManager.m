//
//  DateManager.m
//  TestTable
//
//  Created by masaki on 2014/02/11.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "DateManager.h"

@implementation DateManager
+ (DateManager*)sharedInstance{
    static DateManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DateManager alloc] init];
    });
    return _sharedInstance;
}

- (NSDate*)localDate{
    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    return now;
}

- (NSInteger)yearAndMonth
{
//    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    NSDate * now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;
    flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
//    NSInteger year = comps.year;
//    NSInteger month = comps.month;
    
    NSInteger year = comps.year;
    NSInteger month = comps.month;
//    NSLog(@"year: %d", year);
    
    NSInteger yearAndMonth = (year - 2000) * 100 + month;
//    NSInteger yearAndMonth = comps.hour;
    return yearAndMonth;
}

- (NSArray*)dayAndMonth
{
    //    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    NSDate * now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;
    flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit|NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
    NSInteger day = comps.day;
    NSInteger month = comps.month;
    return @[[NSNumber numberWithInt:day], [NSNumber numberWithInt:month]];
}

- (NSInteger)daysOfThisMonth
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    // 現在の月の最後を得る場合
    NSDate *now = [NSDate date];
    
    // inUnit:で指定した単位（月）の中で、rangeOfUnit:で指定した単位（日）が取り得る範囲
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:now];
    
//    NSInteger min = range.location;
    // これが月末日
    NSInteger max = range.length;
    return max;
}

//- (void)delete
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification object:nil];
//    //キーボードの出現通知の削除
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardDidShowNotification object:nil];
//}

- (void)badgeNumberReset
{
    for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if([[notification.userInfo objectForKey:@"key"] isEqualToString:@"date"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components
    = [calendar components:NSYearCalendarUnit   |
       NSMonthCalendarUnit  |
       NSDayCalendarUnit
//       |
//       NSHourCalendarUnit   |
//       NSMinuteCalendarUnit
                  fromDate:today];
/*
    = [calendar components:NSYearCalendarUnit   |
       NSMonthCalendarUnit  |
       NSDayCalendarUnit    |
       NSHourCalendarUnit   |
       NSMinuteCalendarUnit 
                  fromDate:today];
*/
    components.day = 1;
    components.month ++;
//    components.minute++;
    NSDate *firstDate = [calendar dateFromComponents:components];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat  = @"yyyy.MM.dd(E) HH:mm:ss";
    NSLog(@"firstDate:%@", firstDate);
    NSLog(@"firstDate:%@", [formatter stringFromDate:firstDate]);
    NSLog(@"today:%@", today);
    
    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    NSLog(@"now: %@", now);
    
    NSDate *nowDate = [firstDate initWithTimeInterval:0 sinceDate:firstDate];
    NSLog(@"first: %@", nowDate);
    NSLog(@"interval: %d", [[NSTimeZone systemTimeZone] secondsFromGMT]);
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    /* Time and timezone settings */
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:8.0];
//    notification.fireDate = firstDate;
//    NSDate *fDate = [[NSDate new] initWithTimeInterval:60 sinceDate:[NSDate new]];
    NSDate *fDate = firstDate;
    notification.fireDate = fDate;
//    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:8.0];
    NSLog(@"fdate: %@", fDate);
    notification.timeZone = [[NSCalendar currentCalendar] timeZone];
    notification.alertBody =
    NSLocalizedString(@"カウントをリセットしました。", nil);
    notification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"date", @"key", nil];
    /* Action settings */
    notification.hasAction = YES;
    notification.alertAction = NSLocalizedString(@"View", nil);
    /* Badge settings */
//    notification.applicationIconBadgeNumber =
//    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    notification.applicationIconBadgeNumber = -1;
    /* Additional information, user info */
//    notification.userInfo = @{@"Key 1" : @"Value 1",
//                              @"Key 2" : @"Value 2"};
    /* Schedule the notification */
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    for(UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
//        if([[notification.userInfo objectForKey:@"key"] isEqualToString:@"date"]) {
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//        }
//    }
}
@end
