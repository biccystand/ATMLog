//
//  CounterManager.m
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import "CounterManager.h"
#import "Counter.h"
#include <sqlite3.h>

@implementation CounterManager
+ (CounterManager*)sharedInstance
{
    static CounterManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[CounterManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.counters = [NSMutableArray arrayWithArray:@[
                                                         [[Counter alloc] initWithTitle:@"三井住友" count:0 limit:4 monthReset:YES color:2 badge: 0],
                                                         [[Counter alloc] initWithTitle:@"東京三菱UFJ" count:0 limit:3 monthReset:YES color: 3 badge: 0],
                                                         [[Counter alloc] initWithTitle:@"みずほ" count:0 limit:3 monthReset:YES color:1 badge: 0],
                                                         [[Counter alloc] initWithTitle:@"その他" count:0 limit:0 monthReset:YES color:0 badge: 0]]];
    }
    return self;
}

- (Counter *)counterAtIndex:(NSInteger)index{
    return [self.counters objectAtIndex:index];
}

- (void)updateCounterWithId:(NSInteger)counterId title:(NSString *)title{
    Counter *counter = [self counterAtIndex:counterId];
    counter.title = title;
}
- (NSInteger)increaseCounterWithId:(NSInteger)counterId{
    Counter *counter = [self counterAtIndex:counterId];
    return ++counter.count;
}
- (NSInteger)decreaseCounterWithId:(NSInteger)counterId{
    Counter *counter = [self counterAtIndex:counterId];
    return --counter.count;
}

- (void)resetCount
{
    for (Counter *counter in _counters) {
        if (counter.monthReset) {
            counter.count = 0;
        }
    }
}

- (void)badge:(NSInteger)number
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = number;
}
@end
