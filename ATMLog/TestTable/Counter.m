//
//  Counter.m
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "Counter.h"

@implementation Counter
- (id)initWithTitle:(NSString *)title count:(NSInteger)count limit:(NSInteger)limit monthReset:(BOOL)monthReset color:(NSInteger)color badge:(NSInteger)badge
{
    self = [super init];
    if (self) {
        _title = title;
        _count = count;
        _limit = limit;
        _monthReset = monthReset;
        _color = color;
        _badge = badge;
    }
    return self;
}

- (NSInteger)displayCount
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger isRemainingCountForBadge = [userDefaults integerForKey:@"remainingCountForBadge"];
    if (isRemainingCountForBadge) {
        return self.limit - self.count;
    }
    else
    {
        return self.count;
    }
}
@end
