//
//  PersistencyManager.m
//  TokiMemo
//
//  Created by masaki on 2013/09/30.
//  Copyright (c) 2013年 masaki. All rights reserved.
//

#import "PersistencyManager.h"
#import "Counter.h"
#include <sqlite3.h>

@implementation PersistencyManager

+(PersistencyManager*)sharedInstance
{
    static PersistencyManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PersistencyManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.counters = [[NSMutableArray alloc] init];
        NSString *filePath = [self copyDatabaseToDocuments];
        [self readCountersFromDatabaseWithPath:filePath];
    }
    return self;
}

- (NSDictionary *)dateDictionary: (NSDate *)now {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps;
    
    // 年・月・日を取得
    flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
    
    NSLog(@"%d年 %d月 %d日", year, month, day);
    
    
    // 時・分・秒を取得
    flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps = [calendar components:flags fromDate:now];
    
    NSInteger hour = comps.hour;
    NSInteger minute = comps.minute;
    NSInteger second = comps.second;
    
    NSLog(@"%d時 %d分 %d秒", hour, minute, second);
    
    
    // 曜日
    comps = [calendar components:NSWeekdayCalendarUnit fromDate:now];
    NSInteger weekday = comps.weekday; // 曜日(1が日曜日 7が土曜日)
    NSLog(@"曜日: %d", weekday);
    
    NSDictionary *dateDic = @{@"year": [NSNumber numberWithInt:year], @"month": [NSNumber numberWithInt:month], @"day": [NSNumber numberWithInt:day], @"hour": [NSNumber numberWithInt:hour], @"minute": [NSNumber numberWithInt:minute], @"second": [NSNumber numberWithInt:second], @"weekday": [NSNumber numberWithInt:weekday]};
    return dateDic;
}


#pragma mark - database
- (NSString *)copyDatabaseToDocuments {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"counter.sqlite"];
        [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
    }
    return filePath;
}

- (void)readCountersFromDatabaseWithPath:(NSString *)filePath {
    sqlite3 *database;
    
    BOOL haveBadge = NO;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select * from counters order by row";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                //
                //                CREATE TABLE counter (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
                //
                NSInteger counterId = sqlite3_column_int(compiledStatement, 0);
                NSString *title;
                char *str = (char*)sqlite3_column_text(compiledStatement, 1);
                if(str == NULL){
                    title = @"";
                }else{
                    title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                }

                NSInteger count = sqlite3_column_int(compiledStatement, 2);
                NSInteger limit = sqlite3_column_int(compiledStatement, 3);
                NSInteger monthreset = sqlite3_column_int(compiledStatement, 4);
                NSInteger row = sqlite3_column_int(compiledStatement, 5);
                NSInteger month = sqlite3_column_int(compiledStatement, 6);
                NSInteger year = sqlite3_column_int(compiledStatement, 7);
                NSInteger color = sqlite3_column_int(compiledStatement, 8);
                NSInteger badge = sqlite3_column_int(compiledStatement, 9);
                
                Counter *newCounter = [[Counter alloc] init];
                newCounter.counterId = counterId;
                newCounter.title = title;
                newCounter.count = count;
                newCounter.limit = limit;
                newCounter.monthReset = monthreset;
                newCounter.row = row;
                newCounter.year = year;
                newCounter.month = month;
                newCounter.color = color;
                newCounter.badge = badge;
                [self.counters addObject:newCounter];
                
                if (!haveBadge && newCounter.badge) {
                    haveBadge = YES;
                    [self badgeReload:newCounter];
                }
                //                [self.cities addObject:newCity];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    if (!haveBadge) {
        [self updateCountersToBadgeZero];
        [self badgeReset];
    }
}


- (void)selectCountersFromDatabaseWithPath:(NSString *)filePath {
    sqlite3 *database;
    
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select * from counters order by row";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                //
                //                CREATE TABLE counter (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
                //
                NSInteger counterId = sqlite3_column_int(compiledStatement, 0);
                NSString *title;
                char *str = (char*)sqlite3_column_text(compiledStatement, 1);
                if(str == NULL){
                    title = @"";
                }else{
                    title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)];
                }
                
                NSInteger count = sqlite3_column_int(compiledStatement, 2);
                NSInteger limit = sqlite3_column_int(compiledStatement, 3);
                NSInteger monthreset = sqlite3_column_int(compiledStatement, 4);
                NSInteger row = sqlite3_column_int(compiledStatement, 5);
                NSInteger month = sqlite3_column_int(compiledStatement, 6);
                NSInteger year = sqlite3_column_int(compiledStatement, 7);
                
                Counter *newCounter = [[Counter alloc] init];
                newCounter.counterId = counterId;
                newCounter.title = title;
                newCounter.count = count;
                newCounter.limit = limit;
                newCounter.monthReset = monthreset;
                newCounter.row = row;
                newCounter.year = year;
                newCounter.month = month;
                
                NSLog(@"counter: <%@> <row:%d> <id: %d>", newCounter.title, newCounter.row, newCounter.counterId);
                //                [self.cities addObject:newCity];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);}


//
//- (void)saveCounterWithTitle:(NSString*)title{
//    NSDictionary *dateDic = [self dateDictionary:[NSDate date]];
//    
//    Counter *counter = [[Counter alloc] init];
//    counter.year = [[dateDic objectForKey:@"year"] intValue];
//    counter.month = [[dateDic objectForKey:@"month"] intValue];
//    counter.title = title;
//    [self.counters insertObject:counter atIndex:0];
//    [self addCounterToDatabase:counter];
//    
//    for (Counter *memoInArray in self.counters) {
//        //        NSLog(@"id: %d, color: %d", memoInArray.counterId, memoInArray.color);
//    }
//}

//- (void)saveDateWithColorNum:(NSInteger)num{
//    NSDictionary *dateDic = [self dateDictionary:[NSDate date]];
//    
//    Counter *counter = [[Counter alloc] init];
//    counter.year = [[dateDic objectForKey:@"year"] intValue];
//    counter.month = [[dateDic objectForKey:@"month"] intValue];
//    //    counter.memo = @"init";
//    
//    //    counter.dateString = dateString;
//    //    counter.timeString = timeString;
//    
//    NSInteger maxId = [self maxIdOfDatabase];
//    NSLog(@"maxId: %d", maxId);
//    counter.counterId = maxId + 1;
//    NSLog(@"newId: %d", counter.counterId);
//    //    NSString *filePath = [self copyDatabaseToDocuments];
//    //    [self readAllDataWithPath:filePath];
//    
//    [self.counters insertObject:counter atIndex:0];
////    [self.timeTableViewController reloadTableView];
//    [self addCounterToDatabase:counter];
//    
//    for (Counter *memoInArray in self.counters) {
////        NSLog(@"id: %d, color: %d", memoInArray.counterId, memoInArray.color);
//    }
//}

- (void)updateCountersToBadgeZero {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    sqlite3 *database;
    
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update counters set badge = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_OK) {
                sqlite3_bind_int(compiledStatement, 1, 0);
//                sqlite3_bind_int(compiledStatement, 2, 1);
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    for (Counter *counter in _counters) {
        counter.badge = 0;
    }
}


- (NSInteger)maxIdOfDatabase {
    NSInteger maxId = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "select max(id) from counters";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                maxId = sqlite3_column_int(compiledStatement, 0);
                NSLog(@"maxId: %d", maxId);
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return maxId;
}

- (void)addCounterToDatabase:(Counter *)newCounter {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "insert into counters (year, month, title, monthReset, color) VALUES (?, ?, ?, ?, ?)";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(compiledStatement, 1, newCounter.year);
            sqlite3_bind_int(compiledStatement, 2, newCounter.month);
            sqlite3_bind_text(compiledStatement, 3, [newCounter.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 4, newCounter.monthReset);
            sqlite3_bind_int(compiledStatement, 5, newCounter.color);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        NSLog(@"%@",[self sqlite3StmtToString:compiledStatement]);
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//            sqlite3_finalize(compiledStatement);
        } else {
            NSLog(@"error: %d", sqlite3_step(compiledStatement));
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    NSLog(@"inserted");
    
    NSInteger maxId = [self maxIdOfDatabase];
    NSLog(@"maxId: %d", maxId);
    newCounter.counterId = maxId;
    [self updateCounterIds];

    
    [self selectCountersFromDatabaseWithPath:filePath];
}

//http://stackoverflow.com/questions/9017766/ios-sqlite-how-to-print-a-prepared-sqlite3-stmt-to-nslog
-(NSMutableString*) sqlite3StmtToString:(sqlite3_stmt*) statement
{
    NSMutableString *s = [NSMutableString new];
    [s appendString:@"{\"statement\":["];
    for (int c = 0; c < sqlite3_column_count(statement); c++){
        [s appendFormat:@"{\"column\":\"%@\",\"value\":\"%@\"}",[NSString stringWithUTF8String:(char*)sqlite3_column_name(statement, c)],[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement, c)]];
        if (c < sqlite3_column_count(statement) - 1)
            [s appendString:@","];
    }
    [s appendString:@"]}"];
    return s;
}

- (void)updateCounter:(Counter*)counter{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
//    Counter *counter = [_counters objectAtIndex:row];
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update counters set title = ?, count = ?, limitvalue = ?, color = ?, monthreset = ?, badge = ? where row = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(compiledStatement, 1, [counter.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 2, counter.count);
            sqlite3_bind_int(compiledStatement, 3, counter.limit);
            sqlite3_bind_int(compiledStatement, 4, counter.color);
            sqlite3_bind_int(compiledStatement, 5, counter.monthReset);
            sqlite3_bind_int(compiledStatement, 6, counter.badge);
            sqlite3_bind_int(compiledStatement, 7, counter.row);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        sqlite3_step(compiledStatement);
        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        //            NSLog(@"done");
        //        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}


- (void)updateCounterCount:(NSInteger)row{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
    Counter *counter = [_counters objectAtIndex:row];
    NSLog(@"countercount: %d", counter.count);
    NSLog(@"counterrow: %d", counter.row);
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "update counters set count = ? where row = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(compiledStatement, 1, counter.count);
            sqlite3_bind_int(compiledStatement, 2, counter.row);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
            NSLog(@"sqlitedone");
        } else {
            NSLog(@"error: %d", sqlite3_step(compiledStatement));
        }
//
//        sqlite3_step(compiledStatement);
        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
        //            NSLog(@"done");
        //        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    if (counter.badge) {
        [self badgeReload:counter];
    }
}

- (void)badgeReload:(Counter*)counter
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int isRemainingCountForBadge = [userDefaults integerForKey:@"remainingCountForBadge"];
    [self badge:counter usingRemaining:isRemainingCountForBadge];
}

- (void)updateCounterIds{
    BOOL looped = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
    for (int i=0; i<_counters.count; i++) {
        Counter *counter = [_counters objectAtIndex:i];
        if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
            looped = YES;
            const char *sqlStatement = "update counters set row = ? where id = ?";
            sqlite3_stmt *compiledStatement;
            if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                sqlite3_bind_int(compiledStatement, 1, i);
                sqlite3_bind_int(compiledStatement, 2, counter.counterId);
            } else {
                NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
            }
            sqlite3_step(compiledStatement);
//        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//            NSLog(@"done");
//        }
            sqlite3_finalize(compiledStatement);
        }
    }
    if (looped) {
        sqlite3_close(database);
    }
    
    [self sayData];
}


//- (void)updateCounterOfDatabaseWithId:(NSInteger)counterId colorNum:(NSInteger)colorNum memo:(NSString *)memo{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
//    
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "update counters set color = ?, memo = ? where id = ?";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            sqlite3_bind_int(compiledStatement, 1, colorNum);
//            //            NSString *str;
//            //            if ([memo isEqualToString:@""]) {
//            //                str = @"NULL";
//            //            } else {
//            //                str = memo;
//            //            }
//            
//            sqlite3_bind_text(compiledStatement, 2, [memo UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_int(compiledStatement, 3, counterId);
//        } else {
//            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
//        }
//        sqlite3_step(compiledStatement);
//        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//        //            sqlite3_finalize(compiledStatement);
//        //        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//}

//- (void)updateCounterOfDatabaseWithId:(NSInteger)counterId colorNum:(NSInteger)colorNum {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
//    
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "update counters set color = ? where id = ?";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            sqlite3_bind_int(compiledStatement, 1, colorNum);
//            sqlite3_bind_int(compiledStatement, 2, counterId);
//        } else {
//            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
//        }
//        sqlite3_step(compiledStatement);
//        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//        //            sqlite3_finalize(compiledStatement);
//        //        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//}

//- (void)updateCounterInArrayWithId:(NSInteger)counterId color:(NSInteger)color memo:(NSString *)memo{
//    
//    NSLog(@"newcolor: %d", color);
//    for (Counter *counter in self.counters) {
//        if (counter.counterId == counterId) {
//            NSLog(@"each: %d", counter.counterId);
//            NSLog(@"timemo: %d", counterId);
//            NSLog(@"0color: %d", counters.color);
//            NSLog(@"memo: %@", counters.memo);
//            counters.color = color;
//            counters.memo = memo;
//            NSLog(@"color: %d", counters.color);
//            NSLog(@"memo: %@", counters.memo);
//        }
//    }
////    [self.timeTableViewController reloadTableView];
//}


//- (void)updateCounterOfDatabaseWithId:(NSInteger)counterId memo:(NSString *)memo{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
//    
//    sqlite3 *database;
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "update counters set memo = ? where id = ?";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            //            NSString *str;
//            //            if ([memo isEqualToString:@""]) {
//            //                str = @"NULL";
//            //            } else {
//            //                str = memo;
//            //            }
//            
//            sqlite3_bind_text(compiledStatement, 1, [memo UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_int(compiledStatement, 2, counterId);
//        } else {
//            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
//        }
//        sqlite3_step(compiledStatement);
//        //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
//        //            sqlite3_finalize(compiledStatement);
//        //        }
//        sqlite3_finalize(compiledStatement);
//        
//    }
//    sqlite3_close(database);
//}


- (void)removeALlCounterOfDatabase{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
//    [self selectCountersFromDatabaseWithPath:filePath];

    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlStatement = "delete from counters";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    [self badgeReset];
}

- (void)removeCounterOfDatabaseAtRow:(NSInteger)row{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
    
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        
        const char *sqlStatement = "delete from counters where row = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(compiledStatement, 1, row);
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
            NSLog(@"■■deleted::%d", row);
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    [self updateCounterIds];
    //    [self selectCountersFromDatabaseWithPath:filePath];
//    for (Counter* counter in _counters) {
//        NSLog(@"counter: %@", counter);
//        if (counter.row == row && counter.badge) {
//            [self badgeReset];
//            break;
//        }
//    }
}

- (void)removeCounterOfDatabaseAtId:(NSInteger)counterId{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        
        const char *sqlStatement = "delete from counters where id = ?";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        } else {
            NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
        }
        
        sqlite3_bind_int(compiledStatement, 1, counterId);
        
        
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            //            sqlite3_finalize(compiledStatement);
            NSLog(@"■■deleted::%d", counterId);
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
//    [self selectCountersFromDatabaseWithPath:filePath];

}

- (void)removeCountersOfDatabaseAtIndexPath:(NSArray *)indexPathArray{
    NSArray *reverseIndexPathArray = [[indexPathArray reverseObjectEnumerator] allObjects];
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    NSLog(@"iparray: %@", indexPathArray);
    for (NSIndexPath *indexPath in reverseIndexPathArray) {
        NSLog(@"indexPath: %@", indexPath);
        Counter *counterToDelete = [self.counters objectAtIndex:indexPath.row];
        [removeArray addObject:counterToDelete];
        NSLog(@"delete Id: %d1", counterToDelete.counterId);
//        [self.counters removeObjectAtIndex:indexPath.row];
    }
    [self removeCountersOfDatabaseAtIdNumsArray:indexPathArray];
    NSLog(@"removaarray: %@", removeArray);
    [self.counters removeObjectsInArray:removeArray];
    NSLog(@"counters: %@", self.counters);

//    [self removecounterOfDatabaseAtId:counterToDelete.counterId];
}


- (void)sayData
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];

    [self selectCountersFromDatabaseWithPath:filePath];
}

- (void)removeCountersOfDatabaseAtIdNumsArray:(NSArray *)indexPathArray{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    NSString *whereState = @"where id=0";
    NSLog(@"indexPathArray: %@", indexPathArray);
    for (NSIndexPath *indexPath in indexPathArray) {
//        Counter* counter = [counter ]
        Counter *counterToDelete = [self.counters objectAtIndex:indexPath.row];
        NSLog(@"delete Id: %d", counterToDelete.counterId);
//        [self.counters removeObjectAtIndex:indexPath.row];
//        [self removecounterOfDatabaseAtId:counterToDelete.counterId];

        
        whereState = [whereState stringByAppendingFormat:@" or id=%d", counterToDelete.counterId];
    }
    
    NSLog(@"where: %@", whereState);

    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        
//        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM counter WHERE %@",[NSString stringWithFormat:@"id > 0"]];
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM counters  %@", whereState];
        NSLog(@"%@", deleteSQL);
        
        // SQL文のコンパイルと実行
        sqlite3_stmt *statement = Nil;
        if( sqlite3_prepare_v2(database, [deleteSQL UTF8String], -1, &statement, NULL ) != SQLITE_OK) {
            NSLog(@"not OK");
        } else {
            int wasPrepared = sqlite3_prepare_v2(database, [deleteSQL UTF8String], -1, &statement, NULL );
            int wasSucceeded = sqlite3_step(statement);
            NSLog(@"int: %d", wasSucceeded);
            NSLog(@"preapred: %d", wasPrepared);
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
//    [self selectCountersFromDatabaseWithPath:filePath];
    
}


- (void)removeCounterAtIndexPath: (NSIndexPath *)indexPath{
    Counter *counterToDelete = [self.counters objectAtIndex:indexPath.row];
    NSLog(@"delete Id: %d", counterToDelete.counterId);
    [self.counters removeObjectAtIndex:indexPath.row];
    [self removeCounterOfDatabaseAtId:counterToDelete.counterId];
}

//- (NSString*)allDataString
//{
//    NSString *string = [[NSString alloc] init];
//    sqlite3 *database;
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
//
//    
//    if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
//        const char *sqlStatement = "select * from counters order by id desc";
//        sqlite3_stmt *compiledStatement;
//        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
//            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
//                //
//                //                CREATE TABLE counter (id INTEGER PRIMARY KEY AUTOINCREMENT, year integer, month integer, day integer, hour integer, minute integer, second integer, weekday integer, memo text, color integer)
//                //
//                NSInteger counterId = sqlite3_column_int(compiledStatement, 0);
//                NSInteger year = sqlite3_column_int(compiledStatement, 1);
//                NSInteger month = sqlite3_column_int(compiledStatement, 2);
//                NSInteger day = sqlite3_column_int(compiledStatement, 3);
//                NSInteger hour = sqlite3_column_int(compiledStatement, 4);
//                NSInteger minute = sqlite3_column_int(compiledStatement, 5);
//                NSInteger second = sqlite3_column_int(compiledStatement, 6);
//                NSInteger weekday = sqlite3_column_int(compiledStatement, 7);
//                
//                NSString *memo;
//                char *str = (char*)sqlite3_column_text(compiledStatement, 8);
//                if(str == NULL){
//                    memo = @"";
//                }else{
//                    memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                }
//                //                NSString *memo = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 8)];
//                NSInteger color = sqlite3_column_int(compiledStatement, 9);
//                
//                Counter *newCounter = [[Counter alloc] init];
//                newCounter.counterId = counterId;
//                newCounter.year = year;
//                newCounter.month = month;
////                NSString *newcounterString = [NSString stringWithFormat:@""];
////                string = [string stringByAppendingString:[NSString stringWithFormat:@"%@\n", newCounter.counterString]];
//                NSLog(@"string: %@", string);
//            }
//        }
//        sqlite3_finalize(compiledStatement);
//    }
//    sqlite3_close(database);
//    return string;
//}

- (void)resetCount
{
    BOOL looped = NO;
    for (Counter *counter in _counters) {
        if (counter.monthReset) {
            counter.count = 0;
        }
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"counter.sqlite"];
    
    sqlite3 *database;
//    for (int i=0; i<_counters.count; i++) {
//        Counter *counter = [_counters objectAtIndex:i];
    for (Counter *counter in _counters) {
        if (counter.monthReset) {
            if (sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
                looped = YES;
                const char *sqlStatement = "update counters set count = ? where row = ?";
                sqlite3_stmt *compiledStatement;
                if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                    sqlite3_bind_int(compiledStatement, 1, 0);
                    sqlite3_bind_int(compiledStatement, 2, counter.row);
                } else {
                    NSLog(@"%d", sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL));
                }
                sqlite3_step(compiledStatement);
                //        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
                //            NSLog(@"done");
                //        }
                sqlite3_finalize(compiledStatement);
            }
        }
    }
    if (looped) {
        sqlite3_close(database);
    }

}

- (void)badge:(Counter*)counter usingRemaining:(NSInteger)usingRemaining
{
    NSInteger number;
    if (usingRemaining) {
        number = counter.limit - counter.count;
    }
    else
    {
        number = counter.count;
    }
    NSLog(@"num:: %d", number);
    [UIApplication sharedApplication].applicationIconBadgeNumber = number;
}

- (void)badgeReset
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
}
@end
