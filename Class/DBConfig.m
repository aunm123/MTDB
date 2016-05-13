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
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        db=[[DBConfig alloc]init];
    });
    return db;
}

+(DBConfig*)allocWithDBName:(NSString*)DBP{
    DBConfig *tempDB = [DBConfig shareQueue];
    if (tempDB&&tempDB.baseQueue) {
        [tempDB.baseQueue close];
    }
    tempDB.DBName=[DBP lastPathComponent];
    tempDB.baseQueue=[[FMDatabaseQueue alloc]initWithPath:DBP];
    
    return tempDB;
}

+(NSArray*)AllTableNames:(FMDatabaseQueue*)qu{
    
    NSString *sqlstr = @"select name from sqlite_master where type='table' order by name;";
    
    NSMutableArray *valueArray=[[NSMutableArray alloc]init];
    [qu inDatabase:^(FMDatabase *db) {
        FMResultSet *set=nil;
        
        set=[db executeQuery:sqlstr];
        if (set) {
            while (set.next) {
                if (set.columnCount>=1) {
                    [valueArray addObject:[set objectForColumnIndex:0]];
                }
            }
            [set close];
        }
    }];
    return valueArray;
}

+(DBConfig*)updataOldDB:(NSString*)olddb NewDB:(NSString*)newdb{
    FMDatabaseQueue *oldD = [[FMDatabaseQueue alloc]initWithPath:olddb];
    FMDatabaseQueue *newD = [[FMDatabaseQueue alloc]initWithPath:newdb];
    
    NSArray *oldTables = [DBConfig AllTableNames:oldD];
    NSArray *newTables = [DBConfig AllTableNames:newD];
    
    NSArray *needUpdata = [DBConfig needWithAr1:oldTables Ar2:newTables];
    
    for (NSString *table_name in needUpdata) {
        [DBConfig shareQueue].baseQueue = oldD;
        
        MTDBModel *old_db = [MTDBModel GetTabele:table_name];
        NSArray *ar = [old_db selectAND:nil page:0];
        
        if (ar.count>0) {
            [DBConfig shareQueue].baseQueue = newD;
            
            MTDBModel *new_db = [MTDBModel GetTabele:table_name];
            [new_db saveWithArray:ar];
        }
    }
    [oldD close];
    [newD close];
    
    [DBConfig shareQueue].baseQueue = nil;
    
    NSFileManager *fm=[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:olddb]) {
        [fm removeItemAtPath:olddb error:nil];
        NSError *error;
        [fm copyItemAtPath:newdb toPath:olddb error:&error];
    }
    //删除临时数据库
    [fm removeItemAtPath:newdb error:nil];
}

+(NSArray*)needWithAr1:(NSArray*)array1 Ar2:(NSArray*)array2{
    NSMutableArray *needUpdata = [[NSMutableArray alloc]init];
    for (NSString *oldT in array1) {
        for (NSString *newT in array2) {
            if ([oldT isEqualToString:newT]) {
                [needUpdata addObject:oldT];
                break;
            }
        }
    }
    return [NSArray arrayWithArray:needUpdata];
}

@end
