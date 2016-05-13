//
//  DBConfig.h
//  MTDB
//
//  Created by Tim on 15/6/11.
//  Copyright (c) 2015年 Tim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTDBModel.h"
#import <FMDB/FMDB.h>

#define DocumentPath NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]
#define checkStr(str) [str isKindOfClass:[NSNumber class]]?[NSString stringWithFormat:@"%@",str]:([str isKindOfClass:[NSNull class]]||str==nil?@"":str)

@interface DBConfig : NSObject
@property (nonatomic,strong)NSString *DBName;
@property (nonatomic,strong)FMDatabaseQueue *baseQueue;
+(DBConfig*)allocWithDBName:(NSString*)DBP;
+(DBConfig*)shareQueue;
+(DBConfig*)updataOldDB:(NSString*)olddb NewDB:(NSString*)newdb;

+(NSArray*)needWithAr1:(NSArray*)array1 Ar2:(NSArray*)array2;
@end
