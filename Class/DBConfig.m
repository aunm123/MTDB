//
//  DBConfig.m
//  MTDB
//
//  Created by Tim on 15/6/11.
//  Copyright (c) 2015年 Tim. All rights reserved.
//

#import "DBConfig.h"

static DBConfig *db=nil;
@implementation DBConfig
+(DBConfig*)shareQueue{
    return db;
}

+(DBConfig*)allocWithDBName:(NSString*)DBP{
    if (!db) {
        db=[[DBConfig alloc]init];
        
        db.DBName=[DBP lastPathComponent];
        db.baseQueue=[[FMDatabaseQueue alloc]initWithPath:DBP];
    }
    return db;
}

+(DBConfig*)RallocWithDBName:(NSString *)DBP{
    if (!db) {
        db=[[DBConfig alloc]init];
        
        db.DBName=[DBP lastPathComponent];
        db.baseQueue=[[FMDatabaseQueue alloc]initWithPath:DBP];
    }else{
        db.DBName=[DBP lastPathComponent];
        [db.baseQueue close];
        db.baseQueue=[[FMDatabaseQueue alloc]initWithPath:DBP];
    }
    return db;
}
@end
