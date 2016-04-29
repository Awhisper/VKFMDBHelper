//
//  VKDBManager.m
//
//  Created by awhisper on 15/2/5.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDBManager.h"
#import "VKSQLQueueManager.h"
#import "VKDataBase.h"

@interface VKDataBaseNotificationListener : NSObject

@property (nonatomic,strong) id target;

@property (nonatomic,copy) VKDataBaseQueueBlockReturn block;

@end

@implementation VKDataBaseNotificationListener


@end

@interface VKDBManager ()

@property (nonatomic,strong) VKSQLQueueManager* sqlManager;

@property (nonatomic,strong) NSMutableDictionary* dataBasMap;

@property (nonatomic,strong) VKDataBase* currentDB;

@property (nonatomic,strong) NSMutableDictionary* notificationMap;

@end

@implementation VKDBManager

- (instancetype)sharedInstance {
    return [[self class] defaultManager];
}

static id __singleton__;
+ (instancetype)defaultManager {
    static dispatch_once_t once;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
        self.dataBasMap = [[NSMutableDictionary alloc]init];
        self.currentDB = nil;
        self.sqlManager = [[VKSQLQueueManager alloc]init];
        self.notificationMap = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(BOOL)openDataBaseWithName:(NSString *)name
{
    //如果map中存在，置为current
    if ([_dataBasMap objectForKey:name]) {
        self.currentDB = [_dataBasMap objectForKey:name];
        return YES;
    }else
    {
        VKDataBase* newDB = [[VKDataBase alloc]init];
        newDB.delegate = self;
        BOOL success = [newDB openDB:name];
        if (success) {
            self.currentDB = newDB;
            [_dataBasMap setObject:newDB forKey:name];
        }
        return success;
    }
}

-(BOOL)closeDataBaseWithName:(NSString *)name
{
    //如果map中存在，置为current
    if ([_dataBasMap objectForKey:name]) {
        VKDataBase* target = [_dataBasMap objectForKey:name];
        BOOL success = [target close];
        if (success) {
            [_dataBasMap removeObjectForKey:name];
            if (self.currentDB == target) {
                self.currentDB = nil;
            }
        }
        return success;
    }else
    {
        return YES;
    }
}

-(BOOL)openDefault
{
    return [self openDataBaseWithName:[self getDefaultDataBaseName]];
}

-(BOOL)closeDefault
{
    return [self closeDataBaseWithName:[self getDefaultDataBaseName]];
}


-(VKDataBase *)currentDataBase
{
    return self.currentDB;
}

-(void)changeCurrentDataBase:(NSString *)name
{
    if ([_dataBasMap objectForKey:name]) {
        self.currentDB = [_dataBasMap objectForKey:name];
    }else
    {
        [self openDataBaseWithName:name];
    }
}

-(void)changeCurrentDataBaseDefault
{
    [self changeCurrentDataBase:[self getDefaultDataBaseName]];
}

-(NSString*)getDefaultDataBaseName
{
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    if ( nil == bundleName )
    {
        bundleName = @"default";
    }
    return bundleName;
}

+(NSArray *)doQuerySql:(NSString *)sql
{
    return [[self defaultManager] doQuerySql:sql];
}

-(NSArray *)doQuerySql:(NSString *)sql
{
    if (!self.currentDB) {
        return nil;
    }
    NSArray* rs = [self.currentDB executeQuerySql:sql];
    return rs;
}

+(BOOL)doUpdateSQL:(NSString *)sql
{
    return [[self defaultManager] doUpdateSQL:sql];
}

-(BOOL)doUpdateSQL:(NSString *)sql
{
    if (!self.currentDB) {
        return NO;
    }
    BOOL success = [self.currentDB executeUpdateSql:sql];
    return success;
}

+(NSInteger)lastInsertRowId
{
    return [[self defaultManager]lastInsertRowId];
}

-(NSInteger)lastInsertRowId
{
    return self.currentDB.lastInsertID;
}

-(NSInteger)lastInsertRowIdInDataBase:(NSString*)name
{
    if ([_dataBasMap objectForKey:name]) {
        VKDataBase* data = [_dataBasMap objectForKey:name];
        return data.lastInsertID;
    }
    return -1;
}

+(void)addQueryTaskSQL:(NSString *)sql
{
    [[self defaultManager] addQueryTaskSQL:sql];
}

-(void)addQueryTaskSQL:(NSString *)sql
{
    [self.sqlManager addQuery:sql];
}

+(void)addUpdateTaskSQL:(NSString *)sql
{
    [[self defaultManager] addUpdateTaskSQL:sql];
}

-(void)addUpdateTaskSQL:(NSString *)sql
{
    [self.sqlManager addUpdate:sql];
}

-(void)addDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block
{
    NSString* classname = NSStringFromClass([target class]);
    [self addDataBaseNotificationAtTarget:target withIdentifier:classname withComplete:block];
}

-(void)addDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block
{
    if ([_notificationMap objectForKey:idstr]) {
        //已存在
        VKDataBaseNotificationListener* linsen = [_notificationMap objectForKey:idstr];
        linsen.target = target;
        linsen.block = block;
    }else
    {
        VKDataBaseNotificationListener* linsen = [[VKDataBaseNotificationListener alloc]init];
        linsen.target = target;
        linsen.block = block;
        [_notificationMap setObject:linsen forKey:idstr];
    }
}

-(void)removeDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block
{
    NSString* classname = NSStringFromClass([target class]);
    [self removeDataBaseNotificationAtTarget:target withIdentifier:classname withComplete:block];
}

-(void)removeDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block
{
    if ([_notificationMap objectForKey:idstr]) {
        VKDataBaseNotificationListener* listen = [_notificationMap objectForKey:idstr];
        [_notificationMap removeObjectForKey:idstr];
        listen = nil;
    }else
    {
        return;
    }
}

-(void)executeQueueCompleteWithTag:(NSString *)tag withSuccess:(BOOL)success withData:(NSArray *)data
{
    //此时已经是主线程
    //对所有监听 执行block
    for (VKDataBaseNotificationListener* listen in _notificationMap.allValues) {
        listen.block(tag,success,data);
        NSString* notifications = success?VK_DataBaseNotificationBackGroundTaskSuccess:VK_DataBaseNotificationBackGroundTaskFail;
        [[NSNotificationCenter defaultCenter]postNotificationName:notifications object:nil];
    }
}

+(void)beginBackgroundQuery
{
    [[self defaultManager] beginBackgroundQuery];
}

-(void)beginBackgroundQuery
{
    [self.sqlManager clearQuery];
}

+(void)beginBackgroundUpdate
{
    [[self defaultManager] beginBackgroundUpdate];
}

-(void)beginBackgroundUpdate
{
    [self.sqlManager clearUpdate];
}

+(void)commitBackgroundQuery
{
    [[self defaultManager] commitBackgroundQueryWithTaskTag:VK_DefaultDataBaseQueryTaskTag errorRollback:NO];
}

+(void)commitBackgroundQueryWithTaskTag:(NSString *)tag
{
    [[self defaultManager] commitBackgroundQueryWithTaskTag:tag errorRollback:NO];
}

+(void)commitBackgroundQueryWithTaskTag:(NSString *)tag errorRollback:(BOOL)enablerollback
{
    [[self defaultManager] commitBackgroundQueryWithTaskTag:tag errorRollback:enablerollback];
}

-(void)commitBackgroundQueryWithTaskTag:(NSString *)tag errorRollback:(BOOL)enablerollback
{
    if (!self.currentDB) {
        return;
    }
    NSArray* querySqls = [self.sqlManager getAllQuerySQL];
    if (enablerollback) {
        [self.currentDB executeQueryQueueInTransaction:querySqls withTaskTag:tag];
    }else
    {
        [self.currentDB executeQueryQueueInDatabase:querySqls withTaskTag:tag];
    }
    [self.sqlManager clearQuery];
}
+(void)commitBackgroundUpdate
{
    [[self defaultManager] commitBackgroundUpdateWithTaskTag:VK_DefaultDataBaseUpdateTaskTag errorRollback:NO];
}

+(void)commitBackgroundUpdateWithTaskTag:(NSString *)tag
{
    [[self defaultManager] commitBackgroundUpdateWithTaskTag:tag errorRollback:NO];
}

+(void)commitBackgroundUpdateWithTaskTag:(NSString *)tag errorRollback:(BOOL)enablerollback
{
    [[self defaultManager] commitBackgroundUpdateWithTaskTag:tag errorRollback:enablerollback];
}

-(void)commitBackgroundUpdateWithTaskTag:(NSString *)tag errorRollback:(BOOL)enablerollback
{
    if (!self.currentDB) {
        return;
    }
    NSArray* updateSqls = [self.sqlManager getAllUpdateSQL];
    if (enablerollback) {
        [self.currentDB executeUpdateQueueInTransaction:updateSqls withTaskTag:tag];
    }else
    {
        [self.currentDB executeUpdateQueueInDatabase:updateSqls withTaskTag:tag];
    }
    [self.sqlManager clearUpdate];
}
@end
