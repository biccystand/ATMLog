//
//  DateManager.h
//  TestTable
//
//  Created by masaki on 2014/02/11.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateManager : NSObject
+ (DateManager*)sharedInstance;
- (NSDate*)localDate;
- (NSInteger)yearAndMonth;
- (NSArray*)dayAndMonth;
- (NSInteger)daysOfThisMonth;
- (void)badgeNumberReset;
@end
