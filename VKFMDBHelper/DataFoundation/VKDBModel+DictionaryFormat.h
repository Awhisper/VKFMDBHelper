//
//  VKDBModel+DictionaryFormat.h
//
//  Created by awhisper on 15/2/8.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDBModel.h"

@interface VKDBNonValue : NSObject
+ (VKDBNonValue *)value;
@end

@interface VKDBModel (DictionaryFormat)


#pragma mark -  

- (NSMutableDictionary *)dataBasePropertySet;
+ (NSMutableDictionary *)dataBasePropertySet;
+ (NSMutableDictionary *)dataBasePropertySetFor:(Class)clazz;


#pragma mark -

- (NSString *)dataBasePrimaryKey;
+ (NSString *)dataBasePrimaryKey;
+ (NSString *)dataBasePrimaryKeyFor:(Class)clazz;

#pragma mark - Property Map

+ (BOOL)isRelationMapped;
+ (void)mapRelation;						// for subclass
+ (void)mapRelationForClass:(Class)clazz;	// for subclass


+ (void)mapPropertyAsKey:(NSString *)name;
+ (void)mapPropertyAsKey:(NSString *)name defaultValue:(id)value;
+ (void)mapPropertyAsKey:(NSString *)name atPath:(NSString *)path;
+ (void)mapPropertyAsKey:(NSString *)name atPath:(NSString *)path defaultValue:(id)value;

+ (void)mapProperty:(NSString *)name;
+ (void)mapProperty:(NSString *)name defaultValue:(id)value;
+ (void)mapProperty:(NSString *)name atPath:(NSString *)path;
+ (void)mapProperty:(NSString *)name atPath:(NSString *)path defaultValue:(id)value;
+ (void)mapProperty:(NSString *)name forClass:(NSString *)className;
+ (void)mapProperty:(NSString *)name forClass:(NSString *)className defaultValue:(id)value;
+ (void)mapProperty:(NSString *)name forClass:(NSString *)className atPath:(NSString *)path;
+ (void)mapProperty:(NSString *)name forClass:(NSString *)className atPath:(NSString *)path defaultValue:(id)value;
+ (void)mapProperty:(NSString *)name associateTo:(NSString *)clazz;
+ (void)mapProperty:(NSString *)name associateTo:(NSString *)clazz defaultValue:(id)value;

+ (void)mapPropertyAsArray:(NSString *)name forClass:(NSString *)className;
+ (void)mapPropertyAsArray:(NSString *)name forClass:(NSString *)className defaultValue:(id)value;

+ (void)mapPropertyAsArray:(NSString *)name;
+ (void)mapPropertyAsArray:(NSString *)name defaultValue:(id)value;

+ (void)mapPropertyAsDictionary:(NSString *)name;
+ (void)mapPropertyAsDictionary:(NSString *)name defaultValue:(id)value;

#pragma mark -

+ (NSString *)mapTableName;					// for subclass


#pragma mark -

+ (void)useAutoIncrement;
+ (void)useAutoIncrementFor:(Class)clazz;

+ (BOOL)isAutoIncrement;
+ (BOOL)isAutoIncrementFor:(Class)clazz;

+ (void)useAutoIncrementFor:(Class)clazz andProperty:(NSString *)name;
+ (BOOL)isAutoIncrementFor:(Class)clazz andProperty:(NSString *)name;

+ (void)useAutoIncrementForProperty:(NSString *)name;
+ (BOOL)isAutoIncrementForProperty:(NSString *)name;

+ (void)useUniqueFor:(Class)clazz andProperty:(NSString *)name;
+ (BOOL)isUniqueFor:(Class)clazz andProperty:(NSString *)name;

+ (void)useUniqueForProperty:(NSString *)name;
+ (BOOL)isUniqueForProperty:(NSString *)name;





@end
