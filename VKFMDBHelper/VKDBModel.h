//
//  VKDBModel.h
//
//  Created by awhisper on 15/2/6.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VKDBModel : NSObject

@property (nonatomic,assign,readonly) NSInteger dataBaseId;


//inner use
+(NSString*)primaryKeyName;
+ (NSString *)tableName;
-(NSNumber*)primaryValue;



-(instancetype)initWithDictionary:(NSDictionary*)dic;


+(NSString*)uniqueKeyName;

+(void)mapProperties;

+(void)mapProperty:(NSString *)name AsArrayforClass:(NSString *)className;

+(BOOL)isPropertiesMaped;

+(BOOL)buildTable;

+(BOOL)clearTable;

-(BOOL)exsit;

-(BOOL)refresh;

-(void)refreshInnerDBModel;

-(void)saveInBackground;

-(void)saveToDB;

-(void)deleteFromDB;

-(void)deleteInBackground;

+(NSArray*)allObjectData;

+(void)allObjectDataQuerryInBackground;

+(NSArray*)objectDataWhereKeyName:(NSString*)key Opertor:(NSString*)opera Value:(NSString*)value;

+(void)objectDataQuerryInBackgroundWhereKeyName:(NSString*)key Opertor:(NSString*)opera Value:(NSString*)value;
@end
