//
//  MTDBModel.m
//  MTDB
//
//  Created by Tim on 15/6/11.
//  Copyright (c) 2015年 Tim. All rights reserved.
//

#import "MTDBModel.h"

@interface MTDBModel (){
    NSString *limitStr;
}
@end

@implementation MTDBModel
+(MTDBModel*)GetTabele:(NSString*)TBNAME{
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    MTDBModel *mo=[MTDBModel new];
    mo.ase=YES;
    mo.tableName=TBNAME;
    [base inDatabase:^(FMDatabase *db) {
        NSString *keysql=[NSString stringWithFormat:@"pragma table_info ('%@')",TBNAME];
        FMResultSet *keyset=[db executeQuery:keysql];
        NSMutableArray *tempArray=[[NSMutableArray alloc]init];
        while (keyset.next) {
            NSString *name=[keyset stringForColumn:@"name"];
            [tempArray addObject:name];
            
            int pk=[keyset intForColumn:@"pk"];
            if (pk) {
                mo.indexKey=name;
            }
        }
        [keyset close];
        mo.keys=[NSArray arrayWithArray:tempArray];
        mo.pageSize=15;
        [mo setLimit:15];
    }];
    return mo;
}

#pragma mark - 业务

-(NSMutableArray*)selectAND:(NSDictionary*)dic page:(NSInteger)p{
    BOOL hasSC=NO;
    for (NSString *key in self.keys) {
        if ([key isEqualToString:@"sc"]) {
            hasSC=YES;
            break ;
        }
    }
    if (hasSC) {
        return [self selectANDdic:dic ORdic:nil Page:p PageSize:self.pageSize OrderBy:@{@"sc":@"asc"}];
        
    }else{
        return [self selectANDdic:dic ORdic:nil Page:p PageSize:self.pageSize OrderBy:nil];
    }
}

-(NSMutableArray*)selectOR:(NSDictionary*)dic page:(NSInteger)p{
    return [self selectANDdic:nil ORdic:dic Page:p PageSize:self.pageSize OrderBy:nil];
}

-(NSMutableArray*)selectAND:(NSDictionary*)dic page:(NSInteger)p orderBy:(NSDictionary*)orderDic{
    return [self selectANDdic:dic ORdic:nil Page:p PageSize:self.pageSize OrderBy:orderDic];
}

-(NSDictionary*)selectSingle:(NSDictionary*)dic{
    if (!dic) {
        return nil;
    }
    NSMutableArray *array = [self selectAND:dic page:-1];
    if (array.count>0) {
        NSDictionary *result=[NSDictionary dictionaryWithDictionary:[array objectAtIndex:0]];
        return result;
    }else{
        return nil;
    }
}

-(NSMutableArray*)selectANDdic:(NSDictionary*)andDic ORdic:(NSDictionary*)orDic Page:(NSInteger)p PageSize:(NSInteger)ps OrderBy:(NSDictionary*)orderDic{
    [self setLimit:ps];
    
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    NSMutableArray *valueArray=[[NSMutableArray alloc]init];
    [base inDatabase:^(FMDatabase *db) {
        FMResultSet *set=nil;
        NSString *sql=nil;
        
        NSString *andStr=nil;
        NSString *orStr=nil;
        if (andDic) {
            andStr=[self SplicingDic:andDic Format:@" %@ = '%@' AND" LastWord:3];
        }
        if (orDic) {
            orStr=[self SplicingDic:orDic Format:@" %@ = '%@' OR" LastWord:2];
        }
        
        NSString *whereStr=@"";
        if (andStr||orDic) {
            if (andStr&&orDic) {
                whereStr=[NSString stringWithFormat:@" where %@ OR %@",andStr,orDic];
            }else if (andStr){
                whereStr=[NSString stringWithFormat:@" where %@",andStr];
            }else if (orDic){
                whereStr=[NSString stringWithFormat:@" where %@",orDic];
            }
        }
        
        NSString *orderByStr=@"";
        if (orderDic) {
            NSString *order=[self SplicingDic:orderDic Format:@" [%@] %@ ," LastWord:1];
            orderByStr=[NSString stringWithFormat:@" ORDER BY %@",order];
        }
        
        sql=[NSString stringWithFormat:@"select * from `%@` %@ %@",self.tableName,whereStr,orderByStr];
        
        if (p>=0) {
            NSString *temp=[limitStr stringByReplacingOccurrencesOfString:@"page" withString:[NSString stringWithFormat:@" %d ",(int)p]];
            sql=[sql stringByAppendingString:temp];
        }
        set=[db executeQuery:sql];
        if (set) {
            while (set.next) {
                NSMutableDictionary *teDic=[[NSMutableDictionary alloc]init];
                for (int i=0;i<set.columnCount;i++) {
                    id temp = [set objectForColumnIndex:i];
                    NSString *rea = [NSString stringWithFormat:@"%@",temp];
                    [teDic setObject:rea forKey:[set columnNameForIndex:i]];
                }
                [valueArray addObject:teDic];
            }
            [set close];
        }
    }];
    
    return valueArray;
}

-(NSMutableArray*)selectWhere:(NSString*)str OrderBy:(NSDictionary*)orderDic{
    NSString *orderByStr=@"";
    if (orderDic) {
        NSString *order=[self SplicingDic:orderDic Format:@" [%@] %@ ," LastWord:1];
        orderByStr=[NSString stringWithFormat:@" ORDER BY %@",order];
    }

    NSString *sql;
    if (str) {
        sql=[NSString stringWithFormat:@"select * from `%@` where %@ %@",self.tableName,str,orderByStr];
    }else{
        sql=[NSString stringWithFormat:@"select * from `%@` %@",self.tableName,orderByStr];
    }
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    NSMutableArray *valueArray=[[NSMutableArray alloc]init];
    
    [base inDatabase:^(FMDatabase *db) {
        FMResultSet *set=nil;
        set=[db executeQuery:sql];
        if (set) {
            while (set.next) {
                NSMutableDictionary *teDic=[[NSMutableDictionary alloc]init];
                for (int i=0;i<set.columnCount;i++) {
                    [teDic setObject:[set objectForColumnIndex:i] forKey:[set columnNameForIndex:i]];
                }
                [valueArray addObject:teDic];
            }
            [set close];
        }
    }];
    return valueArray;
}

-(BOOL)save:(NSDictionary*)dic{
    if (!dic) {
        return NO;
    }
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    __block BOOL isFinish=NO;
    [base inDatabase:^(FMDatabase *db) {
        FMResultSet *set=nil;
        NSString *dataPK=[dic objectForKey:self.indexKey];
        BOOL updata=NO;
        if (dataPK) {
            NSString *selectID=[NSString stringWithFormat:@"select * from %@ where %@ = '%@' ",self.tableName,self.indexKey,dataPK];
            set=[db executeQuery:selectID];
            while ([set next]) {
                updata=YES;
            }
            [set close];
        }else{
            updata=NO;
        }
        
        if (updata) {
            NSString *str=[self SplicingDic:dic Format:@" [%@] = '%@' ," LastWord:1];
            if (!str) {
                str=@"";
            }
            if ([self checkhasTime:dic]) {
                str =[str stringByAppendingString:@", 'time' = (datetime('now','localtime')) "];
            }
            NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = '%@'",self.tableName,str,self.indexKey,dataPK];
            isFinish = [db executeUpdate:sql];
        }else{
            NSString *vs=@"";
            NSString *ks=@"";
            for (int i=0;i<dic.count;i++) {
                NSString *key=dic.allKeys[i];
                NSString *value=dic[key];
                if (![self isContent:key]) {
                    continue;
                }
                ks=[ks stringByAppendingFormat:@"'%@' ,",key];
                vs=[vs stringByAppendingFormat:@"'%@' ,",value];
            }
            if (ks.length>0) {
                ks=[ks substringToIndex:ks.length-1];
                vs=[vs substringToIndex:vs.length-1];
            }
            NSString *sql=[NSString stringWithFormat:@"INSERT INTO '%@' (%@) VALUES (%@)",self.tableName,ks,vs];
            isFinish = [db executeUpdate:sql];
        }
    }];
    return isFinish;
}

-(BOOL)deleteWithDic:(NSDictionary*)dic{
    if (!dic) {
        return NO;
    }
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    __block BOOL isFinish=NO;
    [base inDatabase:^(FMDatabase *db) {
        NSString *str=[self SplicingDic:dic Format:@" %@ = '%@' AND" LastWord:3];
        if (!str) {
            str=@"";
        }
        
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ ",self.tableName,str];
        isFinish = [db executeUpdate:sql];
    }];
    return isFinish;
}

#pragma mark  - 设置属性

-(BOOL)isContent:(NSString*)k{
    for (NSString *ke in self.keys) {
        if ([ke isEqualToString:k]) {
            return YES;
        }
    }
    return NO;
}

-(void)setLimit:(NSInteger)PageSize{
    limitStr=[NSString stringWithFormat:@" limit page,%d",(int)PageSize];
}

-(void)cleanUp{
    FMDatabaseQueue *base=[DBConfig shareQueue].baseQueue;
    [base inDatabase:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@",self.tableName];
        [db executeUpdate:sql];
    }];
}

#pragma mark  - 公用方法
-(BOOL)checkhasTime:(NSDictionary*)dic{
    
    for (NSString *str in dic.allKeys) {
        if ([str isEqualToString:@"time"]) {
            return NO;
        }
    }
    
    for (NSString *str in self.keys) {
        if ([str isEqualToString:@"time"]) {
            return YES;
        }
    }
    return NO;
}

+(NSDictionary*)checkSearchDic:(NSArray*)keys needCheckDic:(NSDictionary*)dic{
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc]init];
    for (NSString *keyName in keys) {
        for (NSString *tempkeyName in [dic allKeys]) {
            if ([keyName isEqualToString:tempkeyName]) {
                [tempDic setValue:dic[tempkeyName] forKey:tempkeyName];
                break;
            }
        }
    }
    if (tempDic.count==0) {
        return nil;
    }else{
        return [NSDictionary dictionaryWithDictionary:tempDic];
    }
}

-(NSString*)SplicingDic:(NSDictionary*)dic Format:(NSString*)format LastWord:(NSInteger)size{
    NSDictionary *trueDic=[MTDBModel checkSearchDic:self.keys needCheckDic:dic];
    NSString *string=nil;
    if (trueDic) {
        NSArray *trueKeys=trueDic.allKeys;
        for (int i=0; i<trueDic.count; i++) {
            NSString *TK=trueKeys[i];
            if (!string) {
                string=@"";
            }
            if (![trueDic[TK] isKindOfClass:[NSNull class]]) {
                string=[string stringByAppendingFormat:format,TK,
                        trueDic[TK]];
            }
        }
        if (string) {
            string=[string substringToIndex:string.length-size];
        }
    }
    return string ;
}

@end
