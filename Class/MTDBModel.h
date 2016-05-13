//
//  MTDBModel.h
//  MTDB
//
//  Created by Tim on 15/6/11.
//  Copyright (c) 2015年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBConfig.h"


@interface MTDBModel : NSObject
@property (nonatomic,strong)NSString *tableName;
@property (nonatomic,strong)NSArray *keys;
@property (nonatomic,strong)NSString *indexKey;
@property (nonatomic,assign)NSInteger pageSize;

//@property (nonatomic,strong)NSString *orderKey;

@property (nonatomic,assign)BOOL ase;

+(MTDBModel*)GetTabele:(NSString*)TBNAME;

-(NSMutableArray*)selectOR:(NSDictionary*)dic page:(NSInteger)p;
-(NSMutableArray*)selectAND:(NSDictionary*)dic page:(NSInteger)p;
-(NSMutableArray*)selectAND:(NSDictionary*)dic page:(NSInteger)p orderBy:(NSDictionary*)orderDic;
-(NSMutableArray*)selectWhere:(NSString*)str OrderBy:(NSDictionary*)orderDic Page:(int)p;


-(NSMutableArray*)selectANDdic:(NSDictionary*)andDic ORdic:(NSDictionary*)orDic Page:(NSInteger)p PageSize:(NSInteger)ps OrderBy:(NSDictionary*)orderDic;
-(NSMutableArray*)selectWhereStr:(NSString*)whereStr Page:(NSInteger)p PageSize:(NSInteger)ps OrderBy:(NSString*)orderStr;

-(NSDictionary*)selectSingle:(NSDictionary*)dic;

-(void)saveWithArray:(NSArray*)array;
-(BOOL)saveWithDic:(NSDictionary*)dic;
-(BOOL)deleteWithDic:(NSDictionary*)dic;
-(void)cleanUp;
-(void)setLimit:(NSInteger)PageSize;

-(NSString*)SplicingDic:(NSDictionary*)dic Format:(NSString*)format LastWord:(NSInteger)size;

@end
