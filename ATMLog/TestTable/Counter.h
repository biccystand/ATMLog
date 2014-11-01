//
//  Counter.h
//  TestTable
//
//  Created by masaki on 2014/02/10.
//  Copyright (c) 2014年 masaki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Counter : NSObject
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL monthReset;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger yearAndMonth;
@property (nonatomic, assign) NSInteger counterId;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger color;
@property (nonatomic, assign) NSInteger badge;
@property (nonatomic, assign) NSInteger displayCount;
- (id)initWithTitle:(NSString *)title count:(NSInteger)count limit:(NSInteger)limit monthReset:(BOOL)monthReset color:(NSInteger)color badge:(NSInteger)badge;
@end
