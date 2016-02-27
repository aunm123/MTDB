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

@interface DBConfig : NSObject
@property (nonatomic,strong)NSString *DBName;
@property (nonatomic,strong)FMDatabaseQueue *baseQueue;
+(DBConfig*)allocWithDBName:(NSString*)DBP;
+(DBConfig*)shareQueue;
+(DBConfig*)RallocWithDBName:(NSString *)DBP;
@end
