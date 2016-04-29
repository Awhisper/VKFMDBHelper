//
//  VKSQLQueueManager.m
//
//  Created by awhisper on 15/2/5.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKSQLQueueManager.h"

@interface VKSQLQueueManager ()


@property (nonatomic,strong) NSMutableArray* sqlQueryQueue;
@property (nonatomic,strong) NSMutableArray* sqlUpdateQueue;

@end

@implementation VKSQLQueueManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.sqlQueryQueue = [[NSMutableArray alloc]init];
        self.sqlUpdateQueue = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)clearQuery
{
    [self.sqlQueryQueue removeAllObjects];
}

- (void)clearUpdate
{
    [self.sqlUpdateQueue removeAllObjects];
}

-(void)addQuery:(NSString *)querySQL
{
    [self.sqlQueryQueue addObject:querySQL];
}

-(void)addUpdate:(NSString *)updateSQL
{
    [self.sqlUpdateQueue addObject:updateSQL];
}

-(NSArray*)getAllQuerySQL
{
    NSArray* result = [NSArray arrayWithArray:self.sqlQueryQueue];
    return result;
}

-(NSArray *)getAllUpdateSQL
{
    NSArray* result = [NSArray arrayWithArray:self.sqlUpdateQueue];
    return result;
}

@end
