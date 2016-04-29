//
//  VKSqlGenerator.h
//
//  Created by awhisper on 15/2/10.
//  Copyright (c) 2015年 awhisper. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VK_SqlGenerator [VKSqlGenerator defaultSqlGenerator]

@class VKSqlGenerator;

typedef VKSqlGenerator *	(^VKSqlGeneratorBlockI)( NSInteger val );
typedef VKSqlGenerator *	(^VKSqlGeneratorBlockU)( NSUInteger val );
typedef VKSqlGenerator *	(^VKSqlGeneratorBlockN)( id key, ... );
typedef VKSqlGenerator *	(^VKSqlGeneratorBlockB)( BOOL flag );
typedef VKSqlGenerator *	(^VKSqlGeneratorBlock)( void );
typedef NSString*           (^VKSqlStringBlock)( void );
typedef NSString*           (^VKSqlStringBlockI)( NSInteger val );
typedef NSString*           (^VKSqlStringBlockU)( NSUInteger val );
typedef NSString*           (^VKSqlStringBlockN)( id key, ... );
typedef NSString*           (^VKSqlStringBlockB)( BOOL flag );


@interface VKSqlGenerator : NSObject

- (instancetype)sharedInstance;

+ (instancetype)defaultSqlGenerator;



@property (nonatomic, readonly) VKSqlGeneratorBlockN		TABLE;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		FIELD;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		FIELD_WITH_SIZE;
@property (nonatomic, readonly) VKSqlGeneratorBlock		UNSIGNED;
@property (nonatomic, readonly) VKSqlGeneratorBlock		NOT_NULL;
@property (nonatomic, readonly) VKSqlGeneratorBlock		PRIMARY_KEY;
@property (nonatomic, readonly) VKSqlGeneratorBlock		AUTO_INREMENT;
@property (nonatomic, readonly) VKSqlGeneratorBlock		DEFAULT_ZERO;
@property (nonatomic, readonly) VKSqlGeneratorBlock		DEFAULT_NULL;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		DEFAULT;
@property (nonatomic, readonly) VKSqlGeneratorBlock		UNIQUE;
@property (nonatomic, readonly) VKSqlStringBlock		CREATE_IF_NOT_EXISTS;

@property (nonatomic, readonly) VKSqlStringBlockN		INDEX_ON;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_MAX;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_MAX_ALIAS;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_MIN;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_MIN_ALIAS;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_AVG;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_AVG_ALIAS;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_SUM;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SELECT_SUM_ALIAS;

@property (nonatomic, readonly) VKSqlGeneratorBlock		DISTINCT;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		FROM;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		WHERE;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_WHERE;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		WHERE_OPERATOR;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_WHERE_OPERATOR;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		WHERE_IN;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_WHERE_IN;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		WHERE_NOT_IN;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_WHERE_NOT_IN;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		LIKE;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		NOT_LIKE;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_LIKE;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_NOT_LIKE;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		GROUP_BY;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		HAVING;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		OR_HAVING;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		ORDER_ASC_BY;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		ORDER_DESC_BY;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		ORDER_RAND_BY;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		ORDER_BY;

@property (nonatomic, readonly) VKSqlGeneratorBlockU		LIMIT;
@property (nonatomic, readonly) VKSqlGeneratorBlockU		OFFSET;

@property (nonatomic, readonly) VKSqlGeneratorBlockN		SET;
@property (nonatomic, readonly) VKSqlGeneratorBlockN		SET_NULL;

@property (nonatomic, readonly) VKSqlStringBlock	GET;
@property (nonatomic, readonly) VKSqlStringBlock	COUNT;

@property (nonatomic, readonly) VKSqlStringBlock		INSERT;
@property (nonatomic, readonly) VKSqlStringBlock	UPDATE;
@property (nonatomic, readonly) VKSqlStringBlock	EMPTY;
@property (nonatomic, readonly) VKSqlStringBlock	TRUNCATE;
@property (nonatomic, readonly) VKSqlStringBlock	DELETE;


@end
