##DataBase简介
# 

这是一个基于FMDB的数据库框架，FMDB在使用上支持多个数据库管理，同步，异步数据库，线程安全等，但是FMDB在工作原理上，输入参数必须是sql语句，这对使用者的数据库相关知识了解程度有很高要求。

在FMDB的使用上，必须将sql语句字符串无差错的传入FMDB最终返回字典查询结果。

在FMDB之上进行封装了，采用了强大的Objective-C运行时控制，能够勿须iOS开发人员懂数据库知识，动态的对任何业务模型，自动生成create , query，insert，update语句并进行执行，并且能将fmdb返回的字典表数据，动态的自动反解称为任何业务模型对象，勿须任何开发操作

由一套强大的动态运行时适配模块，和sql语句生成模块组成

动态运行时适配模块：任意自定义的业务模型通过运行时转化成字典表数据，并且可以由db查询出来的字典表数据反向转化回任意自定义业务模型，这个过程借助VKFMDBHelper的框架纯自动完成，iOS开发人员在这块，不需要进行任何额外的开发

sql语句生成模块组成：通过自动转化出来的字典表数据，全自动的生成create , query，insert，update等SQL代码，iOS开发人员可以完全不懂数据库，也能完成数据库操作。如果开发人员精通SQL，还支持自行书写复杂高效sql语句，直接执行，更加灵活


##DataBase第三方依赖
# 
 - FMDB 第三方SQLite数据库
 - MacOS 10.7 及以上版本
 - Xcode 4.6 及以上版本
 

##环境配置
# 
 - 将FMDB导入工程，两种均可
 	- cocoapod `pod 'FMDB'`
 	- 源码导入 	
 - 直接引用头文件`VKDBManager.h` 即可使用DBManager
 - 自定义对象直接继承自`VKDBModel` 即可自动享有动态匹配，自动生成sql的功能

##基本用法
# 
###1 创建自定义数据对象
# 

创建一个需要进行数据库管理的对象模型，继承自`VKDBModel`，比如这里创建一个叫做person的类，他具有firstName，lastName，age，personId四个属性,

	@interface person : VKDBModel

	@property (nonatomic,strong) NSString* personId;

	@property (nonatomic,strong) NSString* firstName;

	@property (nonatomic,strong) NSString* lastName;

	@property (nonatomic,assign) NSInteger age;

	@end


这样这个person简简单单的类，就自动拥有了运行时动态匹配表数据，自动生成sql等能力


如何使用后面细说

###2 关于主键
# 
VKDBModel会自动创建一个隐含的自增主键属性，属性名为dataBaseId

如果用户不指定主键的话，数据库框架依然能正常工作

用户指定主键，需要在person类里重写`uniqueKeyName`方法，指定personId为用户主键，方便后期查找


	+(NSString *)uniqueKeyName
	{
    	return @"personId";
	}

###3 打开数据库
# 

打开数据库，如果使用`openDefault`方法会自动以app bundlename当做数据库名，创建并打开

	[[VKDBManager defaultManager] openDefault];
	

`VKDBManager`本身是单例，支持同时打开关闭多个数据库，并且切换当前使用中的数据库，具体参见相关接口文档

###4 数据模型mapping及建表
# 

每一个`VKDBModel`的模型，在使用前都需要进行mapping，通过运行时建立好属性的映射表，才能在后面进行运行时转换以及sql自动生成

每一个`VKDBModel`的模型，都要先在数据库里成功的创建好表，如果表已经建好重复调用没事
	
	 [K12StudyKeyPointDBModel buildTable];//数据库建表 or 标记表已建好
	 
###5 写入数据库

创建一个person对象，对象赋值，然后执行`saveToDB`

自动生成这个person对象写入数据库所需要的sql语句

自动在打开的数据库中执行这条sql语句

最终实现了这个person对象入库的流程

	person* p = [[person alloc]init];
    p.personId = @"1";
    p.firstName = @"defu";
    p.lastName = @"wang";
    p.age = 28;
    
    [p saveToDB];
    
###6 从数据库刷新
# 
如果一个person对象，已经其用户主键已经有值，调用`refresh`方法，就会自动从数据库中读取该主键键值下的数据，并且赋值刷新给person

自动生成 这个person对象 这个主键-键值的读取sql语句

自动将数据库中读取出来的表结构，运行时匹配赋值给person

	person* p = [[person alloc]init];
    p.personId = @"1";

    [p refresh];
    
    
###7 从数据库查找
# 
获取person表下所有对象，或者获取person表下某个范围的对象合集

自动生成query的sql语句

从数据库中取出大量表数据

一键自动映射到对象上

	NSArray* result1 = [person allObjectData];
    //查询person表所有数据
    NSArray* result2 = [person objectDataWhereKeyName:@"lastName" Opertor:@"=" Value:@"wang"];
    //查询person表 lastname = wang的所有数据
    NSArray* result3 = [person objectDataWhereKeyName:@"age" Opertor:@"<" Value:@"50"];
    //查询person表 age < 50 的所有数据
    
    //所有返回的数据都是数组 不是person对象
    NSMutableArray* objectArr = [[NSMutableArray alloc]init];
    for (NSDictionary* itemdic in result1) {
        person* p = [[person alloc]initWithDictionary:itemdic];//一键自动将数组转化为对象
        [objectArr addObject:p];
    }
    
##灵活用法
# 

    
###1核心思路
# 
 - 借助`VK_SqlGenerator`可以无需懂sql语法，根据行为和语义生成sql语句
 
 - 每一个操作都是可以生成一条sql语句字符串string，从而交个`VKDBManager`来执行  
 
 - 每次查找数据库返回的都是字典，不是对象
 
 - 字典可以借助运行时匹配，一键转化为对象
 
 - `saveToDB` `refresh`都是内部封装好了，先生成sql，再执行，再转化对象赋值
 
###2灵活生成Sql语句

`VK_SqlGenerator` 采用了时下流行的链式语法，在语义的表述下，流畅的生成了sql语句

- `.Table`  `.From`  等为生成器开始头，多用from，table为创建表的使用使用，已经封装在`buildTable`方法里

- `.Where` `.Limit` `.Set`等为生成器中部，用于执行筛选，或者设置字段，并且这些语句可以重复执行，set多次或者筛选多个条件

- `.Get` `.Update` `.Insert` `.Create` 等为生成器尾部，执行了这个方法，最终会根据前边执行过的路径生成最终的sql语句，并返回

数据库SQL语句生成样例

	
    NSString* getSql = VK_SqlGenerator.FROM([person tableName]).WHERE_OPERATOR(@"age",@"<",@"28").WHERE_OPERATOR(@"lastName",@"=",@"wang").GET();
    
`这是一条2个组合筛选条件的查找`

	NSString* sql = VK_SqlGenerator.FROM(self.tableName).WHERE_OPERATOR(@"course",@"=",course).DELETE();
 	
`这是一条单筛选条件的删除`

	VK_SqlGenerator
    .FROM( [person tableName] )
    .WHERE( @"personId", @"1" );
    
    for ( 属性运行时mapping循环 ) {
        VK_SqlGenerator.SET( name, value );
    }
    
    NSString* updateSql = VK_SqlGenerator.UPDATE();
    
`这是一条有筛选条件的数据更新`循环赋值部分为伪代码，已经被封装在saveToDB里

###3直接执行手写sql语句
# 
如果开发者有数据库的知识和能力，可以自行书写复杂sql语句，直接交给`VKDBManager`来执行

尤其是数据库升级 alternate等复杂操作

目前还没对数据库迁移 升级 做好完善强大的语句生成器

	NSString* updateSql = @"INSERT INTO tablename SET column_name1 = value1, column_name2 = value2";
    //手写sql
    [VKDBManager doUpdateSQL:sql];
    //如果写的是写入语句 执行doUpdate
    [VKDBManager doQuerySql:sql];
    //如果写的是查询语句 执行doQuery
    
###4查询表数据映射成对象
# 
因为查询接口返回的数据，都是字典结构，而不是对象，所以需要一次转化

	 person* p = [[person alloc]initWithDictionary:itemdic];//一键自动将数组转化为对象
	 
###5 灵活运用
# 
`生成sql`,`执行`,`字典映射`，这三个步骤是VKommonX DataBase的核心，灵活的拆解，变化，运用，可以实现多变的扩展

##异步操作
# 
###1 异步模式
 - FMDB支持传入一组sql语句，由其内部异步队列完成，最后通过block回调结果

 - VKFMDBHelper将其封装，所有sql语句，可以直接执行，也可以传入mannager的sql队列管理器，进行一次统一的异步执行
 
 - 处理异步的回调，VKFMDBHelper封装了一套事件注册机制，每一次异步操作都可以在注册后在主线程监听其回复
 
###2 异步数据库操作流程
# 

 - 注册异步数据库监听事件，所有异步的数据返回
 都走监听事件返回，为了区别不同事件，每个事件在提交的时候可以指定tag，根据不同tag来区别处理返回数据
#  

#  

	[[VKDBManager defaultManageVKr]addDataBaseNotificationAtTarget:self withComplete:^(NSString *tag, BOOL succuse, NSArray *result) {
	 
	if ([tag isEqualToString:@"event"]) { //可以识别提交任务的tag
		NSLog(@"ccccc");
        }
    }];	
    
#         

 - 先执行开始异步操作，包括开始异步查找，开始异步写入

# 

	 [VKDBManager beginBackgroundUpdate]; 	
	 [VKDBManager beginBackgroundQuery]; 
# 
 - 往异步队列里写入sql语句
 	- 可以通过生成sql语句，直接往队列里添加
 	- 也可以通过封装好的单个对象  saveInBackground deleteInBackground等VKDBModel的方法自动加入队列，但暂时还不执行
 	
#  

	//将生成好的sql放入对应队列
	[VKDBManager addUpdateTaskSQL:sql];
	[VKDBManager addQueryTaskSQL:sql];
	
# 	

	//使用VKDBModel的封装方法加入队列
	person* p;
    [p saveInBackground];
    [p deleteInBackground];
    //将自动生成的sql加入update队列 暂不执行
    
 - 用`VKDBManager`来提交sql队列中的未执行sql语句，提交的时候可以带上tag名，如果没有带则使用默认tag `defaultUpdate` or `defaultQuery`
 
# 
	 [VKDBManager commitBackgroundUpdateWithTaskTag:@"savetask"];//提交tag为savetask
	 [VKDBManager commitBackgroundUpdate];//提交tag为默认tag
	 
# 
 - 数据返回为数组，里面为字典结构，需要手动一键转化为对象

	
 
###3 sql队列管理器

`VKSQLQueueManager` sql队列管理器包含两个队列，`update``query`两个队列，这两个队列各不相干，

 - 每次begin操作 会清空队列
 - 每次comit操作也会清空队列
 
###4 使用样例
 
 	 [[VKDBManager defaultManager]addDataBaseNotificationAtTarget:self withComplete:^(NSString *tag, BOOL succuse, NSArray *result) {
        if ([tag isEqualToString:@"savetask"]) {
            
        }
    }];
    
    [VKDBManager beginBackgroundUpdate];
	
    NSLog(@"aaa time ===");
    for (NSInteger i = 300; i < 4000; i++) {
        K12KeyPointVisitDBModel * model = [[K12KeyPointVisitDBModel alloc]init];
        model.kpid = [NSString stringWithFormat:@"adfadf%@",@(i)];
        model.deltaCount = 100;
        [model saveInBackground]; //循环将sql string  添加到队列
    }
    
    [VKDBManager commitBackgroundUpdateWithTaskTag:@"savetask"];
    
##数据内联

# 
###1 一个`VKDBModel`中含有另一个`VKDBModel`

新建一个dog的`VKDBModel`对象
# 
	
	@interface dog : VKDBModel

	@property (nonatomic,strong)NSString* dogId;

	@property (nonatomic,strong) NSString* dogName;

	@end
# 
改写person对象

	@interface person : VKDBModel

	@property (nonatomic,strong)NSString* personId;

	@property (nonatomic,strong) NSString* firstName;
	
	@property (nonatomic,strong) NSString* lastName;

	@property (nonatomic,assign) NSInteger age;
	
	@property (nonatomic,strong) dog* pet;

	@end	
	
 - 对person建表的时候，dog字段会当做string，  将dog类的唯一key存入数据库（dog必须重写uniqueKey，否则会报断言错误）
 
 - 对person对象进行save的时候，会将person的pet属性，生成一条dog的sql并执行，也生成一条person的sql并执行
 
 - 对person对象进行saveInBackground的时候，会直接生成2条sql语句，进入sql队列

 - 数据读取，无论是通过refresh方式，还是通过字典转化，person的dog属性，都只有uniqueKey有值，其他为空
 - 对dog属性只有uniqueKey有值，其他为空的person执行`refreshInnerDBModel`，可以补全dog对象的数值
 
# 
	 //从person的表中查找出来的字典结果 转化为对象
    person* p = [[person alloc]initWithDictionary:itemdic];
    //person直接refresh出来的结果
    person *p =[[person alloc]init];
    p.personId = @"1";
    [p refresh];
    
    //以上两个结果 p 的dog属性对象，都只有dogId有数值，dog的其他属性如dogname 为空
    [p refreshInnerDBModel];
    //p 的dog属性补全
    
  # 
###2 一个`VKDBModel`中含有一个数组，数组内均为另一个`VKDBModel`

# 
改写person对象

	@interface person : VKDBModel

	@property (nonatomic,strong)NSString* personId;

	@property (nonatomic,strong) NSString* firstName;
	
	@property (nonatomic,strong) NSString* lastName;

	@property (nonatomic,assign) NSInteger age;
	
	@property (nonatomic,strong) NSArray* pets;

	@end	
	
 - 对person建表的时候，pets字段会当做string
 
 - 将pets数组里的所有dog对象的唯一key，序列化转为字符串，存入数据库（dog必须重写uniqueKey，否则会报断言错误）
 
 - 对person对象进行save的时候，会将person的pets属性，生成一组dog的sql并执行，也生成一条person的sql并执行
 
 - 对person对象进行saveInBackground的时候，会直接生成N+1条sql语句，进入sql队列

 - 数据读取，无论是通过refresh方式，还是通过字典转化，pet数组里的dog对象的属性，都只有uniqueKey有值，其他为空
 - 对person执行`refreshInnerDBModel`，可以补全dog对象的数值
 
# 
	 //从person的表中查找出来的字典结果 转化为对象
    person* p = [[person alloc]initWithDictionary:itemdic];
    //person直接refresh出来的结果
    person *p =[[person alloc]init];
    p.personId = @"1";
    [p refresh];
    
    //以上两个结果 p 的dog属性对象，都只有dogId有数值，dog的其他属性如dogname 为空
    [p refreshInnerDBModel];
    //p 的dog数组所有对象属性补全

###3 数据内联说明
# 
VKFMDBHelper的数据库模块并没有支持很强大的数据内联的对象之间，关联查找的功能，只具备最基本的内联形式。

可以从业务数据库表结构入手，将表结构关联性简化，从而使用VKFMDBHelperVK的数据库

如果业务需求需要更高级的数据内联模式，或者现有功能无法满足需求，可以选择手写sql语句，业务逻辑自行赋值的方法，完成更复杂的功能

VKFMDBHelperVK的数据内联，可能还不稳定，后续在持续更新中

##注意事项
# 
 - VKDBModel 只支持 NSNumber(nsinterge cgfloat) NSDate NSArray NSString
 
 - NSArray 中只有 NSString NSNumber
 
 - 如果出现不支持的属性字段会断言报错
 
 - 内联对象没指定uniqueKey会断言报错
 
 - NSDictionary出现在属性会报错（不支持，以后可以考虑扩展，字典内只有NSString NSNumber 才有效）
 
 - 所有异步操作的接口，必须在主线程调用，在线程调用会断言报错，因为内部会统一线程管理
 
##接口详解
# 
###1 VKDBModel
# 
`-(instancetype)initWithDictionary:(NSDictionary*)dic;`

字典自动转化为`VKDBModel`对象

`+(NSString*)uniqueKeyName;`

重载，指定唯一uniqueKey

`+(BOOL)buildTable;`

建表，主线程，可重复执行

`+(BOOL)clearTable;`

清空表，主线程

`-(BOOL)exsit;`

对象的uniqueKey在数据库中是否存在

`-(BOOL)refresh;`

使用对象的uniqueKey，从数据库中查找，赋值给对象

`-(void)refreshInnerDBModel;`

补全对象内联对象的其他属性

`-(void)saveInBackground;`

生成保存sqlstring，放入队列

`-(void)saveToDB;`

生成保存sqlstring，直接执行

`-(void)deleteFromDB;`

生成删除sql，直接执行

`-(void)deleteInBackground;`

生成删除sql，放入队列

`+(NSArray*)allObjectData;`

生成查找全体sql，直接执行

`+(void)allObjectDataQuerryInBackground;`

生成查找全体sql，放入队列

`+(NSArray*)objectDataWhereKeyName:(NSString*)key Opertor:(NSString*)opera Value:(NSString*)value;`

生成条件查找sql，直接执行

`+(void)objectDataQuerryInBackgroundWhereKeyName:(NSString*)key Opertor:(NSString*)opera Value:(NSString*)value;`

生成条件查找sql，放入队列

###2 VKDBManager

`- (instancetype)sharedInstance;`

`+ (instancetype)defaultManager;`

单例功能

`-(BOOL)openDefault;`

打开app bundleID为名的数据库

`-(BOOL)closeDefault;`

关闭app bundleID为名的数据库

`-(BOOL)openDataBaseWithName:(NSString*)name;`

打开指定名称数据库

`-(BOOL)closeDataBaseWithName:(NSString*)name;`

关闭指定名称数据库

`-(VKDataBase*)currentDataBase;`

当前操作的数据库

`-(void)changeCurrentDataBase:(NSString*)name;`

切换当前操作的数据库

`-(void)changeCurrentDataBaseDefault;`

切换当前操作的数据库为默认数据库

`-(void)addDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block;`

异步数据库注册监听，以注册对象的名称注册

`-(void)removeDataBaseNotificationAtTarget:(id)target withComplete:(VKDataBaseQueueBlockReturn)block;`

异步数据库移除监听，以注册对象的名称注册

`-(void)addDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block;`

异步数据库注册监听，以自定义名称注册

`-(void)removeDataBaseNotificationAtTarget:(id)target withIdentifier:(NSString*)idstr withComplete:(VKDataBaseQueueBlockReturn)block;`

异步数据库移除监听，以自定义名称注册

`+(NSInteger)lastInsertRowId;`

当前操作数据库上条插入的RowId

`+(void)addUpdateTaskSQL:(NSString*)sql;`

sql语句加入写队列

`+(void)addQueryTaskSQL:(NSString*)sql;`

sql语句加入读队列

`+(BOOL)doUpdateSQL:(NSString*)sql;`

执行写语句

`+(NSArray*)doQuerySql:(NSString*)sql;`

执行读语句

`+(void)beginBackgroundQuery;`

开始后台查找，清空队列

`+(void)beginBackgroundUpdate;`

开始后台写入，清空队列

`+(void)commitBackgroundQuery;`

提交查询，使用默认tag，失败默认不回滚

`+(void)commitBackgroundQueryWithTaskTag:(NSString*)tag;`

提交查询，使用tag，失败默认不会滚

`+(void)commitBackgroundQueryWithTaskTag:(NSString*)tag errorRollback:(BOOL)enablerollback;`

提交查询，使用tag，

`+(void)commitBackgroundUpdate;`

提交写入，使用默认tag，失败不回滚

`+(void)commitBackgroundUpdateWithTaskTag:(NSString*)tag;`

提交写入，使用tag，失败不回滚

`+(void)commitBackgroundUpdateWithTaskTag:(NSString*)tag errorRollback:(BOOL)enablerollback;`

提交写入，使用tag，

###3 VKSqlGenerator
# 

 - sql生成器使用比较灵活，接口繁多，不一一介绍
 
 - 具体看数据库 `灵活扩展` 部分
 
 - 采用了链式语法
 