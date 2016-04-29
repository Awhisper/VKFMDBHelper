//
//  VKDBManager.h
//
//  Created by awhisper on 15/2/5.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKDataBase.h"

#define VK_DefaultDataBaseQueryTaskTag @"defaultQuery"
#define VK_DefaultDataBaseUpdateTaskTag @"defaultUpdate"

#define VK_DataBaseNotificationBackGroundTaskSuccess @"DataBaseNotificationBackGroundTaskSuccess"
#define VK_DataBaseNotificationBackGroundTaskFail @"DataBaseNotificationBackGroundTaskFail"

typedef void(^VKDataBaseQueueBlockReturn)(NSString* tag,BOOL success,NSArray* result);

@interface VKDBManager : NSObject<VKDataBaseExecuteQueueCompleteDelegate>

- (instancetype)sharedInstance;

+ (instancetype)defaultManager;

-(BOOL)openDefault;

-(BOOL)closeDefault;

-(BOOL)openDataBaseWithName:(NSString*)name;

-(BOOL)closeDataBaseWithName:(NSString*)name;

-(VKDataBase*)currentDataBase;

-(void)changeCurrentDataBase:(NSString*)name;

-(void)changeCurrentDataBaseDefault;

-(void)addDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block;

-(void)removeDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block;

-(void)addDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block;

-(void)removeDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block;

+(NSInteger)lastInsertRowId;

+(void)addUpdateTaskSQL:(NSString*)sql;

+(void)addQueryTaskSQL:(NSString*)sql;

+(BOOL)doUpdateSQL:(NSString*)sql;

+(NSArray*)doQuerySql:(NSString*)sql;

+(void)beginBackgroundQuery;

+(void)beginBackgroundUpdate;

+(void)commitBackgroundQuery;

+(void)commitBackgroundQueryWithTaskTag:(NSString*)tag;

+(void)commitBackgroundQueryWithTaskTag:(NSString*)tag errorRollback:(BOOL)enablerollback;

+(void)commitBackgroundUpdate;

+(void)commitBackgroundUpdateWithTaskTag:(NSString*)tag;

+(void)commitBackgroundUpdateWithTaskTag:(NSString*)tag errorRollback:(BOOL)enablerollback;




@end
