//
//  VKDataBase.m
//
//  Created by awhisper on 15/2/4.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDataBase.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

@interface VKDataBase ()

@property (nonatomic,strong) NSString* namePath;

@property (nonatomic,strong) FMDatabase* dataBase;

@property (nonatomic,strong) FMDatabaseQueue* dataBaseQueue;

@end

@implementation VKDataBase

-(void)checkMainThread
{
    NSParameterAssert([NSThread isMainThread]);
}

-(BOOL)openDB:(NSString *)name
{
    [self checkMainThread];
    if (!name) {
        return NO;  // 返回数据库创建失败
    }
    // 沙盒Docu目录
    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    _namePath = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@.sq",name]];

    if (!_dataBase) {
        _dataBase = [[FMDatabase alloc] initWithPath:_namePath];
        _dataBaseQueue = [[FMDatabaseQueue alloc]initWithPath:_namePath];
    }else
    {
        return NO;
    }
    if (!_dataBaseQueue) {
        NSLog(@"批量数据库队列创建失败");
        return NO;
    }
    if (![_dataBase open]) {
        NSLog(@"不能打开数据库");
        return NO;
    }
    
    
    _DBName = name;
   
    return YES;
    
}
/// 关闭连接
- (BOOL) close {
    [self checkMainThread];
    BOOL success = [_dataBase close];
    _DBName = nil;
    return success;
}

-(NSInteger)lastInsertID
{
    return _dataBase.lastInsertRowId;
}

-(NSArray *)executeQuerySql:(NSString *)sql
{
    [self checkMainThread];
    FMResultSet* rs = [_dataBase executeQuery:sql];
    NSMutableArray* mresult = [[NSMutableArray alloc]init];
    while ([rs next]) {
        NSDictionary* rsitem = [rs resultDictionary];
        [mresult addObject:rsitem];
    }
    
    if (mresult.count <= 0) {
        return nil;
    }
    
    NSArray* result = [NSArray arrayWithArray:mresult];
    return result;
}

-(BOOL)executeUpdateSql:(NSString *)sql
{
    [self checkMainThread];
    BOOL success = [_dataBase executeUpdate:sql];
    return success;
}

- (void)executeUpdateQueueInDatabase:(NSArray *)sqlArr withTaskTag:(NSString*)tag
{
    [self checkMainThread];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* resultarr = [[NSMutableArray alloc]init];
        for (NSString* sqlitem in sqlArr) {
            BOOL success = [db executeUpdate:sqlitem];
            [resultarr addObject:@(success)];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
            NSArray* rarr = [NSArray arrayWithArray:resultarr];
            //转成线程安全的不可变数组 抛主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate executeQueueCompleteWithTag:tag withSuccess:YES withData:rarr];
//                block(tag,YES,rarr);
            });
        }
    }];
}

- (void)executeUpdateQueueInTransaction:(NSArray *)sqlArr withTaskTag:(NSString *)tag
{
    [self checkMainThread];
    [_dataBaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray* resultarr = [[NSMutableArray alloc]init];
        for (NSString* sqlitem in sqlArr) {
            BOOL success = [db executeUpdate:sqlitem];
            if (!success) {
                *rollback = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
                    //抛主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate executeQueueCompleteWithTag:tag withSuccess:NO withData:nil];
//                        block(tag,NO,nil);
                    });
                }
                return;
            }
            [resultarr addObject:@(success)];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
            NSArray* rarr = [NSArray arrayWithArray:resultarr];
            //转成线程安全的不可变数组 抛主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate executeQueueCompleteWithTag:tag withSuccess:YES withData:rarr];
//                block(tag,YES,rarr);
            });
        }
    }];
}

-(void)executeQueryQueueInDatabase:(NSArray *)sqlArr withTaskTag:(NSString *)tag
{
    [self checkMainThread];
    [_dataBaseQueue inDatabase:^(FMDatabase *db) {
        NSMutableArray* resultarr = [[NSMutableArray alloc]init];
        for (NSString* sqlitem in sqlArr) {
            FMResultSet* rs = [_dataBase executeQuery:sqlitem];
            NSMutableArray* mresultItem = [[NSMutableArray alloc]init];
            while ([rs next]) {
                NSDictionary* rsitem = [rs resultDictionary];
                [mresultItem addObject:rsitem];
            }
            //转成线程安全的不可变数组
            NSArray* resultItem = [NSArray arrayWithArray:mresultItem];
            [resultarr addObject:resultItem];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
            NSArray* rarr ;
            //单次查询 将查询单一结果不再包装放到nsarray里
            if (sqlArr.count == 1) {
                rarr = [NSArray arrayWithArray:[resultarr firstObject]];
            }else
            {
                rarr = [NSArray arrayWithArray:resultarr];
            }
            //转成线程安全的不可变数组 抛主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate executeQueueCompleteWithTag:tag withSuccess:YES withData:rarr];
//                block(tag,YES,rarr);
            });
        }
    }];
}

-(void)executeQueryQueueInTransaction:(NSArray *)sqlArr withTaskTag:(NSString *)tag
{
    [self checkMainThread];
    [_dataBaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray* resultarr = [[NSMutableArray alloc]init];
        for (NSString* sqlitem in sqlArr) {
            FMResultSet* rs = [_dataBase executeQuery:sqlitem];
            //如果查询错误 rs为空
            if (rs == nil) {
                *rollback = YES;
                if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
                    //抛主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate executeQueueCompleteWithTag:tag withSuccess:NO withData:nil];
//                        block(tag,NO,nil);
                    });
                }
                return;
            }
            
            NSMutableArray* mresultItem = [[NSMutableArray alloc]init];
            while ([rs next]) {
                NSDictionary* rsitem = [rs resultDictionary];
                [mresultItem addObject:rsitem];
            }
            //转成线程安全的不可变数组
            NSArray* resultItem = [NSArray arrayWithArray:mresultItem];
            [resultarr addObject:resultItem];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(executeQueueCompleteWithTag:withSuccess:withData:)]) {
            NSArray* rarr ;
            //单次查询 将查询单一结果不再包装放到nsarray里
            if (sqlArr.count == 1) {
                rarr = [NSArray arrayWithArray:[resultarr firstObject]];
            }else
            {
                rarr = [NSArray arrayWithArray:resultarr];
            }
            //转成线程安全的不可变数组 抛主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate executeQueueCompleteWithTag:tag withSuccess:YES withData:rarr];
//                block(tag,YES,rarr);
            });
        }
    }];
}

@end
