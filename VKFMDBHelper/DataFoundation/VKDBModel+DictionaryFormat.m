//
//  VKDBModel+DictionaryFormat.m
//
//  Created by awhisper on 15/2/8.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDBModel+DictionaryFormat.h"
#import <objc/runtime.h>
#import "VKDataBaseRuntime.h"


@implementation VKDBNonValue

+ (VKDBNonValue *)value
{
    static VKDBNonValue * _vk_non_value = nil;
    
    if ( nil == _vk_non_value )
    {
        _vk_non_value = [[VKDBNonValue alloc] init];
    }
    
    return _vk_non_value;
}

@end

@implementation VKDBModel (DictionaryFormat)

static NSMutableDictionary * _vk_primaryKeys = nil;
static NSMutableDictionary * _vk_properties = nil;
static NSMutableDictionary * _vk_usingAI = nil;
static NSMutableDictionary * _vk_usingUN = nil;
static NSMutableDictionary * _vk_mapped = nil;

//// map logic


+ (BOOL)isRelationMapped
{
    if ( nil == _vk_mapped )
        return NO;
    
    NSString * className = [self description];
    NSNumber * mapped = [_vk_mapped objectForKey:className];
    if ( mapped && mapped.boolValue )
        return YES;
    
    return NO;
}

+ (void)mapRelation
{
    [self mapRelationForClass:[VKDBModel class]];
}

+ (void)mapRelationForClass:(Class)rootClass
{
    if ( self == rootClass )
        return;
    
    if ( nil == _vk_mapped )
    {
        _vk_mapped = [[NSMutableDictionary alloc] init];
    }
    
    NSString * className = [self description];
    NSNumber * mapped = [_vk_mapped objectForKey:className];
    if ( mapped && mapped.boolValue )
        return;
    
//#if (__ON__ == __ID_AS_KEY__)
    BOOL foundPrimaryKey = NO;
//#endif	// #if (__ON__ == __ID_AS_KEY__)
    
    for ( Class clazzType = self; clazzType != rootClass; )
    {
        unsigned int		propertyCount = 0;
        objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ )
        {
            const char *	name = property_getName(properties[i]);
            NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            if ( [propertyName hasSuffix:@"_"] )
                continue;
            
            const char *	attr = property_getAttributes(properties[i]);
            NSUInteger		type = [VKDataBaseRuntime typeOf:attr];
            
            if ( VK_DBRuntime_PropertyType_NSNUMBER == type )
            {
                BOOL isPrimaryKey = NO;
                
//#if (__ON__ == __ID_AS_KEY__)
                if ( NO == foundPrimaryKey && [propertyName isEqualToString:self.primaryKeyName] )
                {
                    isPrimaryKey = YES;
                    foundPrimaryKey = YES;
                }
//#endif	// #if (__ON__ == __ID_AS_KEY__)
                
//#if (__ON__ == __AUTO_PRIMARY_KEY__ )
//                if ( NO == foundPrimaryKey )
//                {
//                    isPrimaryKey = YES;
//                    foundPrimaryKey = YES;
//                }
//#endif	// #if (__ON__ == __AUTO_PRIMARY_KEY__ )
                
                if ( isPrimaryKey )
                {
                    [self mapPropertyAsKey:propertyName];
                }
                else
                {
                    [self mapProperty:propertyName defaultValue:@0];
                }
            }
            else if ( VK_DBRuntime_PropertyType_NSSTRING == type )
            {
                [self mapProperty:propertyName defaultValue:@""];
            }
            else if ( VK_DBRuntime_PropertyType_NSDATE == type )
            {
                [self mapProperty:propertyName defaultValue:[NSDate dateWithTimeIntervalSince1970:0]];
            }
            else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type )
            {
                //制造crash  不支持 dbmodel 内嵌字典
                NSParameterAssert(type != VK_DBRuntime_PropertyType_NSDICTIONARY);
                [self mapPropertyAsDictionary:propertyName defaultValue:[NSMutableDictionary dictionary]];
            }
            else if ( VK_DBRuntime_PropertyType_NSARRAY == type )
            {
                //支持内嵌数组 但是 后面还有数组 assert  不支持数组内嵌 非dbmodel string number的对象
                [self mapPropertyAsArray:propertyName defaultValue:[NSMutableArray array]];
            }
            else if ( VK_DBRuntime_PropertyType_NSOBJECT == type )
            {
                NSString * attrClassName = [VKDataBaseRuntime classNameOfAttribute:attr];
                if ( attrClassName )
                {
                    Class class = NSClassFromString( attrClassName );
                    if ( class )
                    {
                        if ( [class isSubclassOfClass:rootClass] )
                        {
                            [self mapProperty:propertyName forClass:attrClassName defaultValue:nil];
                        }
                        else
                        {   //制造crash  不支持 dbmodel 其他非DBModel的对象
                            NSParameterAssert(type != VK_DBRuntime_PropertyType_NSOBJECT);
                            [self mapProperty:propertyName forClass:attrClassName defaultValue:@""];
                        }
                    }
                }
            }
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    if (!foundPrimaryKey) {
        [self mapPropertyAsKey:self.primaryKeyName defaultValue:@(-1)];
    }
    
    [_vk_mapped setObject:[NSNumber numberWithBool:YES]
                 forKey:className];
}


+ (void)mapPropertyAsKey:(NSString *)name
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:YES
               isArray:NO
          isDictionary:NO];
}

+ (void)mapPropertyAsKey:(NSString *)name defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:YES
               isArray:NO
          isDictionary:NO];
}

+ (void)mapPropertyAsKey:(NSString *)name atPath:(NSString *)path
{
    [self addProtperty:name
                atPath:path
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:YES
               isArray:NO
          isDictionary:NO];
}

+ (void)mapPropertyAsKey:(NSString *)name atPath:(NSString *)path defaultValue:(id)value
{
    [self addProtperty:name
                atPath:path
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:YES
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name atPath:(NSString *)path
{
    [self addProtperty:name
                atPath:path
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name atPath:(NSString *)path defaultValue:(id)value
{
    [self addProtperty:name
                atPath:path
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name forClass:(NSString *)className
{
    [self addProtperty:name
                atPath:nil
              forClass:className
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name forClass:(NSString *)className defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:className
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name forClass:(NSString *)className atPath:(NSString *)path
{
    [self addProtperty:name
                atPath:path
              forClass:className
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name forClass:(NSString *)className atPath:(NSString *)path defaultValue:(id)value
{
    [self addProtperty:name
                atPath:path
              forClass:className
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name associateTo:(NSString *)domain
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:domain
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapProperty:(NSString *)name associateTo:(NSString *)domain defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:domain
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:NO];
}

+ (void)mapPropertyAsArray:(NSString *)name forClass:(NSString *)className
{
    [self addProtperty:name
                atPath:nil
              forClass:className
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:YES
          isDictionary:NO];
}

+ (void)mapPropertyAsArray:(NSString *)name forClass:(NSString *)className defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:className
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:YES
          isDictionary:NO];
}

+ (void)mapPropertyAsArray:(NSString *)name
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:YES
          isDictionary:NO];
}

+ (void)mapPropertyAsArray:(NSString *)name defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:YES
          isDictionary:NO];
}

+ (void)mapPropertyAsDictionary:(NSString *)name
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:nil
                   key:NO
               isArray:NO
          isDictionary:YES];
}

+ (void)mapPropertyAsDictionary:(NSString *)name defaultValue:(id)value
{
    [self addProtperty:name
                atPath:nil
              forClass:nil
           associateTo:nil
          defaultValue:value
                   key:NO
               isArray:NO
          isDictionary:YES];
}

+ (void)addProtperty:(NSString *)name
              atPath:(NSString *)path
            forClass:(NSString *)className
         associateTo:(NSString *)domain
        defaultValue:(id)value
                 key:(BOOL)key
             isArray:(BOOL)isArray
        isDictionary:(BOOL)isDictionary
{
    // add primary key
    
    if ( key )
    {
        if ( nil == _vk_primaryKeys )
        {
            _vk_primaryKeys = [[NSMutableDictionary alloc] init];
        }
        
        [_vk_primaryKeys setObject:name forKey:[self description]];
        [self useAutoIncrementForProperty:name];
    }
    
    // add property
    
    if ( nil == _vk_properties )
    {
        _vk_properties = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableDictionary * propertySet = self.dataBasePropertySet;
    if ( propertySet )
    {
        NSMutableDictionary * property = [propertySet objectForKey:name];
        if ( nil == property )
        {
            property = [NSMutableDictionary dictionary];
            [propertySet setObject:property forKey:name];
        }
        
        if ( property )
        {
            [property setObject:name forKey:@"name"];			
            [property setObject:(key ? @"YES" : @"NO") forKey:@"key"];
            [property setObject:[VKDataBaseRuntime fieldNameForIdentifier:name] forKey:@"field"];
            [property setObject:[self description] forKey:@"byClass"];
            
            if ( domain )
            {
                NSArray * components = [domain componentsSeparatedByString:@"."];
                if ( components.count >= 2 )
                {
                    NSString * className = [components objectAtIndex:0];
                    NSString * propertyName = [components objectAtIndex:1];
                    
                    [property setObject:className forKey:@"associateClass"];
                    [property setObject:propertyName forKey:@"associateProperty"];
                }
                else
                {
                    [property setObject:domain forKey:@"associateClass"];
                }
            }
            
            if ( className )
            {
                [property setObject:className forKey:@"className"];
            }
            
            path = path ? [self keyPathFromString:path] : name;
            if ( path )
            {
                [property setObject:path forKey:@"path"];
            }
            
            if ( value )
            {
                [property setObject:value forKey:@"value"];
            }
            else
            {
                [property setObject:[VKDBNonValue value] forKey:@"value"];
            }
            
            if ( isArray )
            {
                [property setObject:@YES forKey:@"isArray"];
            }
            
            if ( isDictionary )
            {
                [property setObject:@YES forKey:@"isDictionary"];
            }
        }
    }
}

#pragma mark -

+ (NSString *)mapTableName
{
    return [NSString stringWithUTF8String:class_getName(self)];
}


- (NSMutableDictionary *)dataBasePropertySet
{
    return [[self class] dataBasePropertySet];
}

+ (NSMutableDictionary *)dataBasePropertySet
{
    return [self dataBasePropertySetFor:self];
}

+ (NSMutableDictionary *)dataBasePropertySetFor:(Class)clazz
{
    if ( nil == _vk_properties )
    {
        _vk_properties = [[NSMutableDictionary alloc] init];
    }
    
    NSString * className = [clazz description];
    NSMutableDictionary * propertySet = [_vk_properties objectForKey:className];
    if ( nil == propertySet )
    {
        propertySet = [NSMutableDictionary dictionary];
        [_vk_properties setObject:propertySet forKey:className];
    }
    
    return propertySet;
}


#pragma mark - unique autoincrement flag


+ (void)useAutoIncrement
{
    [self useAutoIncrementFor:self];
}

+ (void)useAutoIncrementFor:(Class)clazz
{
    if ( nil == _vk_usingAI )
    {
        _vk_usingAI = [[NSMutableDictionary alloc] init];
    }
    
    [_vk_usingAI setObject:@YES forKey:[clazz description]];
}

+ (BOOL)isAutoIncrement
{
    return [self isAutoIncrementFor:self];
}

+ (BOOL)isAutoIncrementFor:(Class)clazz
{
    if ( nil == _vk_usingAI )
        return NO;
    
    NSNumber * flag = [_vk_usingAI objectForKey:[clazz description]];
    if ( flag )
        return flag.boolValue;
    
    return NO;
}

+ (void)useAutoIncrementFor:(Class)clazz andProperty:(NSString *)name
{
    if ( nil == _vk_usingAI )
    {
        _vk_usingAI = [[NSMutableDictionary alloc] init];
    }
    
    NSString * key = [NSString stringWithFormat:@"%@.%@", [clazz description], name];
    [_vk_usingAI setObject:@YES forKey:key];
}

+ (BOOL)isAutoIncrementFor:(Class)clazz andProperty:(NSString *)name
{
    if ( nil == _vk_usingAI )
        return NO;
    
    NSString * key = [NSString stringWithFormat:@"%@.%@", [clazz description], name];
    NSNumber * flag = [_vk_usingAI objectForKey:key];
    if ( flag )
        return flag.boolValue;
    
    return NO;
}

+ (void)useAutoIncrementForProperty:(NSString *)name
{
    return [self useAutoIncrementFor:self andProperty:name];
}

+ (BOOL)isAutoIncrementForProperty:(NSString *)name
{
    return [self isAutoIncrementFor:self andProperty:name];
}

+ (void)useUniqueFor:(Class)clazz andProperty:(NSString *)name
{
    if ( nil == _vk_usingUN )
    {
        _vk_usingUN = [[NSMutableDictionary alloc] init];
    }
    
    NSString * key = [NSString stringWithFormat:@"%@.%@", [clazz description], name];
    [_vk_usingUN setObject:@YES forKey:key];
}

+ (BOOL)isUniqueFor:(Class)clazz andProperty:(NSString *)name
{
    if ( nil == _vk_usingUN )
        return NO;
    
    NSString * key = [NSString stringWithFormat:@"%@.%@", [clazz description], name];
    NSNumber * flag = [_vk_usingUN objectForKey:key];
    if ( flag )
        return flag.boolValue;
    
    return NO;
}

+ (void)useUniqueForProperty:(NSString *)name
{
    [self useUniqueFor:self andProperty:name];
}

+ (BOOL)isUniqueForProperty:(NSString *)name
{
    return [self isUniqueFor:self andProperty:name];
}


- (NSString *)dataBasePrimaryKey
{
    return [[self class] dataBasePrimaryKey];
}

+ (NSString *)dataBasePrimaryKey
{
    return [self dataBasePrimaryKeyFor:self];
}

+ (NSString *)dataBasePrimaryKeyFor:(Class)clazz
{
    if ( _vk_primaryKeys )
    {
        NSString * key = [clazz description];
        NSString * value = (NSString *)[_vk_primaryKeys objectForKey:key];
        if ( value )
            return value;
    }
    
    return nil;
}

#pragma mark - foundation function
+ (NSString *)keyPathFromString:(NSString *)path
{
    NSString *	keyPath = [path stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    NSRange		range = NSMakeRange( 0, 1 );
    
    if ( [[keyPath substringWithRange:range] isEqualToString:@"."] )
    {
        keyPath = [keyPath substringFromIndex:1];
    }
    
    return keyPath;
}



@end
