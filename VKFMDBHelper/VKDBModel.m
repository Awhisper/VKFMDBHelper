//
//  VKDBModel.m
//
//  Created by awhisper on 15/2/6.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKDBModel.h"
#import "VKDBModel+DictionaryFormat.h"
#import "VKDataBaseRuntime.h"
#import "VKSqlGenerator.h"
#import "VKDataBaseRuntime.h"
#import "VKDBManager.h"

@interface VKDBModel ()
{
    BOOL _dbChanging ;
    BOOL _dbDeleted ;
}

@end

@implementation VKDBModel

static NSMutableDictionary * _vk_createTable = nil;

-(instancetype)init{
    self = [super init];
    if (self) {
//        [self setObservers];
        [[self class] mapProperties];
        if ([[self class] uniqueKeyName]) {
            [[self class] useUniqueForProperty:[[self class] uniqueKeyName]];
        }
        [self resetProperties];
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dic
{
    self = [self init];
    if (self) {
        [self setPropertiesFrom:dic];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
/*
-(void)dealloc
{
    [self removeObservers];
}

- (void)setObservers
{
//#if __JSON_SERIALIZATION__
    
    NSMutableDictionary * propertySet = self.dataBasePropertySet;
    if ( propertySet && propertySet.count )
    {
        for ( NSString * key in propertySet.allKeys )
        {
            NSDictionary * property = [propertySet objectForKey:key];
            
            NSString * name = [property objectForKey:@"name"];
//            NSString * path = [property objectForKey:@"path"];
            
            [self addObserver:self
                   forKeyPath:name
                      options:NSKeyValueObservingOptionNew//|NSKeyValueObservingOptionOld
                      context:&property];
            
//            [_JSON addObserver:self
//                    forKeyPath:path
//                       options:NSKeyValueObservingOptionNew//|NSKeyValueObservingOptionOld
//                       context:property];
        }
    }
    
//#endif	// #if __JSON_SERIALIZATION__
}

- (void)removeObservers
{
//#if __JSON_SERIALIZATION__
    
    NSMutableDictionary * propertySet = self.dataBasePropertySet;
    if ( propertySet && propertySet.count )
    {
        for ( NSString * key in propertySet.allKeys )
        {
            NSDictionary * property = [propertySet objectForKey:key];
            
            NSString * name = [property objectForKey:@"name"];
//            NSString * path = [property objectForKey:@"path"];
            
            [self removeObserver:self forKeyPath:name];
//            [_JSON removeObserver:self forKeyPath:path];
        }
    }
    
//#endif	// #if __JSON_SERIALIZATION__
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( _deleted )
        return;
    
    if (object != self) {
        return;
    }
    
    NSObject * obj1 = [change objectForKey:@"new"];
    NSObject * obj2 = [change objectForKey:@"old"];
    
    if ( NO == [obj1 isEqual:obj2] )
    {
        _changed = YES;
    }
}

*/

- (void)resetProperties
{
    _dbChanging = NO;
    _dbDeleted = NO;
    
    NSMutableDictionary * propertySet = self.dataBasePropertySet;
    if ( nil == propertySet )
        return;
    
    NSString * primaryKey = [[self class] primaryKeyName];
    if ( primaryKey )
    {
        [self setValue:VK_DBRuntime_PropertyType_INVALID_ID forKey:primaryKey];
    }
//    
//#if __JSON_SERIALIZATION__
//    
//    NSString * JSONKey = self.activeJSONKey;
//    if ( _JSON )
//    {
//        [_JSON removeAllObjects];
//        
//        NSDictionary * property = [propertySet objectForKey:JSONKey];
//        if ( property )
//        {
//            NSString * path = [property objectForKey:@"path"];
//            if ( path )
//            {
//                [_JSON setObject:self.INVALID_ID atPath:path];
//            }
//        }
//    }
//    
//#endif	// #if __JSON_SERIALIZATION__
    
    if ( propertySet && propertySet.count )
    {
        for ( NSString * key in propertySet.allKeys )
        {
            NSDictionary * property = [propertySet objectForKey:key];
            
            NSString * name = [property objectForKey:@"name"];
            //			NSString * path = [property objectForKey:@"path"];
            NSNumber * type = [property objectForKey:@"type"];
            
//#if __JSON_SERIALIZATION__
//            NSObject * json = nil;
//#endif	// #if __JSON_SERIALIZATION__
            
            NSObject * value = [property objectForKey:@"value"];
            
            if ( value && NO == [value isKindOfClass:[VKDBNonValue class]] )
            {
                if ( VK_DBRuntime_PropertyType_NSNUMBER == type.intValue )
                {
                    value = [value asNSNumber];
                    
//#if __JSON_SERIALIZATION__
//                    json = value;
//#endif	// #if __JSON_SERIALIZATION__
                }
                else if ( VK_DBRuntime_PropertyType_NSSTRING == type.intValue )
                {
                    value = [value asNSString];
                    
//#if __JSON_SERIALIZATION__
//                    json = value;
//#endif	// #if __JSON_SERIALIZATION__
                }
                else if ( VK_DBRuntime_PropertyType_NSDATE == type.intValue )
                {
                    value = [value asNSString];
                    
//#if __JSON_SERIALIZATION__
//                    json = value;
//#endif	// #if __JSON_SERIALIZATION__
                }
                else if ( VK_DBRuntime_PropertyType_NSARRAY == type.intValue )
                {
                    NSMutableArray *	defaultValue = [NSMutableArray array];
                    NSArray *			array = nil;
                    
                    if ( [value isKindOfClass:[NSArray class]] )
                    {
                        array = (NSArray *)value;
                    }
//                    else if ( [value isKindOfClass:[NSString class]] )
//                    {
//                        NSObject * obj = [(NSString *)value objectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:nil];
//                        if ( [obj isKindOfClass:[NSArray class]] )
//                        {
//                            array = (NSArray *)obj;
//                        }
//                    }
                    
                    if ( array && array.count )
                    {
                        value = [array asNSMutableArray];
                        
//#if __JSON_SERIALIZATION__
//                        json = [array objectToString];
//#endif	// #if __JSON_SERIALIZATION__
                    }
                    else
                    {
                        value = defaultValue;
                        
//#if __JSON_SERIALIZATION__
//                        json = [defaultValue JSONString];
//#endif	// #if __JSON_SERIALIZATION__
                    }
                }
                else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type.intValue )
                {
                    //制造crash  不支持 dbmodel 内嵌字典
                    NSParameterAssert(type.intValue != VK_DBRuntime_PropertyType_NSDICTIONARY);
                    value = [value asNSMutableDictionary];
                    
//#if __JSON_SERIALIZATION__
//                    json = [(NSDictionary *)value JSONString];
//#endif	// #if __JSON_SERIALIZATION__
                }
                else if ( VK_DBRuntime_PropertyType_NSDATE == type.intValue )
                {
                    value = [value asNSString];
                    
//#if __JSON_SERIALIZATION__
//                    json = value;
//#endif	// #if __JSON_SERIALIZATION__
                }
                else if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
                {
                    
                    // 尝试创建默认的AR对象
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        if ( class )
                        {
                            if ( [class isSubclassOfClass:[VKDBModel class]] )
                            {
//                                NSNumber * primaryKey = [value asNSNumber];
//                                if ( primaryKey && primaryKey.unsignedIntValue )
//                                {
//                                    arValue = [class recordWithKey:[value asNSNumber]];
//                                    
//                                    value = arValue;
//                                    
////#if __JSON_SERIALIZATION__
////                                    json = [arValue JSON];
////#endif	// #if __JSON_SERIALIZATION__
//                                }
//                                else
//                                {
                                    value = nil;
                                    
//#if __JSON_SERIALIZATION__
//                                    json = nil;
//#endif	// #if __JSON_SERIALIZATION__
//                                }
                                
                            }
                            else
                            {
                                //制造crash  不支持 dbmodel 其他非DBModel的对象
                                NSParameterAssert(type.intValue != VK_DBRuntime_PropertyType_NSOBJECT);
                                value = nil;
                                
//#if __JSON_SERIALIZATION__
//                                json = nil;
//#endif	// #if __JSON_SERIALIZATION__
                            }
                        }
                        else
                        {
                            value = nil;
                            
//#if __JSON_SERIALIZATION__
//                            json = nil;
//#endif	// #if __JSON_SERIALIZATION__
                        }
                    }
                }
                
                [self setValue:value forKey:name];
                
//#if __JSON_SERIALIZATION__
//                if ( json )
//                {
//                    [_JSON setObject:json atPath:path];
//                }
//                //				else
//                //				{
//                //					[_JSON setObject:nil atPath:path];
//                //				}
//#endif	// #if __JSON_SERIALIZATION__
            }
            else
            {
                NSObject * value = nil;
                
                if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
                {
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        if ( class )
                        {
                            if ([class isSubclassOfClass:[VKDBModel class]]) {
                                value = [[class alloc] init];
                            }else
                            {
                                NSParameterAssert(type.intValue != VK_DBRuntime_PropertyType_NSOBJECT);
                            }
                            
                        }
                    }
                }
                
                if ( value )
                {
                    [self setValue:value forKey:name];
                }
            }
        }
    }
}

- (void)setPropertiesFrom:(NSDictionary *)dict
{
    // set properties
    
    NSMutableDictionary * propertySet = self.dataBasePropertySet;
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        
        NSString * name = [property objectForKey:@"name"];
//        NSString * path = [property objectForKey:@"path"];
        NSNumber * type = [property objectForKey:@"type"];
        
        NSString * associateClass = [property objectForKey:@"associateClass"];
//        NSString * associateProperty = [property objectForKey:@"associateProperty"];
        
        NSMutableArray * values = [NSMutableArray array];
        
        if ( associateClass )
        {
//            Class classType = NSClassFromString( associateClass );
//            if ( classType )
//            {
//                NSArray * objs = [super.DB associateObjectsFor:classType];
//                for ( NSObject * obj in objs )
//                {
//                    if ( associateProperty )
//                    {
//                        NSObject * value = [obj valueForKey:associateProperty];
//                        [values addObject:value];
//                    }
//                    else
//                    {
//                        NSObject * value = [obj valueForKey:classType.activePrimaryKey];
//                        [values addObject:value];
//                    }
//                }
//            }
        }
        
        NSObject * value = values.count ? values.lastObject : nil;
        
        if ( nil == value )
        {
//            value = [dict objectAtPath:path];
//            
//            if ( nil == value )
//            {
                value = [dict objectForKey:name];
//            }
        }
        
        if ( nil == value )
        {
            value = [property objectForKey:@"value"];
            
            if ( [value isKindOfClass:[VKDBNonValue class]] || [value isKindOfClass:[NSNull class]] )
            {
                value = nil;
            }
        }
        
        if ( value && NO == [value isKindOfClass:[VKDBNonValue class]] )
        {
            if ( VK_DBRuntime_PropertyType_NSNUMBER == type.intValue )
            {
                value = [value asNSNumber];
            }
            else if ( VK_DBRuntime_PropertyType_NSSTRING == type.intValue )
            {
                value = [value asNSString];
            }
            else if ( VK_DBRuntime_PropertyType_NSDATE == type.intValue )
            {
                value = [value asNSDate];
            }
            else if ( VK_DBRuntime_PropertyType_NSARRAY == type.intValue )
            {
             
                NSMutableArray *	defaultValue = [NSMutableArray array];
                NSArray *			array = nil;
                
//                if ( [value isKindOfClass:[NSArray class]] )
//                {
////                    array = (NSArray *)value;
//                    //数组入库的时候 统一打平为string
//                    NSParameterAssert(![value isKindOfClass:[NSArray class]]);
//                }
//                else
//                    数组入库的时候 统一打平为string
                if ( [value isKindOfClass:[NSString class]] )
                {
                    NSObject * obj = [NSJSONSerialization JSONObjectWithData:[(NSString *)value dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingMutableContainers error:nil];
                    
                    if ( [obj isKindOfClass:[NSArray class]] )
                    {
                        array = (NSArray *)obj;
                    }
                }
                
                if ( array && array.count )
                {
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        if ( class )
                        {
                            NSMutableArray * results = [NSMutableArray array];
                            
                            if ( [class isSubclassOfClass:[VKDBModel class]] )
                            {
//                                一次处理，创建并赋值uniqueKey 并不做二次处理 内链表数据
                                for ( NSObject * elem in array )
                                {
                                    NSObject * record = [[class alloc]init];
                                    NSString* uniqkey = [class uniqueKeyName];
                                    NSParameterAssert(uniqkey && uniqkey.length > 0);
                                    if ( record )
                                    {
                                        [record setValue:elem forKey:uniqkey];
                                        [results addObject:record];
                                    }
                                }
                            }
                            else
                            {
                                //array 内 如果有classname 说明是内嵌。。不允许非dbmodel  nssting number 不应该有classname
                                NSParameterAssert([class isSubclassOfClass:[VKDBModel class]]);
//                                for ( NSObject * elem in array )
//                                {
//                                    if ( [elem isKindOfClass:[NSDictionary class]] )
//                                    {
////                                        crash 数组内不许内嵌字典
//                                        NSParameterAssert(![elem isKindOfClass:[NSDictionary class]]);
////                                        NSObject * newObj = [class objectFromDictionary:elem];	// convert dictionary to NSObject
////                                        if ( newObj )
////                                        {
////                                            [results addObject:newObj];
////                                        }
//                                    }
//                                    else if ( [elem isKindOfClass:[NSString class]] )
//                                    {
////                                        NSObject * newObj = [class objectFromString:elem];		// convert dictionary to NSObject
////                                        if ( newObj )
////                                        {
//                                            [results addObject:elem];
////                                        }
//                                    }
//                                }
                            }
                            
                            value = results;
                        }
                        else
                        {
                            value = defaultValue;
                        }
                    }
                    else
                    {
                        value = [array asNSMutableArray];
                    }
                }
                else
                {
                    value = defaultValue;
                };
              
            }
            else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type.intValue )
            {
                //错误 禁止出现字典  强制crash
                NSParameterAssert(VK_DBRuntime_PropertyType_NSDICTIONARY != type.intValue);
                /*
                if ( [value isKindOfClass:[NSString class]] )
                {
                    value = [(NSString *)value objectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:nil];
                    if ( NO == [value isKindOfClass:[NSDictionary class]] )
                    {
                        value = [NSMutableDictionary dictionary];
                    }
                }
                else
                {
                    value = [value asNSMutableDictionary];	
                }*/
                value = nil;
            }
            else if ( VK_DBRuntime_PropertyType_NSOBJECT== type.intValue )
            {
                // set inner AR objects
                
                NSString * className = [property objectForKey:@"className"];
                if ( className )
                {
                    Class class = NSClassFromString( className );
                    if ( class )
                    {
                        if ( [class isSubclassOfClass:[VKDBModel class]] )
                        {
//                          一次处理，创建并赋值uniqueKey 并不做二次处理 内链表数据
                            NSObject * record = [[class alloc]init];
                            NSString* uniqkey = [class uniqueKeyName];
                            NSParameterAssert(uniqkey && uniqkey.length > 0);
                            if ( record )
                            {
                                [record setValue:value forKey:uniqkey];
                            }

                        }
                        else
                        {
                            //强制crash assert
                            NSParameterAssert([class isSubclassOfClass:[VKDBModel class]]);
                        }
                    }
                    else
                    {
                        value = nil;
                    }
                }
                else
                {
                    value = nil;
                }
                value = nil;
            }
            else
            {
                //				value = [value asNSNumber];
            }
        }
        else
        {
            // TODO: impossible
        }
        
        if ( name && value )
        {
            [self setValue:value forKey:name];
        }
    }
    
    // reset flags
    
//    _changed = YES;
//    _deleted = NO;
}



+ (NSString *)primaryKeyName
{
    return @"dataBaseId";
}

-(NSNumber *)primaryValue
{
    NSString * key = self.dataBasePrimaryKey;
    if ( key )
    {
        return [self valueForKey:key];
    }
    
    return nil;
}

+ (NSString*)uniqueKeyName
{
    return nil;
}

+(void)mapProperties
{
    [self mapRelation];
    [self useAutoIncrement];
}

+(void)mapProperty:(NSString *)name AsArrayforClass:(NSString *)className
{
    [self mapPropertyAsArray:name forClass:className];
}

+(BOOL)isPropertiesMaped
{
    return [self isRelationMapped];
}

+(BOOL)buildTable
{
    if ( nil == _vk_createTable )
    {
        _vk_createTable = [[NSMutableDictionary alloc] init];
    }
    
    NSString * className = [self description];
    
    NSNumber * builtFlag = [_vk_createTable objectForKey:className];
    if ( builtFlag && builtFlag.boolValue )
        return YES;
    
    [self mapProperties];
    
    // Step2, create table
    
    VK_SqlGenerator.TABLE( self.tableName );
    
    VK_SqlGenerator.FIELD( self.dataBasePrimaryKey, @"INTEGER" ).UNIQUE().PRIMARY_KEY();
    
    if ( [self isAutoIncrement] )
    {
        VK_SqlGenerator.AUTO_INREMENT();
    }
    
    Class rootClass = [VKDBModel class];
    
    NSDictionary * propertySet = self.dataBasePropertySet;
    if ( propertySet && propertySet.count )
    {
        for ( Class clazzType = self; clazzType != rootClass; )
        {
            unsigned int		propertyCount = 0;
            objc_property_t *	properties = class_copyPropertyList( clazzType, &propertyCount );
            
            for ( NSUInteger i = 0; i < propertyCount; i++ )
            {
                const char *	name = property_getName(properties[i]);
                NSString *		propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                
                NSMutableDictionary * property = [propertySet objectForKey:propertyName];
                if ( property )
                {
                    const char *	attr = property_getAttributes(properties[i]);
                    NSUInteger		type = [VKDataBaseRuntime typeOf:attr];
                    
                    NSString *		field = [property objectForKey:@"field"];
                    NSObject *		value = [property objectForKey:@"value"];
                    
                    if ( VK_DBRuntime_PropertyType_NSNUMBER == type )
                    {
                        VK_SqlGenerator.FIELD( field, @"INTEGER" );
                    }
                    else if ( VK_DBRuntime_PropertyType_NSSTRING == type )
                    {
                        VK_SqlGenerator.FIELD( field, @"TEXT" );
                    }
                    else if ( VK_DBRuntime_PropertyType_NSDATE == type )
                    {
                        VK_SqlGenerator.FIELD( field, @"TEXT" );
                    }
                    else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type )
                    {
//                        字典类型放空 不建表 不入库
//                        VK_SqlGenerator.FIELD( field, @"TEXT" );			// save as JSON
                    }
                    else if ( VK_DBRuntime_PropertyType_NSARRAY == type )
                    {
                        VK_SqlGenerator.FIELD( field, @"TEXT" );			// save as "id,id,id" or JSON
                    }
                    else if ( VK_DBRuntime_PropertyType_NSOBJECT == type )
                    {
                        Class fieldClass = [VKDataBaseRuntime classOfAttribute:attr];
                        if ( [fieldClass isSubclassOfClass:rootClass] )
                        {
                            NSString* fieldClassUniqKey = [fieldClass uniqueKeyName];
                            //没有唯一key 内联会报错！
                            NSParameterAssert(fieldClassUniqKey);
                            const char * uniqkeyc = [fieldClassUniqKey UTF8String];
                            objc_property_t	uniqProperty = class_getProperty(fieldClass, uniqkeyc);
                            const char *    attr = property_getAttributes(uniqProperty);
                            NSUInteger		type = [VKDataBaseRuntime typeOf:attr];
                            if (type == VK_DBRuntime_PropertyType_NSSTRING) {
                                VK_SqlGenerator.FIELD( field, @"TEXT" );
                            }else if (type == VK_DBRuntime_PropertyType_NSNUMBER)
                            {
                                VK_SqlGenerator.FIELD( field, @"INTEGER" );
                            }
                        }
                        else
                        {
                            //非内嵌类型强制不许输入
                            NSParameterAssert([fieldClass isSubclassOfClass:rootClass]);
                            VK_SqlGenerator.FIELD( field, @"TEXT" );
                        }
                    }
                    else
                    {
                        VK_SqlGenerator.FIELD( field, @"INTEGER" );
                    }
                    
                    if ( [clazzType isAutoIncrementForProperty:field] )
                    {
                        VK_SqlGenerator.AUTO_INREMENT();
                    }
                    
                    if ( [clazzType isUniqueForProperty:field] )
                    {
                        VK_SqlGenerator.UNIQUE();
                    }
                    
                    if ( value && NO == [value isKindOfClass:[VKDBNonValue class]] )
                    {
                        VK_SqlGenerator.DEFAULT( value );
                    }
                    
                    [property setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
                }
            }
            
            free( properties );
            
            clazzType = class_getSuperclass( clazzType );
            if ( nil == clazzType )
                break;
        }
    }
    
    NSString* createIfNotExistSQL =  VK_SqlGenerator.CREATE_IF_NOT_EXISTS();
    
    BOOL success = [VKDBManager doUpdateSQL:createIfNotExistSQL];
    // Step3, do migration if needed
    if (!success) {
        return NO;
    }
    
    // Step4, create index
    
    NSString* indexSQL = VK_SqlGenerator.TABLE( self.tableName ).INDEX_ON( self.dataBasePrimaryKey, nil );
    
    [VKDBManager doUpdateSQL:indexSQL];
    
    [_vk_createTable setObject:[NSNumber numberWithBool:YES] forKey:className];
    
    return YES;
}


- (BOOL)isTableBuilt
{
    NSString * className = [[self class] description];
    
    NSNumber * builtFlag = [_vk_createTable objectForKey:className];
    if ( builtFlag && builtFlag.boolValue )
    {
        return YES;
    }
    
    return NO;
}

+(BOOL)clearTable
{
    NSString* clearSQL = VK_SqlGenerator.FROM(self.tableName).EMPTY();
    return [VKDBManager doUpdateSQL:clearSQL];
}

+(void)clearTableInBackground
{
    NSString* clearSQL = VK_SqlGenerator.FROM(self.tableName).EMPTY();
    
    [VKDBManager addUpdateTaskSQL:clearSQL];
  
}

+ (NSString *)tableName
{
    if ( [self respondsToSelector:@selector(mapTableName)] )
    {
        return [self performSelector:@selector(mapTableName)];
    }
    
    return [NSString stringWithFormat:@"table_%@", [self description]];
}

- (BOOL)exsitWithKey:(NSString*)keyname
{
    NSString* exsitSql = VK_SqlGenerator
    .FROM( [self class].tableName )
    .WHERE( keyname, [self valueForKey:keyname] )
    .LIMIT(1)
    .COUNT();
    
    NSArray* rs = [VKDBManager doQuerySql:exsitSql];
    
    id result = [rs firstObject];
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSNumber* num = [result objectForKey:@"numrows"];
        if ([num integerValue] == 0) {
            return  NO;
        }else
        {
            return YES;
        }
    }

    return NO;
}

-(BOOL)exsit
{
    NSString* keyname;
    if ([[self class]uniqueKeyName]) {
        keyname = [[self class]uniqueKeyName];
    }else
    {
        keyname = self.dataBasePrimaryKey;
        id value = [self valueForKey:keyname];
        if ([value isKindOfClass:[NSNumber class]]) {
            NSInteger databaseID = [value integerValue];
            if (databaseID <= 0) {
                return NO;
            }
        }
    }

    if (keyname) {
        return [self exsitWithKey:keyname];
    }else
    {
        return NO;
    }

}

-(BOOL)refresh
{
    NSString* keyname = [self findKeyName];
    if (keyname) {
        return [self refreshWithKey:keyname];
    }else
    {
        return NO;
    }
}

-(BOOL)refreshWithKey:(NSString*)keyname
{
    NSString* refreshSql = VK_SqlGenerator
    .FROM( [self class].tableName )
    .WHERE( keyname, [self valueForKey:keyname])
    .LIMIT( 1 )
    .GET();

    NSArray* rs = [VKDBManager doQuerySql:refreshSql];
    
    if (rs) {
        if (rs.count >0) {
            NSDictionary * dict = rs.firstObject;
            
            [self resetProperties];
            [self setPropertiesFrom:dict];
            return YES;
        }
    }
    return NO;
}

-(void)refreshInnerDBModel
{
    NSDictionary *	propertySet = self.dataBasePropertySet;
    
    // step 1, update inner AR objects
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary *	property = [propertySet objectForKey:key];
        NSNumber *		type = [property objectForKey:@"type"];
        NSString * className = [property objectForKey:@"className"];
        
        if (className) {
            if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
            {
                NSString *	name = [property objectForKey:@"name"];
                NSObject *	value = [self valueForKey:name];
                
                if ( value && [value isKindOfClass:[VKDBModel class]] )
                {
                    //#warning MODEL 嵌套 待开发 内嵌对象写入另外一个库的 SQL 生成
                    VKDBModel* record = (VKDBModel*)value;
                    [record refresh];
                }
            }else if (VK_DBRuntime_PropertyType_NSARRAY == type.intValue)
            {
                NSString *	name = [property objectForKey:@"name"];
                NSArray *	value = [self valueForKey:name];
                if (value && [value isKindOfClass:[NSArray class]]) {
                    for (NSObject* item in value) {
                        if (item && [item isKindOfClass:[VKDBManager class]]) {
                            VKDBModel* record = (VKDBModel*)item;
                            [record refresh];
                        }
                    }
                }
            }
        }
    }
}

-(NSString*)findKeyName
{
    NSString* keyname;
    
    if ([[self class]uniqueKeyName]) {
        keyname = [[self class]uniqueKeyName];
    }else
    {
        keyname = self.dataBasePrimaryKey;
    }
    
    if ( nil == keyname || keyname.length == 0 )
        return nil;
    
    id value = [self valueForKey:keyname];
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber* valuenum = (NSNumber*)value;
        if (valuenum.intValue < 0) {
            return nil;
        }
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString* valuestr = (NSString*) value;
        if (valuestr.length <= 0) {
            return nil;
        }
    }
    
    return keyname;
}

-(void)saveToDB//主线程
{
    if (_dbDeleted) {
        return;
    }
    
    if (_dbChanging) {
        return;
    }
    
    BOOL ret = [self exsit];
    NSArray* sqlarr;
    if ( NO == ret )
    {
        sqlarr = [self insertSql];
    }
    else
    {
        sqlarr = [self updateSql];
    }
    
    for (NSString* sql in sqlarr) {
        [VKDBManager doUpdateSQL:sql];
    }
    _dbChanging = NO;
}

-(NSArray*)saveSqlGeneration
{
    BOOL ret = [self exsit];
    NSArray* sqlarr;
    if ( NO == ret )
    {
        sqlarr = [self insertSql];
    }
    else
    {
        sqlarr = [self updateSql];
    }
    return sqlarr;
}

-(void)saveInBackground
{
    if (_dbDeleted) {
        return;
    }
    if (_dbChanging) {
        return;
    }
    
    BOOL ret = [self exsit];
    NSArray* sqlarr;
    if ( NO == ret )
    {
        sqlarr = [self insertSql];
    }
    else
    {
        sqlarr = [self updateSql];
    }
    
    for (NSString* sql in sqlarr) {
        [VKDBManager addUpdateTaskSQL:sql];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveInBackgroundSuccessHandle) name:VK_DataBaseNotificationBackGroundTaskSuccess object:nil];
    
    _dbChanging = YES;
}

-(void)saveInBackgroundSuccessHandle
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VK_DataBaseNotificationBackGroundTaskSuccess object:nil];
    _dbChanging = NO;
}


- (NSArray*)insertSql
{
    if ( _dbDeleted )
        return nil;
    
    NSMutableArray* sqlarr = [[NSMutableArray alloc]init];
    // if already inserted into table, no nessecery insert again
    
    NSString *		primaryKey = self.dataBasePrimaryKey;
    //	NSNumber *		primaryID = [self valueForKey:primaryKey];
    //
    //	if ( primaryID && primaryID.intValue >= 0 )
    //		return NO;
    
    
//    NSString *		JSONKey = self.activeJSONKey;
    NSDictionary *	propertySet = self.dataBasePropertySet;
    
    // step 1, save inner AR objects
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary *	property = [propertySet objectForKey:key];
        NSNumber *		type = [property objectForKey:@"type"];
        
        if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
        {
            NSString *	name = [property objectForKey:@"name"];
            NSObject *	value = [self valueForKey:name];
            
            if ( value && [value isKindOfClass:[VKDBModel class]] )
            {
//#warning MODEL 嵌套 待开发 内嵌对象写入另外一个库的 SQL 生成
                VKDBModel* record = (VKDBModel*)value;
                NSArray* innerSql = [record exsit] ? [record updateSql] : [record insertSql];
                [sqlarr addObjectsFromArray:innerSql];
            }
        }
    }
    
    // step 2, save this object
    
    VK_SqlGenerator.FROM( [[self class] tableName] );
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        
        NSString * name = [property objectForKey:@"name"];
        NSNumber * type = [property objectForKey:@"type"];
        
        NSString * byClass = [property objectForKey:@"byClass"];
        if ( byClass )
        {
            Class byClassType = NSClassFromString( byClass );
            if ( byClassType && [VKDBModel isAutoIncrementFor:byClassType andProperty:name] )
            {
                continue;
            }
        }
        
//        if ( [name isEqualToString:JSONKey] )
//            continue;
        
        NSObject * value = [self valueForKey:name];
        if ( value )
        {
            if ( VK_DBRuntime_PropertyType_NSNUMBER == type.intValue )
            {
                value = [value asNSNumber];
                
                // bug fix
                if ( [name isEqualToString:primaryKey] && [(NSNumber *)value integerValue] < 0 )
                {
                    continue;
                }
            }
            else if ( VK_DBRuntime_PropertyType_NSSTRING == type.intValue )
            {
                value = [value asNSString];
            }
            else if ( VK_DBRuntime_PropertyType_NSDATE == type.intValue )
            {
                value = [[value asNSDate] description];
            }
            else if ( VK_DBRuntime_PropertyType_NSARRAY == type.intValue )
            {
                NSString *	defaultValue = @"[]";
                NSArray *	array = nil;
                
                if ( [value isKindOfClass:[NSArray class]] )
                {
                    array = (NSArray *)value;
                }
//                else if ( [value isKindOfClass:[NSString class]] )
//                {
//                    NSObject * obj = [(NSString *)value objectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:nil];
//                    if ( [obj isKindOfClass:[NSArray class]] )
//                    {
//                        array = (NSArray *)obj;
//                    }
//                }
                
                if ( array && array.count )
                {
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        if ( class )
                        {
                            NSMutableArray * results = [NSMutableArray array];
                            
                            if ( [class isSubclassOfClass:[VKDBModel class]] )
                            {
                                for ( NSObject * elem in array )
                                {
                                    if ( NO == [elem isKindOfClass:[VKDBModel class]] )
                                        continue;
                                    
                                    //内嵌开发 相关其他数据 入库其他表
                                    VKDBModel* record = (VKDBModel*)elem;
                                    NSArray* innerSql = [record exsit] ? [record updateSql] : [record insertSql];
                                    [sqlarr addObjectsFromArray:innerSql];
                                    
                                    //组建本表内 数据字符  类型string
                                    NSString* uniqkey = [class uniqueKeyName];
                                    [results addObject:[record valueForKey:uniqkey]];
                                }
                            }
                            else //nsarray 嵌套 数 string 等
                            {
                                //有classname 的话 必须 本array 为dbmodel 不可为其他 crash
                                NSParameterAssert([class isSubclassOfClass:[VKDBModel class]]);
//                                for ( NSObject * elem in array )
//                                {
//                                    [results addObject:elem];
//                                }
                            }
                            NSError *error = nil;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:&error];
                            
                            NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            value = trimmedString;
                        }
                        else //没找到内嵌class
                        {
                            value = defaultValue;
                        }
                    }
                    else//没有 classname 内嵌属性 说明可能是nsstring  nsnumber
                    {
                        //非nsstring number crash
                        for (NSObject* item in array) {
                            NSParameterAssert([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]);
                        }
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
                        
                        NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        value = trimmedString;
                    }
                }
                else//array 空数据
                {
                    value = defaultValue;
                }
            }
            else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type.intValue )
            {
                NSParameterAssert(VK_DBRuntime_PropertyType_NSDICTIONARY != type.intValue );
//                NSError *error = nil;
//                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error];
//                
//                NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                value = trimmedString;
            }
            else if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
            {
                if ( [value isKindOfClass:[VKDBModel class]] )
                {
                    //内链表已经在上面 写入了 此处只需写入本表 本field
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        NSString* unikey = [class uniqueKeyName];
                        value = [value valueForKey:unikey];//把对象变 uniq key 值

                    }else
                    {
                        value = nil;
                    }
                }
                else
                {
                    NSParameterAssert(VK_DBRuntime_PropertyType_NSOBJECT != type.intValue);
                }
            }
            else
            {
                //				value = [value asNSNumber];
            }
            
            if ( name && value )
            {
                if ( [name isEqualToString:primaryKey] )
                {
                    VK_SqlGenerator.SET( name, value );
                }
                else
                {
                    VK_SqlGenerator.SET( [VKDataBaseRuntime fieldNameForIdentifier:name], value );
                }
            }
        }
    }
    
//#if __JSON_SERIALIZATION__
//    
//    if ( [[self class] usingJSON] )
//    {
//        super.DB.SET( JSONKey, self.JSONString );
//    }
//    
//#endif	// #if __JSON_SERIALIZATION__
    
    NSString* insertSql = VK_SqlGenerator.INSERT();
    if (insertSql == nil) {
        return nil;
    }
    [sqlarr addObject:insertSql];
    return sqlarr;
    
//    BOOL succeed = super.DB.succeed;
//    if ( succeed )
//    {
//        _changed = NO;
//        
//        if ( primaryKey )
//        {
//            [self setValue:[NSNumber numberWithInteger:super.DB.insertID] forKey:primaryKey];
//        }
//    }
//    
//    [BeeDatabase scopeLeave];
//    
//    return succeed;
}

- (NSArray*)updateSql
{
    if ( _dbDeleted)
        return nil;
    
    NSMutableArray* sqlarr = [[NSMutableArray alloc]init];
    
    // if already inserted into table, no nessecery insert again
    
    NSString *		primaryKey = self.dataBasePrimaryKey;
    
    NSString * keyname = [self findKeyName];
    if ( nil == keyname )
        return nil;
    
    id  keyvalue = [self valueForKey:keyname];
//    if ( primaryID && primaryID.intValue < 0 )
//        return NO;
    
    
//    NSString *		JSONKey = self.activeJSONKey;
    NSDictionary *	propertySet = self.dataBasePropertySet;
    
    // step 1, update inner AR objects
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary *	property = [propertySet objectForKey:key];
        NSNumber *		type = [property objectForKey:@"type"];
        
        if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
        {
            NSString *	name = [property objectForKey:@"name"];
            NSObject *	value = [self valueForKey:name];
            
            if ( value && [value isKindOfClass:[VKDBModel class]] )
            {
                //#warning MODEL 嵌套 待开发 内嵌对象写入另外一个库的 SQL 生成
                VKDBModel* record = (VKDBModel*)value;
                NSArray* innerSql = [record exsit] ? [record updateSql] : [record insertSql];
                [sqlarr addObjectsFromArray:innerSql];
            }
        }
    }
    
    // step 2, update this object
    
    VK_SqlGenerator
    .FROM( [[self class]tableName] )
    .WHERE( keyname, keyvalue );
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        
        NSString * name = [property objectForKey:@"name"];
        NSNumber * type = [property objectForKey:@"type"];
        
        if ( [name isEqualToString:primaryKey] || [name isEqualToString:keyname] )
            continue;
        
        NSObject * value = [self valueForKey:name];
        if ( value )
        {
            if ( VK_DBRuntime_PropertyType_NSNUMBER == type.intValue )
            {
                value = [value asNSNumber];
            }
            else if ( VK_DBRuntime_PropertyType_NSSTRING == type.intValue )
            {
                value = [value asNSString];
            }
            else if ( VK_DBRuntime_PropertyType_NSDATE == type.intValue )
            {
                value = [[value asNSDate] description];
            }
            else if ( VK_DBRuntime_PropertyType_NSARRAY == type.intValue )
            {
                NSString *	defaultValue = @"[]";
                NSArray *	array = nil;
                
                if ( [value isKindOfClass:[NSArray class]] )
                {
                    array = (NSArray *)value;
                }
                //                else if ( [value isKindOfClass:[NSString class]] )
                //                {
                //                    NSObject * obj = [(NSString *)value objectFromJSONStringWithParseOptions:JKParseOptionValidFlags error:nil];
                //                    if ( [obj isKindOfClass:[NSArray class]] )
                //                    {
                //                        array = (NSArray *)obj;
                //                    }
                //                }
                
                if ( array && array.count )
                {
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        if ( class )
                        {
                            NSMutableArray * results = [NSMutableArray array];
                            
                            if ( [class isSubclassOfClass:[VKDBModel class]] )
                            {
                                for ( NSObject * elem in array )
                                {
                                    if ( NO == [elem isKindOfClass:[VKDBModel class]] )
                                        continue;
                                    
                                    //内嵌开发 相关其他数据 入库其他表
                                    VKDBModel* record = (VKDBModel*)elem;
                                    NSArray* innerSql = [record exsit] ? [record updateSql] : [record insertSql];
                                    [sqlarr addObjectsFromArray:innerSql];
                                    
                                    //组建本表内 数据字符  类型string
                                    NSString* uniqkey = [class uniqueKeyName];
                                    [results addObject:[record valueForKey:uniqkey]];
                                }
                            }
                            else //nsarray 嵌套 数 string 等
                            {
                                //有classname 的话 必须 本array 为dbmodel 不可为其他 crash
                                NSParameterAssert([class isSubclassOfClass:[VKDBModel class]]);
                                //                                for ( NSObject * elem in array )
                                //                                {
                                //                                    [results addObject:elem];
                                //                                }
                            }
                            NSError *error = nil;
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:&error];
                            
                            NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            value = trimmedString;
                        }
                        else //没找到内嵌class
                        {
                            value = defaultValue;
                        }
                    }
                    else//没有 classname 内嵌属性 说明可能是nsstring  nsnumber
                    {
                        //非nsstring number crash
                        for (NSObject* item in array) {
                            NSParameterAssert([item isKindOfClass:[NSString class]] || [item isKindOfClass:[NSNumber class]]);
                        }
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
                        
                        NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        value = trimmedString;
                    }
                }
                else//array 空数据
                {
                    value = defaultValue;
                }
            }
            else if ( VK_DBRuntime_PropertyType_NSDICTIONARY == type.intValue )
            {
                NSParameterAssert(VK_DBRuntime_PropertyType_NSDICTIONARY != type.intValue );
//
//                NSError *error = nil;
//                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&error];
//                
//                NSString *trimmedString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                value = trimmedString;
            }
            else if ( VK_DBRuntime_PropertyType_NSOBJECT == type.intValue )
            {
                if ( [value isKindOfClass:[VKDBModel class]] )
                {
                    //内链表已经在上面 写入了 此处只需写入本表 本field
                    NSString * className = [property objectForKey:@"className"];
                    if ( className )
                    {
                        Class class = NSClassFromString( className );
                        NSString* unikey = [class uniqueKeyName];
                        value = [value valueForKey:unikey];//把对象变 uniq key 值
                        
                    }else
                    {
                        value = nil;
                    }
                }
                else
                {
                    NSParameterAssert(VK_DBRuntime_PropertyType_NSOBJECT != type.intValue);
                }

            }
            else
            {
                //				value = [value asNSNumber];
            }
            
            if ( name && value )
            {
                if ( [name isEqualToString:primaryKey] )
                {
                    VK_SqlGenerator.SET( name, value );
                }
                else
                {
                    VK_SqlGenerator.SET( [VKDataBaseRuntime fieldNameForIdentifier:name], value );
                }
            }

        }
    }
    
//#if __JSON_SERIALIZATION__
//    
//    if ( [[self class] usingJSON] )
//    {
//        super.DB.SET( JSONKey, self.JSONString );
//    }
//    
//#endif	// #if __JSON_SERIALIZATION__
    
    NSString* updatesql = VK_SqlGenerator.UPDATE();
    
    if (updatesql == nil) {
        return nil;
    }
    
    [sqlarr addObject:updatesql];
    
    return sqlarr;
}

-(void)deleteFromDB
{
    NSString* deletesql = [self deleteDB];
    [VKDBManager doUpdateSQL:deletesql];
    [self deleteSelf];
}

-(void)deleteInBackground
{
    if (_dbChanging) {
        return;
    }
    
    if (_dbDeleted) {
        return;
    }
    NSString* deletesql = [self deleteDB];
    [VKDBManager addUpdateTaskSQL:deletesql];
    _dbDeleted = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteInBackgroundSuccessHandle) name:VK_DataBaseNotificationBackGroundTaskSuccess object:nil];
}

-(void)deleteInBackgroundSuccessHandle
{
    [self deleteSelf];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VK_DataBaseNotificationBackGroundTaskSuccess object:nil];
}

- (NSString*)deleteDB
{
    if ( _dbDeleted )
        return nil;
    
    NSString * keyname = [self findKeyName];
    if ( nil == keyname )
        return nil;
    
    id  keyvalue = [self valueForKey:keyname];
    
    NSString* deleteSql = VK_SqlGenerator
    .FROM( [self class].tableName )
    .WHERE( keyname, keyvalue )
    .DELETE();
    
    return deleteSql;
}

-(void)deleteSelf
{
    NSDictionary *	propertySet = self.dataBasePropertySet;
    
    NSString *		primaryKey = self.dataBasePrimaryKey;
    
    [self setValue:VK_DBRuntime_PropertyType_INVALID_ID forKey:primaryKey];
    
    for ( NSString * key in propertySet.allKeys )
    {
        NSDictionary * property = [propertySet objectForKey:key];
        
        NSString * name = [property objectForKey:@"name"];
        
        NSObject * value = [property objectForKey:@"value"];
        
        if ( value && NO == [value isKindOfClass:[VKDBNonValue class]] )
        {
            [self setValue:value forKey:name];
        }
        else
        {
            [self setValue:nil forKey:name];
        }
    }
        
    _dbChanging = NO;
    _dbDeleted = YES;

}

+(NSArray *)allObjectData
{
    NSString* getAllSql = [self allObjectDataQuerryStr];
    NSArray* rs = [VKDBManager doQuerySql:getAllSql];
    return rs;
}

+(void)allObjectDataQuerryInBackground
{
    NSString* getAllSql = [self allObjectDataQuerryStr];
    [VKDBManager addQueryTaskSQL:getAllSql];
}

+(NSString*)allObjectDataQuerryStr
{
    NSString* getAllSql = VK_SqlGenerator.FROM([self class].tableName).GET();
    return getAllSql;
}

+(NSArray *)objectDataWhereKeyName:(NSString *)key Opertor:(NSString *)opera Value:(NSString *)value
{
    NSString* getSql = [self objectDataQuerryStrWhereKeyName:key Opertor:opera Value:value];
    NSArray* rs = [VKDBManager doQuerySql:getSql];
    return rs;
    
}

+(void)objectDataQuerryInBackgroundWhereKeyName:(NSString *)key Opertor:(NSString *)opera Value:(NSString *)value
{
    NSString* getsql = [self objectDataQuerryStrWhereKeyName:key Opertor:opera Value:value];
    [VKDBManager addQueryTaskSQL:getsql];
}

+(NSString*)objectDataQuerryStrWhereKeyName:(NSString *)key Opertor:(NSString *)opera Value:(NSString *)value
{
    NSString* getSql = VK_SqlGenerator.FROM([self class].tableName).WHERE_OPERATOR(key,opera,value).GET();
    return getSql;
}

@end
