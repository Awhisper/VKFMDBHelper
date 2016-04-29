//
//  VKSQLQueueManager.h
//
//  Created by awhisper on 15/2/5.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKSQLQueueManager : NSObject

- (void)clearQuery;

- (void)clearUpdate;

- (void)addQuery:(NSString*)querySQL;

- (void)addUpdate:(NSString*)updateSQL;

- (NSArray*)getAllQuerySQL;

- (NSArray*)getAllUpdateSQL;

@end
