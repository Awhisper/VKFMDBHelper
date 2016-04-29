//
//  VKSqlGenerator.m
//
//  Created by awhisper on 15/2/10.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import "VKSqlGenerator.h"
#import "VKDataBaseRuntime.h"

@interface NSArray (dataBase)

- (id)safeObjectAtIndex:(NSInteger)index;

@end

@implementation NSArray (dataBase)

- (id)safeObjectAtIndex:(NSInteger)index
{
    if ( index < 0 )
        return nil;
    
    if ( index >= self.count )
        return nil;
    
    return [self objectAtIndex:index];
}

@end

@interface VKSqlGenerator ()
{
    NSMutableArray *		_select;
    BOOL					_distinct;
    NSMutableArray *		_from;
    NSMutableArray *		_where;
    NSMutableArray *		_like;
    NSMutableArray *		_groupby;
    NSMutableArray *		_having;
    NSMutableArray *		_keys;
    NSUInteger				_limit;
    NSUInteger				_offset;
    NSMutableArray *		_orderby;
    NSMutableDictionary *	_set;
    
    
    NSMutableArray *		_table;
    NSMutableArray *		_field;
    NSMutableArray *		_index;
    
    NSMutableArray *		_classType;
    NSMutableArray *		_associate;
    NSMutableArray *		_has;
}

- (void)initSelf;
- (NSString *)internalCreateAliasFromTable:(NSString *)name;
- (void)internalGroupBy:(NSString *)by;
- (void)internalSelect:(NSString *)select alias:(NSString *)alias type:(NSString *)type;
- (void)internalWhere:(NSString *)key expr:(NSString *)expr value:(NSObject *)value type:(NSString *)type;
- (void)internalLike:(NSString *)field match:(NSObject *)match type:(NSString *)type side:(NSString *)side invert:(BOOL)invert;
- (void)internalHaving:(NSString *)key value:(NSObject *)value type:(NSString *)type;
- (void)internalOrderBy:(NSString *)by direction:(NSString *)direction;

- (NSString *)internalCompileInsert:(NSString *)table values:(NSMutableArray *)values;
- (NSString *)internalCompileUpdate:(NSString *)table values:(NSMutableArray *)values;
- (NSString *)internalCompileSelect:(NSString *)override;
- (NSString *)internalCompileCreate:(NSString *)table;
- (NSString *)internalCompileDelete:(NSString *)table;
- (NSString *)internalCompileEmpty:(NSString *)table;
- (NSString *)internalCompileTrunc:(NSString *)table;
- (NSString *)internalCompileIndex:(NSString *)table;
- (NSString *)internalCompileExist:(NSString *)table as:(NSString *)value;

// create

- (VKSqlGenerator *)table:(NSString *)name;
- (VKSqlGenerator *)field:(NSString *)name type:(NSString *)type size:(NSUInteger)size;
- (VKSqlGenerator *)unsignedType;
- (VKSqlGenerator *)notNull;
- (VKSqlGenerator *)primaryKey;
- (VKSqlGenerator *)autoIncrement;
- (VKSqlGenerator *)defaultZero;
- (VKSqlGenerator *)defaultNull;
- (VKSqlGenerator *)defaultValue:(id)value;
- (VKSqlGenerator *)unique;
- (NSString*)createTableIfNotExists;
- (NSString*)createTableIfNotExists:(NSString *)table;
- (NSString*)indexTable:(NSString *)table on:(NSArray *)fields;
- (NSString*)existsTable:(NSString *)table;

// select

- (VKSqlGenerator *)select:(NSString *)select;
- (VKSqlGenerator *)selectMax:(NSString *)select;
- (VKSqlGenerator *)selectMax:(NSString *)select alias:(NSString *)alias;
- (VKSqlGenerator *)selectMin:(NSString *)select;
- (VKSqlGenerator *)selectMin:(NSString *)select alias:(NSString *)alias;
- (VKSqlGenerator *)selectAvg:(NSString *)select;
- (VKSqlGenerator *)selectAvg:(NSString *)select alias:(NSString *)alias;
- (VKSqlGenerator *)selectSum:(NSString *)select;
- (VKSqlGenerator *)selectSum:(NSString *)select alias:(NSString *)alias;

- (VKSqlGenerator *)distinct:(BOOL)flag;
- (VKSqlGenerator *)from:(NSString *)from;

- (VKSqlGenerator *)where:(NSString *)key value:(id)value;
- (VKSqlGenerator *)orWhere:(NSString *)key value:(id)value;
- (VKSqlGenerator *)where:(NSString *)key expr:(NSString *)expr value:(id)value;
- (VKSqlGenerator *)orWhere:(NSString *)key expr:(NSString *)expr value:(id)value;

- (VKSqlGenerator *)whereIn:(NSString *)key values:(NSArray *)values;
- (VKSqlGenerator *)orWhereIn:(NSString *)key values:(NSArray *)values;
- (VKSqlGenerator *)whereNotIn:(NSString *)key values:(NSArray *)values;
- (VKSqlGenerator *)orWhereNotIn:(NSString *)key values:(NSArray *)values;

- (VKSqlGenerator *)like:(NSString *)field match:(id)value;
- (VKSqlGenerator *)notLike:(NSString *)field match:(id)value;
- (VKSqlGenerator *)orLike:(NSString *)field match:(id)value;
- (VKSqlGenerator *)orNotLike:(NSString *)field match:(id)value;

- (VKSqlGenerator *)groupBy:(NSString *)by;

- (VKSqlGenerator *)having:(NSString *)key value:(id)value;
- (VKSqlGenerator *)orHaving:(NSString *)key value:(id)value;

- (VKSqlGenerator *)orderAscendBy:(NSString *)by;
- (VKSqlGenerator *)orderDescendBy:(NSString *)by;
- (VKSqlGenerator *)orderRandomBy:(NSString *)by;
- (VKSqlGenerator *)orderBy:(NSString *)by direction:(NSString *)direction;

- (VKSqlGenerator *)limit:(NSUInteger)limit;
- (VKSqlGenerator *)offset:(NSUInteger)offset;

- (VKSqlGenerator *)classInfo:(id)obj;

// write

- (VKSqlGenerator *)set:(NSString *)key;
- (VKSqlGenerator *)set:(NSString *)key value:(id)value;

- (NSString *)get;
- (NSString *)get:(NSString *)table;
- (NSString *)get:(NSString *)table limit:(NSUInteger)limit;
- (NSString *)get:(NSString *)table limit:(NSUInteger)limit offset:(NSUInteger)offset;

- (NSString*)count;
- (NSString*)count:(NSString *)table;

- (NSString*)insert;
- (NSString*)insert:(NSString *)table;

- (NSString*)update;
- (NSString*)update:(NSString *)table;

- (NSString*)empty;
- (NSString*)empty:(NSString *)table;

- (NSString*)truncate;
- (NSString*)truncate:(NSString *)table;

- (NSString*)delete;
- (NSString*)delete:(NSString *)table;

// active record

//- (void)classType:(Class)clazz;
//- (void)associate:(NSObject *)obj;
//- (void)has:(NSObject *)obj;

//- (void)executeWriteOperations;
//- (void)executeWriteOperation;

@end

@implementation VKSqlGenerator


@dynamic TABLE;
@dynamic FIELD;
@dynamic FIELD_WITH_SIZE;
@dynamic UNSIGNED;
@dynamic NOT_NULL;
@dynamic PRIMARY_KEY;
@dynamic AUTO_INREMENT;
@dynamic DEFAULT_ZERO;
@dynamic DEFAULT_NULL;
@dynamic DEFAULT;
@dynamic UNIQUE;
@dynamic CREATE_IF_NOT_EXISTS;
@dynamic INDEX_ON;

@dynamic SELECT;
@dynamic SELECT_MAX;
@dynamic SELECT_MAX_ALIAS;
@dynamic SELECT_MIN;
@dynamic SELECT_MIN_ALIAS;
@dynamic SELECT_AVG;
@dynamic SELECT_AVG_ALIAS;
@dynamic SELECT_SUM;
@dynamic SELECT_SUM_ALIAS;

@dynamic DISTINCT;
@dynamic FROM;

@dynamic WHERE;
@dynamic OR_WHERE;

@dynamic WHERE_OPERATOR;
@dynamic OR_WHERE_OPERATOR;

@dynamic WHERE_IN;
@dynamic OR_WHERE_IN;
@dynamic WHERE_NOT_IN;
@dynamic OR_WHERE_NOT_IN;

@dynamic LIKE;
@dynamic NOT_LIKE;
@dynamic OR_LIKE;
@dynamic OR_NOT_LIKE;

@dynamic GROUP_BY;

@dynamic HAVING;
@dynamic OR_HAVING;

@dynamic ORDER_ASC_BY;
@dynamic ORDER_DESC_BY;
@dynamic ORDER_RAND_BY;
@dynamic ORDER_BY;

@dynamic LIMIT;
@dynamic OFFSET;

@dynamic SET;
@dynamic SET_NULL;

@dynamic GET;
@dynamic COUNT;

@dynamic INSERT;
@dynamic UPDATE;
@dynamic EMPTY;
@dynamic TRUNCATE;
@dynamic DELETE;


- (instancetype)sharedInstance {
    return [[self class] defaultSqlGenerator];
}

static id __singleton__;
+ (instancetype)defaultSqlGenerator {
    static dispatch_once_t once;
    dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } );
    return __singleton__;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initSelf];
    }
    return self;
}



- (void)initSelf
{
    _select = [[NSMutableArray alloc] init];
    _distinct = NO;
    _from = [[NSMutableArray alloc] init];
    _where = [[NSMutableArray alloc] init];
    _like = [[NSMutableArray alloc] init];
    _groupby = [[NSMutableArray alloc] init];
    _having = [[NSMutableArray alloc] init];
    _keys = [[NSMutableArray alloc] init];
    _limit = 0;
    _offset = 0;
    _orderby = [[NSMutableArray alloc] init];
    _set = [[NSMutableDictionary alloc] init];
    
//    _classType = [NSMutableArray alloc] init];
//    
//    _associate = [NSMutableArray nonRetainingArray] retain];
//    _has = [NSMutableArray nonRetainingArray] retain];
    
    _table = [[NSMutableArray alloc] init];
    _field = [[NSMutableArray alloc] init];
    _index = [[NSMutableArray alloc] init];
    
//    _writeQueue = [NSMutableArray alloc] init];
//    _resultArray = [NSMutableArray alloc] init];
//    _resultCount = 0;
//    
//    _identifier = __identSeed++;
//    
//    _condition = [NSCondition alloc] init];
//    [_condition setName:[NSString stringWithFormat:@"db-%d", _identifier]];
//    
//    _lastQuery = [NSDate timeIntervalSinceReferenceDate];
//    _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
}



#pragma mark - clearstate

- (void)clearState
{
    [self __internalResetCreate];
    [self __internalResetWrite];
    [self __internalResetSelect];
}

- (void)__internalResetCreate
{
    [_field removeAllObjects];
    [_table removeAllObjects];
    [_index removeAllObjects];
    
//    if ( NO == _batch )
//    {
//        [_classType removeAllObjects];
//        [_associate removeAllObjects];
//        [_has removeAllObjects];
//    }
}

- (void)__internalResetSelect
{
    [_select removeAllObjects];
    [_from removeAllObjects];
    [_where removeAllObjects];
    [_like removeAllObjects];
    [_groupby removeAllObjects];
    [_having removeAllObjects];
    [_orderby removeAllObjects];
    
//    if ( NO == _batch )
//    {
//        [_classType removeAllObjects];
//        [_associate removeAllObjects];
//        [_has removeAllObjects];
//    }
    
    _distinct = NO;
    _limit = 0;
    _offset = 0;
}

- (void)__internalResetWrite
{
    [_set removeAllObjects];
    [_from removeAllObjects];
    [_where removeAllObjects];
    [_like removeAllObjects];
    [_orderby removeAllObjects];
    [_keys removeAllObjects];
    
//    if ( NO == _batch )
//    {
//        [_classType removeAllObjects];
//        [_associate removeAllObjects];
//        [_has removeAllObjects];
//    }
    
    _limit = 0;
}



#pragma mark - sql founction

- (VKSqlGenerator *)table:(NSString *)name
{
//    if ( nil == _database )
//        return self;
    
    if ( nil == name )
        return self;
    
    name = [VKDataBaseRuntime tableNameForIdentifier:name];
    
    for ( NSString * table in _table )
    {
        if ( NSOrderedSame == [table compare:name options:NSCaseInsensitiveSearch] )
            return self;
    }
    
    [_table addObject:name];
    return self;
}

- (VKSqlGenerator *)field:(NSString *)name type:(NSString *)type size:(NSUInteger)size
{
//    if ( nil == _database )
//        return self;
    
    BOOL found = NO;
    
    for ( NSMutableDictionary * dict in _field )
    {
        NSString * existName = [dict objectForKey:@"name"];
        if ( NSOrderedSame == [existName compare:name options:NSCaseInsensitiveSearch] )
        {
            if ( type )
            {
                [dict setObject:type forKey:@"type"];
            }
            
            if ( size )
            {
                [dict setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
            }
            
            found = YES;
            break;
        }
    }
    
    if ( NO == found )
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:name forKey:@"name"];
        [dict setObject:(type ? type : @"INT") forKey:@"type"];
        [dict setObject:[NSNumber numberWithUnsignedLongLong:size] forKey:@"size"];
        [_field addObject:dict];
    }
    
    return self;
}

- (VKSqlGenerator *)unsignedType
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:@1 forKey:@"unsigned"];
    return self;
}

- (VKSqlGenerator *)notNull
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:@1 forKey:@"notNull"];
    return self;
}

- (VKSqlGenerator *)primaryKey
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:@1 forKey:@"primaryKey"];
    return self;
}

- (VKSqlGenerator *)autoIncrement
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:@1 forKey:@"autoIncrement"];
    return self;
}

- (VKSqlGenerator *)defaultZero
{
    return [self defaultValue:@0];
}

- (VKSqlGenerator *)defaultNull
{
    return [self defaultValue:[NSNull null]];
}

- (VKSqlGenerator *)defaultValue:(id)value
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:value forKey:@"default"];
    return self;
}

- (VKSqlGenerator *)unique
{
//    if ( nil == _database )
//        return self;
    
    NSMutableDictionary * dict = (NSMutableDictionary *)_field.lastObject;
    if ( nil == dict )
        return self;
    
    [dict setObject:@1 forKey:@"unique"];
    return self;
}

#pragma mark -

- (NSString*)createTableIfNotExists
{
    return [self createTableIfNotExists:nil];
}

- (NSString*)createTableIfNotExists:(NSString *)table
{
//    [self __internalResetResult];
    
//    if ( nil == _database )
//        return NO;
    
    if ( nil == table )
    {
        if ( 0 == _table.count )
            return nil;
        
        table = (NSString *)_table.lastObject;
    }
    else
    {
        table = [VKDataBaseRuntime tableNameForIdentifier:table];
    }
    
    if ( nil == table || 0 == table.length )
        return nil;
    
    if ( 0 == _field.count )
        return nil;
    
    NSString * sql = [self internalCompileCreate:table];
    [self __internalResetCreate];
    
    return sql;
    
//    BOOL ret = [_database executeUpdate:sql];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//    }
    
//    return ret;
}

#pragma mark -

- (NSString*)indexTable:(NSString *)table on:(NSArray *)fields
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return NO;
    
    if ( nil == fields || 0 == fields.count )
        return nil;
    
    if ( nil == table )
    {
        if ( 0 == _table.count )
            return nil;
        
        table = (NSString *)_table.lastObject;
    }
    else
    {
        table = [VKDataBaseRuntime tableNameForIdentifier:table];
    }
    
    if ( nil == table || 0 == table.length )
        return nil;
    
    for ( NSString * field in fields )
    {
        [_index addObject:field];
    }
    
    if ( 0 == _index.count )
        return nil;
    
    NSString * sql = [self internalCompileIndex:table];
    [self __internalResetCreate];
    return sql;
    
//    BOOL ret = [_database executeUpdate:sql];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//    }
//    
//    return ret;
}

#pragma mark -

- (NSString*)existsTable:(NSString *)table
{
    if ( nil == table )
        return nil;
    
//    BOOL succeed = NO;
//    BOOL exists = NO;
    
    if ( nil == table )
    {
        if ( 0 == _table.count )
            return nil;
        
        table = (NSString *)_table.lastObject;
    }
    else
    {
        table = [VKDataBaseRuntime tableNameForIdentifier:table];
    }
    
    if ( nil == table || 0 == table.length )
        return nil;
    
    NSString * sql = [self internalCompileExist:table as:@"numrows"];
    return sql;
    
//    FMResultSet * result = [_database executeQuery:sql];
//    if ( result )
//    {
//        succeed = [result next];
//        if ( succeed )
//        {
//            NSDictionary * dict = nil;
//            
//            if ( [result respondsToSelector:@selector(resultDictionary)] )
//            {
//                dict = [result resultDictionary];
//            }
//            else if ( [result respondsToSelector:@selector(resultDict)] )
//            {
//                dict = [result performSelector:@selector(resultDict)];
//            }
//            
//            if ( dict )
//            {
//                NSNumber * numrows = [dict objectForKey:@"numrows"];
//                if ( numrows )
//                {
//                    exists = numrows.intValue ? YES : NO;
//                }
//            }
//        }
//        
//        if ( succeed )
//        {
//            _lastQuery = [NSDate timeIntervalSinceReferenceDate];
//        }
//    }
//    
//    return exists;
}

#pragma mark -

- (VKSqlGenerator *)select:(NSString *)select
{
//    if ( nil == _database )
//        return self;
    
    if ( nil == select )
        return self;
    
    [self internalSelect:select alias:nil type:nil];
    return self;
}

- (VKSqlGenerator *)selectMax:(NSString *)select
{
    return [self selectMax:select alias:nil];
}

- (VKSqlGenerator *)selectMax:(NSString *)select alias:(NSString *)alias
{
//    if ( nil == _database )
//        return self;
    
    [self internalSelect:select alias:alias type:@"MAX"];
    return self;
}

- (VKSqlGenerator *)selectMin:(NSString *)select
{
    return [self selectMin:select alias:nil];
}

- (VKSqlGenerator *)selectMin:(NSString *)select alias:(NSString *)alias
{
//    if ( nil == _database )
//        return self;
    
    [self internalSelect:select alias:alias type:@"MIN"];
    return self;
}

- (VKSqlGenerator *)selectAvg:(NSString *)select
{
    return [self selectAvg:select alias:nil];
}

- (VKSqlGenerator *)selectAvg:(NSString *)select alias:(NSString *)alias
{
//    if ( nil == _database )
//        return self;
    
    [self internalSelect:select alias:alias type:@"AVG"];
    return self;
}

- (VKSqlGenerator *)selectSum:(NSString *)select
{
    return [self selectSum:select alias:nil];
}

- (VKSqlGenerator *)selectSum:(NSString *)select alias:(NSString *)alias
{
//    if ( nil == _database )
//        return self;
    
    [self internalSelect:select alias:alias type:@"SUM"];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)distinct:(BOOL)flag
{
//    if ( nil == _database )
//        return self;
    
    _distinct = flag;
    return self;
}

#pragma mark -

- (VKSqlGenerator *)from:(NSString *)from
{
//    if ( nil == _database )
//        return self;
    
    if ( nil == from )
        return self;
    
    from = [VKDataBaseRuntime tableNameForIdentifier:from];
    
    for ( NSString * table in _from )
    {
        if ( NSOrderedSame == [table compare:from options:NSCaseInsensitiveSearch] )
            return self;
    }
    
    [_from addObject:from];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)where:(NSString *)key value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhere:key expr:@"=" value:value type:@"AND"];
    return self;
}

- (VKSqlGenerator *)orWhere:(NSString *)key value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhere:key expr:@"=" value:value type:@"OR"];
    return self;
}

- (VKSqlGenerator *)where:(NSString *)key expr:(NSString *)expr value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhere:key expr:expr value:value type:@"AND"];
    return self;
}

- (VKSqlGenerator *)orWhere:(NSString *)key expr:(NSString *)expr value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhere:key expr:expr value:value type:@"OR"];
    return self;
}

- (VKSqlGenerator *)whereIn:(NSString *)key values:(NSArray *)values
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhereIn:key values:values invert:NO type:@"AND"];
    return self;
}

- (VKSqlGenerator *)orWhereIn:(NSString *)key values:(NSArray *)values
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhereIn:key values:values invert:NO type:@"OR"];
    return self;
}

- (VKSqlGenerator *)whereNotIn:(NSString *)key values:(NSArray *)values
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhereIn:key values:values invert:YES type:@"AND"];
    return self;
}

- (VKSqlGenerator *)orWhereNotIn:(NSString *)key values:(NSArray *)values
{
//    if ( nil == _database )
//        return self;
    
    [self internalWhereIn:key values:values invert:YES type:@"OR"];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)like:(NSString *)field match:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalLike:field match:value type:@"AND" side:@"both" invert:NO];
    return self;
}

- (VKSqlGenerator *)notLike:(NSString *)field match:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalLike:field match:value type:@"AND" side:@"both" invert:YES];
    return self;
}

- (VKSqlGenerator *)orLike:(NSString *)field match:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalLike:field match:value type:@"OR" side:@"both" invert:NO];
    return self;
}

- (VKSqlGenerator *)orNotLike:(NSString *)field match:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalLike:field match:value type:@"OR" side:@"both" invert:YES];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)groupBy:(NSString *)by
{
//    if ( nil == _database )
//        return self;
    
    [self internalGroupBy:by];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)having:(NSString *)key value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalHaving:key value:value type:@"AND"];
    return self;
}

- (VKSqlGenerator *)orHaving:(NSString *)key value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    [self internalHaving:key value:value type:@"OR"];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)orderAscendBy:(NSString *)by
{
    return [self orderBy:by direction:@"ASC"];
}

- (VKSqlGenerator *)orderDescendBy:(NSString *)by
{
    return [self orderBy:by direction:@"DESC"];
}

- (VKSqlGenerator *)orderRandomBy:(NSString *)by
{
    return [self orderBy:by direction:@"RAND()"];
}

- (VKSqlGenerator *)orderBy:(NSString *)by direction:(NSString *)direction
{
//    if ( nil == _database )
//        return self;
    
    if ( nil == by )
        return self;
    
    [self internalOrderBy:by direction:direction];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)limit:(NSUInteger)limit
{
//    if ( nil == _database )
//        return self;
    
    _limit = limit;
    return self;
}

- (VKSqlGenerator *)offset:(NSUInteger)offset
{
//    if ( nil == _database )
//        return self;
    
    _offset = offset;
    return self;
}

- (VKSqlGenerator *)classInfo:(id)obj
{
//    if ( nil == obj )
//        return self;
    
    [_classType addObject:obj];
    return self;
}

#pragma mark -

- (VKSqlGenerator *)set:(NSString *)key
{
    return [self set:key value:nil];
}

- (VKSqlGenerator *)set:(NSString *)key value:(id)value
{
//    if ( nil == _database )
//        return self;
    
    if ( nil == key || nil == value )
        return self;
    
    [_set setObject:value forKey:key];
    return self;
}

#pragma mark -

- (NSString *)get
{
    return [self get:nil limit:0 offset:0];
}

- (NSString *)get:(NSString *)table
{
    return [self get:table limit:0 offset:0];
}

- (NSString *)get:(NSString *)table limit:(NSUInteger)limit
{
    return [self get:table limit:limit offset:0];
}

- (NSString *)get:(NSString *)table limit:(NSUInteger)limit offset:(NSUInteger)offset
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return nil;
    
    if ( table )
    {
        [self from:table];
    }
    
    if ( limit )
    {
        [self limit:limit];
    }
    
    if ( offset )
    {
        [self offset:offset];
    }
    
    NSString * sql = [self internalCompileSelect:nil];
    
    [self __internalResetSelect];
    
    return sql;
    
//    FMResultSet * result = [_database executeQuery:sql];
//    if ( result )
//    {
//        while ( [result next] )
//        {
//            NSDictionary * dict = nil;
//            
//            if ( [result respondsToSelector:@selector(resultDictionary)] )
//            {
//                dict = [result resultDictionary];
//            }
//            else if ( [result respondsToSelector:@selector(resultDict)] )
//            {
//                dict = [result performSelector:@selector(resultDict)];
//            }
//            
//            if ( dict )
//            {
//                [_resultArray addObject:dict];
//            }
//        }
//        
//        _resultCount = _resultArray.count;
//        
//        _lastQuery = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//    }
//    
//    return _resultArray;
}

#pragma mark -

- (NSString*)count
{
    return [self count:nil];
}

- (NSString*)count:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return 0;
    
    if ( table )
    {
        [self from:table];
    }
    
    NSString * sql = [self internalCompileSelect:@"SELECT COUNT(*) AS numrows"];
    [self __internalResetSelect];
    
    return sql;
    
//    BOOL succeed = NO;
//    
//    FMResultSet * result = [_database executeQuery:sql];
//    if ( result )
//    {
//        succeed = [result next];
//        if ( succeed )
//        {
//            _resultCount = (NSUInteger)[result unsignedLongLongIntForColumn:@"numrows"];
//            
//            _lastQuery = [NSDate timeIntervalSinceReferenceDate];
//            _lastSucceed = YES;
//        }
//    }
//    
//    return _resultCount;
}

#pragma mark -

- (NSString*)insert
{
    return [self insert:nil];
}

- (NSString*)insert:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return -1;
    
    if ( 0 == _set.count )
        return nil;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return nil;
        
        table = [_from objectAtIndex:0];
    }
    
    NSMutableArray * allValues = [NSMutableArray array];
    NSString * sql = [self internalCompileInsert:table values:allValues];
    
    [self __internalResetWrite];
    
    return sql;
//    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:allValues];
//    if ( ret )
//    {
//        _lastInsertID = (NSInteger)_database.lastInsertRowId;
//        
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//    }
//    
//    return _lastInsertID;
}

#pragma mark -

- (NSString*)update
{
    return [self update:nil];
}

- (NSString*)update:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return NO;
    
    if ( 0 == _set.count )
        return nil;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return nil;
        
        table = [_from objectAtIndex:0];
    }
    
    NSMutableArray * allValues = [NSMutableArray array];
    NSString * sql = [self internalCompileUpdate:table values:allValues];
    
    [self __internalResetWrite];
    
    return sql;
    
//    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:allValues];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//        
//        // TODO: ...
//    }
//    
//    return ret;
}

#pragma mark -

- (NSString*)empty
{
    return [self empty:nil];
}

- (NSString*)empty:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return NO;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return nil;
        
        table = [_from objectAtIndex:0];
    }
    else
    {
        table = [VKDataBaseRuntime tableNameForIdentifier:table];
    }
    
    NSString * sql = [self internalCompileEmpty:table];
    
    [self __internalResetWrite];
    
    return sql;
    
//    BOOL ret = [_database executeUpdate:sql];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//        
//        // TODO: ...
//    }
//    
//    return ret;
}

#pragma mark -

- (NSString*)delete
{
    return [self delete:nil];
}

- (NSString*)delete:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return NO;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return nil;
        
        table = [_from objectAtIndex:0];
    }
    
    if ( 0 == _where.count && 0 == _like.count )
        return nil;
    
    NSString * sql = [self internalCompileDelete:table];
    
    [self __internalResetWrite];
    
    return sql;
    
//    BOOL ret = [_database executeUpdate:sql];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//        
//        // TODO: ...
//    }
//    
//    return ret;
}

#pragma mark -

- (NSString*)truncate
{
    return [self truncate:nil];
}

- (NSString*)truncate:(NSString *)table
{
//    [self __internalResetResult];
//    
//    if ( nil == _database )
//        return NO;
    
    if ( nil == table )
    {
        if ( 0 == _from.count )
            return nil;
        
        table = [_from objectAtIndex:0];
    }
    else
    {
        table = [VKDataBaseRuntime tableNameForIdentifier:table];
    }
    
    NSString * sql = [self internalCompileTrunc:table];
    
    [self __internalResetWrite];
    
    return sql;
//    BOOL ret = [_database executeUpdate:sql];
//    if ( ret )
//    {
//        _lastUpdate = [NSDate timeIntervalSinceReferenceDate];
//        _lastSucceed = YES;
//        
//        // TODO: ...
//    }
//    
//    return ret;
}


- (void)internalGroupBy:(NSString *)by
{
    if ( nil == by )
        return;
    
    [_groupby addObject:by];
}

- (void)internalSelect:(NSString *)select alias:(NSString *)alias type:(NSString *)type
{
    if ( nil == select )
        return;
    
    NSArray * fieldNames = [select componentsSeparatedByString:@","];
    if ( fieldNames.count > 0 )
    {
        for ( NSString * field in fieldNames )
        {
            NSString* sfield = [VKDataBaseRuntime fieldNameForIdentifier:field];
            
            if ( sfield && sfield.length )
            {
                [_select addObject:sfield];
            }
        }
    }
    else
    {
        NSMutableString * sql = [NSMutableString string];
        
        if ( type && type.length )
        {
            [sql appendFormat:@"%@(%@)", type, [VKDataBaseRuntime fieldNameForIdentifier:select]];
        }
        else
        {
            [sql appendFormat:@"%@", [VKDataBaseRuntime fieldNameForIdentifier:select]];
        }
        
        if ( nil == alias || 0 == alias.length )
        {
            alias = [self internalCreateAliasFromTable:alias];
        }
        
        if ( alias )
        {
            alias = [VKDataBaseRuntime fieldNameForIdentifier:alias];
            [sql appendFormat:@" AS %@", alias];
        }
        
        [_select addObject:sql];
    }
}

- (NSString *)internalCreateAliasFromTable:(NSString *)name
{
    NSRange range = [name rangeOfString:@"."];
    if ( range.length )
    {
        NSArray * array = [name componentsSeparatedByString:@"."];
        if ( array && array.count )
        {
            return array.lastObject;
        }
    }
    
    return name;
}

- (void)internalWhere:(NSString *)key expr:(NSString *)expr value:(NSObject *)value type:(NSString *)type
{
    key = [VKDataBaseRuntime fieldNameForIdentifier:key];
    
    NSString *			prefix = (0 == _where.count) ? @"" : type;
    NSMutableString *	sql = [NSMutableString string];
    
    if ( nil == value || [value isKindOfClass:[NSNull class]] )
    {
        [sql appendFormat:@"%@ %@ IS NULL", prefix, key];
    }
    else
    {
        if ( [value isKindOfClass:[NSNumber class]] )
        {
            [sql appendFormat:@"%@ %@ %@ %@", prefix, key, expr, value];
        }
        else
        {
            [sql appendFormat:@"%@ %@ %@ '%@'", prefix, key, expr, value];
        }
    }
    
    [_where addObject:sql];
}

- (void)internalWhereIn:(NSString *)key values:(NSArray *)values invert:(BOOL)invert type:(NSString *)type
{
    if ( nil == key || nil == values || 0 == values.count )
        return;
    
    NSMutableString * sql = [NSMutableString string];
    
    if ( _where.count )
    {
        [sql appendFormat:@"%@ ", type];
    }
    
    key = [VKDataBaseRuntime fieldNameForIdentifier:key];
    [sql appendFormat:@"%@", key];
    
    if ( invert )
    {
        [sql appendString:@" NOT"];
    }
    
    [sql appendString:@" IN ("];
    
    for ( NSInteger i = 0; i < values.count; ++i )
    {
        NSObject * value = [values objectAtIndex:i];
        
        if ( i > 0 )
        {
            [sql appendFormat:@", "];
        }
        
        if ( [value isKindOfClass:[NSNumber class]] )
        {
            [sql appendFormat:@"%@", value];
        }
        else
        {
            [sql appendFormat:@"'%@'", value];
        }
    }
    
    [sql appendString:@")"];
    
    [_where addObject:sql];
}

- (void)internalLike:(NSString *)field match:(NSObject *)match type:(NSString *)type side:(NSString *)side invert:(BOOL)invert
{
    if ( nil == field || nil == match )
        return;
    
    NSString * value = nil;
    
    if ( [side isEqualToString:@"before"] )
    {
        value = [NSString stringWithFormat:@"%%%@", match];
    }
    else if ( [side isEqualToString:@"after"] )
    {
        value = [NSString stringWithFormat:@"%@%%", match];
    }
    else
    {
        value = [NSString stringWithFormat:@"%%%@%%", match];
    }
    
    NSMutableString * sql = [NSMutableString string];
    
    if ( _like.count )
    {
        [sql appendString:type];
    }
    
    field = [VKDataBaseRuntime fieldNameForIdentifier:field];
    [sql appendFormat:@" %@", field];
    
    if ( invert )
    {
        [sql appendString:@" NOT"];
    }
    
    [sql appendFormat:@" LIKE '%@'", value];
    
    [_like addObject:sql];
}

- (void)internalHaving:(NSString *)key value:(NSObject *)value type:(NSString *)type
{
    if ( nil == key || nil == value )
        return;
    
    [_having addObject:[NSArray arrayWithObjects:key, value, type, nil]];
}

- (void)internalOrderBy:(NSString *)by direction:(NSString *)direction
{
    if ( nil == by || nil == direction )
        return;
    
    [_orderby addObject:[NSArray arrayWithObjects:by, direction, nil]];
}

#pragma mark -

- (NSString *)internalCompileSelect:(NSString *)override
{
    NSMutableString * sql = [NSMutableString string];
    
    if ( override )
    {
        [sql appendString:override];
    }
    else
    {
        if ( _distinct )
        {
            [sql appendString:@"SELECT DISTINCT "];
        }
        else
        {
            [sql appendString:@"SELECT "];
        }
        
        if ( _select.count )
        {
            [_select sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString * left = (NSString *)obj1;
                NSString * right = (NSString *)obj2;
                return [left compare:right options:NSCaseInsensitiveSearch];
            }];
            
            for ( NSInteger i = 0; i < _select.count; ++i )
            {
                NSString * select = [_select objectAtIndex:i];
                
                if ( 0 == i )
                {
                    [sql appendFormat:@"%@", select];
                }
                else
                {
                    [sql appendFormat:@", %@", select];
                }
            }
        }
        else
        {
            [sql appendString:@"*"];
        }
    }
    
    if ( _from.count )
    {
        [sql appendString:@" FROM "];
        
        for ( NSInteger i = 0; i < _from.count; ++i )
        {
            NSString * from = [_from objectAtIndex:i];
            
            if ( 0 == i )
            {
                [sql appendString:from];
            }
            else
            {
                [sql appendFormat:@", %@", from];
            }
        }
    }
    
    if ( _where.count || _like.count )
    {
        [sql appendString:@" WHERE"];
    }
    
    if ( _where.count )
    {
        for ( NSString * where in _where )
        {
            [sql appendFormat:@" %@ ", where];
        }
    }
    
    if ( _like.count )
    {
        if ( _where.count )
        {
            [sql appendString:@" AND "];
        }
        
        for ( NSString * like in _like )
        {
            [sql appendFormat:@" %@ ", like];
        }
    }
    
    if ( _groupby.count )
    {
        [sql appendString:@" GROUP BY "];
        
        for ( NSInteger i = 0; i < _groupby.count; ++i )
        {
            NSString * by = [_groupby objectAtIndex:i];
            
            if ( 0 == i )
            {
                [sql appendFormat:@"%@", by];
            }
            else
            {
                [sql appendFormat:@", %@", by];
            }
        }
    }
    
    if ( _having.count )
    {
        [sql appendString:@" HAVING "];
        
        for ( NSInteger i = 0; i < _having.count; ++i )
        {
            NSArray *	array = [_orderby objectAtIndex:i];
            NSString *	key = [array safeObjectAtIndex:0];
            NSString *	value = [array safeObjectAtIndex:1];
            NSString *	type = [array safeObjectAtIndex:2];
            
            if ( type )
            {
                [sql appendFormat:@"%@ ", type];
            }
            
            if ( [value isKindOfClass:[NSNull class]] )
            {
                [sql appendFormat:@"%@ IS NULL ", key];
            }
            else if ( [value isKindOfClass:[NSNumber class]] )
            {
                [sql appendFormat:@"%@ = %@ ", key, value];
            }
            else if ( [value isKindOfClass:[NSString class]] )
            {
                [sql appendFormat:@"%@ = '%@' ", key, value];
            }
            else
            {
                [sql appendFormat:@"%@ = '%@' ", key, value];
            }
        }
    }
    
    if ( _orderby.count )
    {
        [sql appendString:@" ORDER BY "];
        
        for ( NSInteger i = 0; i < _orderby.count; ++i )
        {
            NSArray *	array = [_orderby objectAtIndex:i];
            NSString *	by = [array safeObjectAtIndex:0];
            NSString *	dir = [array safeObjectAtIndex:1];
            
            if ( 0 == i )
            {
                [sql appendFormat:@"%@ %@", by, dir];
            }
            else
            {
                [sql appendFormat:@", %@ %@", by, dir];
            }
        }
    }
    
    if ( _limit )
    {
        if ( _offset )
        {
            [sql appendFormat:@" LIMIT %llu, %llu", (unsigned long long)_offset, (unsigned long long)_limit];
        }
        else
        {
            [sql appendFormat:@" LIMIT %llu", (unsigned long long)_limit];
        }
    }
    
    return sql;
}

- (NSString *)internalCompileInsert:(NSString *)table values:(NSMutableArray *)allValues
{
    NSMutableString *	sql = [NSMutableString string];
    NSMutableArray *	allKeys = [NSMutableArray arrayWithArray:_set.allKeys];
    
    NSString *			field = nil;
    NSObject *			value = nil;
    
    [allKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * left = (NSString *)obj1;
        NSString * right = (NSString *)obj2;
        return [left compare:right options:NSCaseInsensitiveSearch];
    }];
    
    [sql appendFormat:@"INSERT INTO %@ (", table];
    
    for ( NSInteger i = 0; i < allKeys.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        
        NSString * key = [allKeys objectAtIndex:i];
        
        field = [VKDataBaseRuntime fieldNameForIdentifier:key];
        value = [_set objectForKey:key];
        
        [sql appendString:field];
        [allValues addObject:value];
    }
    
    [sql appendString:@") VALUES ("];
    
    for ( NSInteger i = 0; i < allValues.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
//        [sql appendString:@"?"];
        id curvalue = allValues[i];
        
        if ( [curvalue isKindOfClass:[NSNumber class]] )
        {
            [sql appendFormat:@"%@", curvalue];
        }
        else if ( [curvalue isKindOfClass:[NSString class]] )
        {
            [sql appendFormat:@"'%@'", curvalue];
        }
        else
        {
            [sql appendFormat:@"'%@'", curvalue];
        }

        
//        [sql appendFormat:@"%@",allValues[i]];
    }
    
    [sql appendString:@")"];
    
    return sql;
}

- (NSString *)internalCompileUpdate:(NSString *)table values:(NSMutableArray *)allValues
{
    NSMutableString *	sql = [NSMutableString string];
    NSMutableArray *	allKeys = [NSMutableArray arrayWithArray:_set.allKeys];
    
    NSString *			field = nil;
    NSString *			key = nil;
    NSObject *			value = nil;
    
    [allKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * left = (NSString *)obj1;
        NSString * right = (NSString *)obj2;
        return [left compare:right options:NSCaseInsensitiveSearch];
    }];
    
    [sql appendFormat:@"UPDATE %@ SET ", table];
    
    for ( NSInteger i = 0; i < allKeys.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        
        key = [allKeys objectAtIndex:i];
        field = [VKDataBaseRuntime fieldNameForIdentifier:key];
        value = [_set objectForKey:key];
        
        if ( [value isKindOfClass:[NSNumber class]] )
        {
            [sql appendFormat:@"%@ = %@", field,value];
        }
        else if ( [value isKindOfClass:[NSString class]] )
        {
            [sql appendFormat:@"%@ = '%@'", field,value];
        }
        else
        {
            [sql appendFormat:@"%@ = '%@'", field,value];
        }

//        [sql appendFormat:@"%@ = %@", field];
        [allValues addObject:value];
    }
    
    if ( _where.count )
    {
        [sql appendString:@"\n"];
        [sql appendString:@" WHERE"];
        
        for ( NSString * where in _where )
        {
            [sql appendFormat:@" %@", where];
        }
    }
    
    if ( _orderby.count )
    {
        [sql appendString:@"\n"];
        [sql appendString:@" ORDER BY "];
        
        for ( NSInteger i = 0; i < _orderby.count; ++i )
        {
            NSString * by = [_orderby objectAtIndex:i];
            
            if ( 0 == i )
            {
                [sql appendString:by];
            }
            else
            {
                [sql appendFormat:@", %@", by];
            }
        }
    }
    
    if ( _limit )
    {
        [sql appendString:@"\n"];
        [sql appendFormat:@" LIMIT %lu", (unsigned long)_limit];
    }
    
    return sql;
}

- (NSString *)internalCompileCreate:(NSString *)table
{
    NSMutableString * sql = [NSMutableString string];
    
    [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ ( ", table];
    
    [_field sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * left = (NSString *)[(NSDictionary *)obj1 objectForKey:@"name"];
        NSString * right = (NSString *)[(NSDictionary *)obj2 objectForKey:@"name"];
        return [left compare:right options:NSCaseInsensitiveSearch];
    }];
    
    for ( NSInteger i = 0; i < _field.count; ++i )
    {
        if ( 0 != i )
        {
            [sql appendString:@", "];
        }
        
        [sql appendString:@"\n"];
        
        NSDictionary * dict = [_field objectAtIndex:i];
        
        NSString * name = (NSString *)[dict objectForKey:@"name"];
        NSString * type = (NSString *)[dict objectForKey:@"type"];
        NSNumber * size = (NSNumber *)[dict objectForKey:@"size"];
        NSNumber * PK = (NSNumber *)[dict objectForKey:@"primaryKey"];
        NSNumber * AI = (NSNumber *)[dict objectForKey:@"autoIncrement"];
        NSNumber * UN = (NSNumber *)[dict objectForKey:@"unique"];
        NSNumber * NN = (NSNumber *)[dict objectForKey:@"notNull"];
        
        NSObject * defaultValue = [dict objectForKey:@"default"];
        
        [sql appendFormat:@"%@", name];
        
        if ( type )
        {
            [sql appendFormat:@" %@", type];
        }
        
        if ( size && size.intValue )
        {
            [sql appendFormat:@"(%@)", size];
        }
        
        if ( PK && PK.intValue )
        {
            [sql appendString:@" PRIMARY KEY"];
        }
        
        if ( AI && AI.intValue )
        {
            [sql appendString:@" AUTOINCREMENT"];
        }
        
        if ( UN && UN.intValue )
        {
            [sql appendString:@" UNIQUE"];
        }
        
        if ( NN && NN.intValue )
        {
            [sql appendString:@" NOT NULL"];
        }
        
        if ( defaultValue )
        {
            if ( [defaultValue isKindOfClass:[NSNull class]] )
            {
                [sql appendString:@" DEFAULT NULL"];
            }
            else if ( [defaultValue isKindOfClass:[NSNumber class]] )
            {
                [sql appendFormat:@" DEFAULT %@", defaultValue];
            }
            else if ( [defaultValue isKindOfClass:[NSString class]] )
            {
                [sql appendFormat:@" DEFAULT '%@'", defaultValue];
            }
            else
            {
                [sql appendFormat:@" DEFAULT '%@'", defaultValue];
            }
        }
    }
    
    [sql appendString:@" )\n"];
    
    return sql;
}

- (NSString *)internalCompileEmpty:(NSString *)table
{
    NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@", table];
    return sql;
}

- (NSString *)internalCompileDelete:(NSString *)table
{
    NSMutableString * sql = [NSMutableString string];
    
    [sql appendFormat:@"DELETE FROM %@", table];
    
    if ( _where.count || _like.count )
    {
        [sql appendString:@" WHERE "];
        
        if ( _where.count )
        {
            for ( NSString * where in _where )
            {
                [sql appendFormat:@" %@ ", where];
            }
        }
        
        if ( _like.count )
        {
            if ( _where.count )
            {
                [sql appendString:@" AND "];
            }
            
            for ( NSString * like in _like )
            {
                [sql appendFormat:@" %@ ", like];
            }
        }
    }
    
    if ( _limit )
    {
        [sql appendFormat:@" LIMIT %lu", (unsigned long)_limit];
    }
    
    return sql;
}

- (NSString *)internalCompileTrunc:(NSString *)table
{
    NSString * sql = [NSString stringWithFormat:@"TRUNCATE %@", table];
    return sql;
}

- (NSString *)internalCompileIndex:(NSString *)table
{
    NSMutableString * sql = [NSMutableString string];
    
    [sql appendFormat:@"CREATE INDEX IF NOT EXISTS index_%@ ON %@ ( ", table, table];
    
    for ( NSInteger i = 0; i < _index.count; ++i )
    {
        NSString * field = [_index objectAtIndex:i];
        
        if ( 0 == i )
        {
            [sql appendFormat:@"%@", field];
        }
        else
        {
            [sql appendFormat:@", %@", field];
        }
    }
    
    [sql appendString:@" )"];
    
    return sql;
}

- (NSString *)internalCompileExist:(NSString *)table as:(NSString *)value
{
    NSMutableString * sql = [NSMutableString string];
    
    [sql appendFormat:@"SELECT COUNT(*) as '%@'\n", value];
    [sql appendFormat:@"FROM sqlite_master\n"];
    [sql appendFormat:@"WHERE type ='table' AND name = %@", table];
    
    return sql;
}


- (NSArray *)associateObjects
{
    return _associate;
}

- (NSArray *)associateObjectsFor:(Class)clazz
{
    NSMutableArray * array = [NSMutableArray array];
    
    for ( NSObject * obj in _associate )
    {
        if ( [obj isKindOfClass:clazz] )
        {
            [array addObject:obj];
        }
    }
    
    return array;
}

- (NSArray *)hasObjects
{
    return _has;
}

- (NSArray *)hasObjectsFor:(Class)clazz
{
    NSMutableArray * array = [NSMutableArray array];
    
    for ( NSObject * obj in _has )
    {
        if ( [obj isKindOfClass:clazz] )
        {
            [array addObject:obj];
        }
    }
    
    return array;
}

- (void)associate:(NSObject *)obj
{
    if ( nil == obj )
        return;
    
    [_associate addObject:obj];
}

- (void)has:(NSObject *)obj
{
    if ( nil == obj )
        return;
    
    [_has addObject:obj];
}



#pragma mark - Blocks

- (VKSqlGeneratorBlockN)TABLE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self table:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)FIELD
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString *	field = (NSString *)first;
        NSString *	type = va_arg( args, NSString * );
        
        va_end( args );
        
        return [self field:field type:type size:0];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)FIELD_WITH_SIZE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString *	field = (NSString *)first;
        NSString *	type = va_arg( args, NSString * );
        NSUInteger	size = va_arg( args, NSUInteger );
        
        va_end( args );
        
        return [self field:field type:type size:size];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)UNSIGNED
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self unsignedType];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)NOT_NULL
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self notNull];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)PRIMARY_KEY
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self primaryKey];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)AUTO_INREMENT
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self autoIncrement];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)DEFAULT_ZERO
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self defaultZero];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)DEFAULT_NULL
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self defaultNull];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)DEFAULT
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self defaultValue:first];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)UNIQUE
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self unique];
    };
    
    return block;
}

- (VKSqlStringBlock)CREATE_IF_NOT_EXISTS
{
    VKSqlStringBlock block = ^ NSString * ( void )
    {
        return [self createTableIfNotExists];
    };
    
    return block;
}

- (VKSqlStringBlockN)INDEX_ON
{
    VKSqlStringBlockN block = ^ NSString * ( id field, ... )
    {
        va_list args;
        va_start( args, field );
        
        NSMutableArray * array = [NSMutableArray array];
        
        for ( ;; field = nil )
        {
            NSObject * name = field ? field : va_arg( args, NSObject * );
            if ( nil == name || NO == [name isKindOfClass:[NSString class]] )
                break;
            
            [array addObject:(NSString *)name];
        }
        
        va_end(args);
        
        return [self indexTable:nil on:array];// ? self : nil;
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self select:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_MAX
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self selectMax:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_MAX_ALIAS
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * field = (NSString *)first;
        NSString * alias = (NSString *)va_arg( args, NSString * );
        
        va_end( args );
        
        return [self selectMax:field alias:alias];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_MIN
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self selectMin:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_MIN_ALIAS
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * field = (NSString *)first;
        NSString * alias = (NSString *)va_arg( args, NSString * );
        
        va_end(args);
        
        return [self selectMin:field alias:alias];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_AVG
{
   VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self selectAvg:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_AVG_ALIAS
{
   VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * field = (NSString *)first;
        NSString * alias = (NSString *)va_arg( args, NSString * );
        
        va_end( args );
        
        return [self selectAvg:field alias:alias];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_SUM
{
   VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self selectSum:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SELECT_SUM_ALIAS
{
   VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * field = (NSString *)first;
        NSString * alias = (NSString *)va_arg( args, NSString * );
        
        va_end( args );
        
        return [self selectSum:field alias:alias];
    };
    
    return block;
}

- (VKSqlGeneratorBlock)DISTINCT
{
    VKSqlGeneratorBlock block = ^ VKSqlGenerator * ( void )
    {
        return [self distinct:YES];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)FROM
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self from:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)WHERE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self where:key value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_WHERE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self orWhere:key value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)WHERE_OPERATOR
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSString * expr = (NSString *)va_arg( args, NSString * );
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self where:key expr:expr value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_WHERE_OPERATOR
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSString * expr = (NSString *)va_arg( args, NSString * );
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self orWhere:key expr:expr value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)WHERE_IN
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id field, ... )
    {
        va_list args;
        va_start( args, field );
        
        NSString * key = (NSString *)field;
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; )
        {
            NSObject * value = va_arg( args, NSObject * );
            if ( nil == value )
                break;
            
            if ( [value isKindOfClass:[NSArray class]] )
            {
                [array addObjectsFromArray:(id)value];
            }
            else
            {
                [array addObject:(NSString *)value];
            }
        }
        
        va_end( args );
        
        return [self whereIn:key values:array];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_WHERE_IN
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id field, ... )
    {
        va_list args;
        va_start( args, field );
        
        NSString * key = (NSString *)field;
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; )
        {
            NSObject * value = va_arg( args, NSObject * );
            if ( nil == value )
                break;
            
            if ( [value isKindOfClass:[NSArray class]] )
            {
                [array addObjectsFromArray:(id)value];
            }
            else
            {
                [array addObject:(NSString *)value];
            }
        }
        
        va_end( args );
        
        return [self orWhereIn:key values:array];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)WHERE_NOT_IN
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id field, ... )
    {
        va_list args;
        va_start( args, field );
        
        NSString * key = (NSString *)field;
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; )
        {
            NSObject * value = va_arg( args, NSObject * );
            if ( nil == value )
                break;
            
            if ( [value isKindOfClass:[NSArray class]] )
            {
                [array addObjectsFromArray:(id)value];
            }
            else
            {
                [array addObject:(NSString *)value];
            }
        }
        
        va_end( args );
        
        return [self whereNotIn:key values:array];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_WHERE_NOT_IN
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id field, ... )
    {
        va_list args;
        va_start( args, field );
        
        NSString * key = (NSString *)field;
        
        NSMutableArray * array = [NSMutableArray array];
        for ( ;; )
        {
            NSObject * value = va_arg( args, NSObject * );
            if ( nil == value )
                break;
            
            if ( [value isKindOfClass:[NSArray class]] )
            {
                [array addObjectsFromArray:(id)value];
            }
            else
            {
                [array addObject:(NSString *)value];
            }
        }
        
        va_end( args );
        
        return [self orWhereNotIn:key values:array];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)LIKE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self like:key match:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)NOT_LIKE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self notLike:key match:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_LIKE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self orLike:key match:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_NOT_LIKE
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self orNotLike:key match:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)GROUP_BY
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self groupBy:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)HAVING
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self having:key value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)OR_HAVING
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self orHaving:key value:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)ORDER_ASC_BY
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self orderAscendBy:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)ORDER_DESC_BY
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self orderDescendBy:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)ORDER_RAND_BY
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self orderRandomBy:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)ORDER_BY
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * by = (NSString *)first;
        NSString * direction = (NSString *)va_arg( args, NSString * );
        
        va_end( args );
        
        return [self orderBy:by direction:direction];
    };
    
    return block;
}

- (VKSqlGeneratorBlockU)LIMIT
{
    VKSqlGeneratorBlockU block = ^ VKSqlGenerator * ( NSUInteger value )
    {
        return [self limit:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockU)OFFSET
{
    VKSqlGeneratorBlockU block = ^ VKSqlGenerator * ( NSUInteger value )
    {
        return [self offset:value];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SET_NULL
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        return [self set:(NSString *)first];
    };
    
    return block;
}

- (VKSqlGeneratorBlockN)SET
{
    VKSqlGeneratorBlockN block = ^ VKSqlGenerator * ( id first, ... )
    {
        va_list args;
        va_start( args, first );
        
        NSString * key = (NSString *)first;
        NSObject * value = (NSObject *)va_arg( args, NSObject * );
        
        va_end( args );
        
        return [self set:key value:value];
    };
    
    return block;
}

- (VKSqlStringBlock)GET
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self get];
    };
    
    return block;
}

- (VKSqlStringBlock)COUNT
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self count];
    };
    
    return block;
}

- (VKSqlStringBlock)INSERT
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self insert];
    };
    
    return block;
}

- (VKSqlStringBlock)UPDATE
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self update];
    };
    
    return block;
}

- (VKSqlStringBlock)EMPTY
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self empty];
    };
    
    return block;
}

- (VKSqlStringBlock)TRUNCATE
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self truncate];
    };
    
    return block;
}

- (VKSqlStringBlock)DELETE
{
    VKSqlStringBlock block = ^ NSString* ( void )
    {
        return [self delete];
    };
    
    return block;
}

@end
