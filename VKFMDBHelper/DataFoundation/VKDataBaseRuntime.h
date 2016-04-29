//
//  VKDataBaseRuntime.h
//
//  Created by awhisper on 15/2/9.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define VK_DBRuntime_PropertyType_INVALID_ID @(-1)
#define VK_DBRuntime_PropertyType_UNKNOWN 0
#define VK_DBRuntime_PropertyType_NSOBJECT 1
#define VK_DBRuntime_PropertyType_NSNUMBER 2
#define VK_DBRuntime_PropertyType_NSSTRING 3
#define VK_DBRuntime_PropertyType_NSARRAY 4
#define VK_DBRuntime_PropertyType_NSDICTIONARY 5
#define VK_DBRuntime_PropertyType_NSDATE 6

@interface VKDataBaseRuntime : NSObject

+ (NSString *)tableNameForIdentifier:(NSString *)identifier;

+ (NSString *)fieldNameForIdentifier:(NSString *)identifier;

+ (NSString *)classNameOfAttribute:(const char *)attr;

+ (Class)classOfAttribute:(const char *)attr;

+ (NSUInteger)typeOf:(const char *)attr;

@end


@interface NSObject(VKDBTypeConversion)

- (NSInteger)asInteger;
- (float)asFloat;
- (BOOL)asBool;

- (NSNumber *)asNSNumber;
- (NSString *)asNSString;
- (NSDate *)asNSDate;
- (NSData *)asNSData;	// TODO
- (NSArray *)asNSArray;
//- (NSArray *)asNSArrayWithClass:(Class)clazz;
- (NSMutableArray *)asNSMutableArray;
//- (NSMutableArray *)asNSMutableArrayWithClass:(Class)clazz;
- (NSDictionary *)asNSDictionary;
- (NSMutableDictionary *)asNSMutableDictionary;

@end
