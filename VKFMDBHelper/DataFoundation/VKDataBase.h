//
//  VKDataBase.h
//
//  Created by awhisper on 15/2/4.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VKDataBaseExecuteQueueCompleteDelegate <NSObject>

-(void)executeQueueCompleteWithTag:(NSString*)tag withSuccess:(BOOL)success withData:(NSArray*)data;

@end

@interface VKDataBase : NSObject

@property (nonatomic,weak) id<VKDataBaseExecuteQueueCompleteDelegate> delegate;

@property (nonatomic,strong,readonly) NSString* DBName;

- (BOOL) openDB:(NSString*)name;

- (BOOL) close;

- (NSInteger) lastInsertID;

//查询操作
- (NSArray*) executeQuerySql:(NSString*)sql;

- (BOOL) executeUpdateSql:(NSString*)sql;

- (void) executeQueryQueueInDatabase:(NSArray *)sqlArr withTaskTag:(NSString*)tag;

- (void) executeQueryQueueInTransaction:(NSArray *)sqlArr withTaskTag:(NSString*)tag;

- (void) executeUpdateQueueInDatabase:(NSArray *)sqlArr withTaskTag:(NSString*)tag;

- (void) executeUpdateQueueInTransaction:(NSArray *)sqlArr withTaskTag:(NSString*)tag;

@end
