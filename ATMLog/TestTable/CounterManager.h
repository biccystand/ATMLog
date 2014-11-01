//
//  CounterManager.h
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Counter;

@interface CounterManager : NSObject
@property (nonatomic, strong) NSMutableArray *counters;
+ (CounterManager*)sharedInstance;
- (void)updateCounterWithId:(NSInteger)counterId title:(NSString *)title;
- (Counter *)counterAtIndex:(NSInteger)index;
- (NSInteger)increaseCounterWithId:(NSInteger)counterId;
- (NSInteger)decreaseCounterWithId:(NSInteger)counterId;
- (void)resetCount;
- (void)badge:(NSInteger)number;
@end
