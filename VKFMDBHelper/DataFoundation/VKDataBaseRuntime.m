//
//  VKDataBaseRuntime.m
//
//  Created by awhisper on 15/2/9.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDataBaseRuntime.h"


@implementation NSObject(VKDBTypeConversion)

- (NSInteger)asInteger
{
    return [[self asNSNumber] integerValue];
}

- (float)asFloat
{
    return [[self asNSNumber] floatValue];
}

- (BOOL)asBool
{
    return [[self asNSNumber] boolValue];
}

- (NSNumber *)asNSNumber
{
    if ( [self isKindOfClass:[NSNumber class]] )
    {
        return (NSNumber *)self;
    }
    else if ( [self isKindOfClass:[NSString class]] )
    {
        return [NSNumber numberWithFloat:[(NSString *)self floatValue]];
    }
    else if ( [self isKindOfClass:[NSDate class]] )
    {
        return [NSNumber numberWithDouble:[(NSDate *)self timeIntervalSince1970]];
    }
    else if ( [self isKindOfClass:[NSNull class]] )
    {
        return [NSNumber numberWithInteger:0];
    }
    
    return nil;
}

- (NSString *)asNSString
{
    if ( [self isKindOfClass:[NSNull class]] )
        return nil;
    
    if ( [self isKindOfClass:[NSString class]] )
    {
        return (NSString *)self;
    }
    else if ( [self isKindOfClass:[NSData class]] )
    {
        NSData * data = (NSData *)self;
        
        NSString * text = [[NSString alloc] initWithBytes:data.bytes length:data.length encoding:NSUTF8StringEncoding];
        if ( nil == text )
        {
            text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ( nil == text )
            {
                text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            }
        }
        return text;
    }
    else
    {
        return [NSString stringWithFormat:@"%@", self];
    }
}

- (NSDate *)asNSDate
{
    if ( [self isKindOfClass:[NSDate class]] )
    {
        return (NSDate *)self;
    }
    else if ( [self isKindOfClass:[NSString class]] )
    {
        NSDate * date = nil;
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss z"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)self];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)self];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)self];
        }
        
        if ( nil == date )
        {
            static NSDateFormatter * formatter = nil;
            
            if ( nil == formatter )
            {
                formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            }
            
            date = [formatter dateFromString:(NSString *)self];
        }
        
        return date;
        
        //		NSTimeZone * local = [NSTimeZone localTimeZone];
        //		return [NSDate dateWithTimeInterval:(3600 + [local secondsFromGMT])
        //								  sinceDate:[dateFormatter dateFromString:text]];
    }
    else
    {
        return [NSDate dateWithTimeIntervalSince1970:[self asNSNumber].doubleValue];
    }
    
    return nil;
}

- (NSData *)asNSData
{
    if ( [self isKindOfClass:[NSString class]] )
    {
        return [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    }
    else if ( [self isKindOfClass:[NSData class]] )
    {
        return (NSData *)self;
    }
    
    return nil;
}

- (NSArray *)asNSArray
{
    if ( [self isKindOfClass:[NSArray class]] )
    {
        return (NSArray *)self;
    }
    else
    {
        return [NSArray arrayWithObject:self];
    }
}

//- (NSArray *)asNSArrayWithClass:(Class)clazz
//{
//    if ( [self isKindOfClass:[NSArray class]] )
//    {
//        NSMutableArray * results = [NSMutableArray array];
//        
//        for ( NSObject * elem in (NSArray *)self )
//        {
//            if ( [elem isKindOfClass:[NSDictionary class]] )
//            {
//                NSObject * obj = [[self class] objectFromDictionary:elem];
//                [results addObject:obj];
//            }
//        }
//        
//        return results;
//    }
//    
//    return nil;
//}

- (NSMutableArray *)asNSMutableArray
{
    if ( [self isKindOfClass:[NSMutableArray class]] )
    {
        return (NSMutableArray *)self;
    }
    
    return nil;
}

//- (NSMutableArray *)asNSMutableArrayWithClass:(Class)clazz
//{
//    NSArray * array = [self asNSArrayWithClass:clazz];
//    if ( nil == array )
//        return nil;
//    
//    return [NSMutableArray arrayWithArray:array];
//}

- (NSDictionary *)asNSDictionary
{
    if ( [self isKindOfClass:[NSDictionary class]] )
    {
        return (NSDictionary *)self;
    }
    
    return nil;
}

- (NSMutableDictionary *)asNSMutableDictionary
{
    if ( [self isKindOfClass:[NSMutableDictionary class]] )
    {
        return (NSMutableDictionary *)self;
    }
    
    NSDictionary * dict = [self asNSDictionary];
    if ( nil == dict )
        return nil;
    
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}

@end

@implementation VKDataBaseRuntime


+ (NSString *)tableNameForIdentifier:(NSString *)identifier
{
    NSString* identifierstr = [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( identifierstr.length >= 2 )
    {
        if ( [identifierstr hasPrefix:@"\""] && [identifierstr hasSuffix:@"\""] )
        {
            identifierstr = [identifierstr substringWithRange:NSMakeRange(1, identifierstr.length - 2)];
        }
        
        if ( [identifierstr hasPrefix:@"'"] && [identifierstr hasSuffix:@"'"] )
        {
            identifierstr = [identifierstr substringWithRange:NSMakeRange(1, identifierstr.length - 2)];
        }
    }
    
    NSString * name = identifierstr;
    name = [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return name;
}

+ (NSString *)fieldNameForIdentifier:(NSString *)identifier
{
    NSString* identifierstr = [identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( identifierstr.length >= 2 )
    {
        if ( [identifierstr hasPrefix:@"\""] && [identifierstr hasSuffix:@"\""] )
        {
            identifierstr = [identifierstr substringWithRange:NSMakeRange(1, identifierstr.length - 2)];
        }
        
        if ( [identifierstr hasPrefix:@"'"] && [identifierstr hasSuffix:@"'"] )
        {
            identifierstr = [identifierstr substringWithRange:NSMakeRange(1, identifierstr.length - 2)];
        }
    }
    
    NSString * name = identifierstr;
    name = [name stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    name = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return name;
}

+ (Class)classOfAttribute:(const char *)attr
{
    NSString * className = [self classNameOfAttribute:attr];
    if ( nil == className )
        return nil;
    
    return NSClassFromString( className );
}

+ (NSString *)classNameOfAttribute:(const char *)attr
{
    if ( attr[0] != 'T' )
        return nil;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return nil;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        return [NSString stringWithUTF8String:typeClazz];
    }
    
    return nil;
}


+ (NSUInteger)typeOf:(const char *)attr
{
    if ( attr[0] != 'T' )
        return VK_DBRuntime_PropertyType_UNKNOWN;
    
    const char * type = &attr[1];
    if ( type[0] == '@' )
    {
        if ( type[1] != '"' )
            return VK_DBRuntime_PropertyType_UNKNOWN;
        
        char typeClazz[128] = { 0 };
        
        const char * clazz = &type[2];
        const char * clazzEnd = strchr( clazz, '"' );
        
        if ( clazzEnd && clazz != clazzEnd )
        {
            unsigned int size = (unsigned int)(clazzEnd - clazz);
            strncpy( &typeClazz[0], clazz, size );
        }
        
        if ( 0 == strcmp((const char *)typeClazz, "NSNumber") )
        {
            return VK_DBRuntime_PropertyType_NSNUMBER;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSString") )
        {
            return VK_DBRuntime_PropertyType_NSSTRING;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDate") )
        {
            return VK_DBRuntime_PropertyType_NSDATE;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSArray") )
        {
            return VK_DBRuntime_PropertyType_NSARRAY;
        }
        else if ( 0 == strcmp((const char *)typeClazz, "NSDictionary") )
        {
            return VK_DBRuntime_PropertyType_NSDICTIONARY;
        }
        else
        {
            return VK_DBRuntime_PropertyType_NSOBJECT;
        }
    }
    else if ( type[0] == '[' )
    {
        return VK_DBRuntime_PropertyType_UNKNOWN;
    }
    else if ( type[0] == '{' )
    {
        return VK_DBRuntime_PropertyType_UNKNOWN;
    }
    else
    {
        if ( type[0] == 'c' || type[0] == 'C' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == 'i' || type[0] == 's' || type[0] == 'l' || type[0] == 'q' )
        {
            return VK_DBRuntime_PropertyType_NSNUMBER;
        }
        else if ( type[0] == 'I' || type[0] == 'S' || type[0] == 'L' || type[0] == 'Q' )
        {
            return VK_DBRuntime_PropertyType_NSNUMBER;
        }
        else if ( type[0] == 'f' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == 'd' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == 'B' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == 'v' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == '*' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == ':' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( 0 == strcmp(type, "bnum") )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == '^' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else if ( type[0] == '?' )
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
        else
        {
            return VK_DBRuntime_PropertyType_UNKNOWN;
        }
    }
    
    return VK_DBRuntime_PropertyType_UNKNOWN;
}

@end
