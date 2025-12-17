//
//  AdScopeDBHelperModel.h
//  AdScopeFoundation
//
//  Created by Cookie on 2023/5/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AdScopeDBHelper;

@interface AdScopeDBHelperModel : NSObject

/** 主键 id */
@property (nonatomic, assign) int pkid;
/** 列名 */
@property (retain, readonly, nonatomic) NSMutableArray *columeNames;
/** 列类型 */
@property (retain, readonly, nonatomic) NSMutableArray *columeTypes;

/**
 *  获取该类的所有属性
 */
+ (NSDictionary *)getPropertys;

/** 获取所有属性，包括主键 */
+ (NSDictionary *)getAllProperties;

/** 数据库中是否存在表 */
+ (BOOL)isExistInTable:(NSString *)tableName;

/** 表中数据个数 */
+ (int)tableItemCount:(NSString *)tableName;

/// 根据条件获取数据条数
+ (int)tableItemCount:(NSString *)tableName format:(NSString *)format, ...;

/** 表中的字段*/
+ (NSArray *)getColumnsTable:(NSString *)tableName;

/** 保存或更新
 * 如果不存在主键，保存，
 * 有主键，则更新
 */
- (BOOL)saveOrUpdateTable:(NSString *)tableName;
/** 保存或更新
 * 如果根据特定的列数据可以获取记录，则更新，
 * 没有记录，则保存
 */
- (BOOL)saveOrUpdateTable:(NSString *)tableName columnName:(NSString*)columnName columnValue:(NSString*)columnValue;
/** 保存单个数据 */
- (BOOL)saveTable:(NSString *)tableName;
/** 批量保存数据 */
+ (BOOL)saveTable:(NSString *)tableName objects:(NSArray *)array;
/** 更新单个数据 */
- (BOOL)updateTable:(NSString *)tableName;
/** 批量更新数据*/
+ (BOOL)updateTable:(NSString *)tableName objects:(NSArray *)array;
/** 删除单个数据 */
- (BOOL)deleteTable:(NSString *)tableName;
/** 批量删除数据 */
+ (BOOL)deleteTable:(NSString *)tableName objects:(NSArray *)array;
/** 通过条件删除数据 */
+ (BOOL)deleteObjectsTable:(NSString *)tableName byCriteria:(NSString *)criteria;
/** 通过条件删除 (多参数）--2 */
+ (BOOL)deleteObjectsTable:(NSString *)tableName format:(NSString *)format, ...;
/** 清空表 */
+ (BOOL)clearTable:(NSString *)tableName;

/** 查询全部数据 */
+ (NSArray *)findAllTable:(NSString *)tableName;

/** 通过主键查询 */
+ (instancetype)findTable:(NSString *)tableName byPK:(int)inPk;

+ (instancetype)findFirstTable:(NSString *)tableName format:(NSString *)format, ...;

/** 查找某条数据 */
+ (instancetype)findFirstTable:(NSString *)tableName byCriteria:(NSString *)criteria;

+ (NSArray *)findWithTable:(NSString *)tableName format:(NSString *)format, ...;

/** 通过条件查找数据
 * 这样可以进行分页查询 @" WHERE pk > 5 limit 10"
 */
+ (NSArray *)findTable:(NSString *)tableName byCriteria:(NSString *)criteria;
/**
 * 创建表
 * 如果已经创建，返回YES
 */
+ (BOOL)createTable:(NSString *)tableName;

#pragma mark - must be override method
/** 如果子类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 */
+ (NSArray *)transients;

@end

NS_ASSUME_NONNULL_END
