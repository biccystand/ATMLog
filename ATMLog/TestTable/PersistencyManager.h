//
//  PersistencyManager.h
//  TokiMemo
//
//  Created by masaki on 2013/09/30.
//  Copyright (c) 2013年 masaki. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Counter;

@interface PersistencyManager : NSObject
+(PersistencyManager*)sharedInstance;
@property (nonatomic, strong) NSMutableArray *counters;
@property (nonatomic, strong) NSDictionary *dateDictionary;
//@property (nonatomic, assign) NSInteger row;
- (void)resetCount;
- (void)removeCounterAtIndexPath: (NSIndexPath *)indexPath;
//- (void)saveDateWithColorNum:(NSInteger)num;
//- (void)saveCounterWithTitle:(NSString*)title;
- (void)addCounterToDatabase:(Counter *)newCounter;
- (void)updateCounterIds;
- (void)updateCounter:(Counter*)counter;
- (void)updateCounterCount:(NSInteger)row;
- (void)updateCountersToBadgeZero;
//- (void)updateCounterOfDatabaseWithId:(NSInteger)timeMemoId memo:(NSString *)memo;
//- (void)updateCounterOfDatabaseWithId:(NSInteger)timeMemoId colorNum:(NSInteger)colorNum memo:(NSString *)memo;
//- (void)updateCounterOfDatabaseWithId:(NSInteger)timeMemoId colorNum:(NSInteger)colorNum;
- (void)removeALlCounterOfDatabase;
- (void)removeCounterOfDatabaseAtRow:(NSInteger)row;
//- (NSString*)allDataString;
//- (void)removeCountersOfDatabaseAtIdNumsArray:(NSArray *)idNumsArray;
//- (void)removeCountersOfDatabaseAtIndexPath:(NSArray *)indexPathArray;
- (void)badge:(Counter*)counter usingRemaining:(NSInteger)usingRemaining;
//- (void)removeTimeMemosOfDatabaseAtIdNumsArray:(NSArray *)indexPathArray;
- (void)sayData;
- (void)badgeReset;
@end
