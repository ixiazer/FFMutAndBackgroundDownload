//
//  FFFileManager.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFFileManager.h"

@implementation FFFileManager

+ (NSString *)getFullFile:(NSString *)identifier {
    NSString *parentFile = [FFFileManager getDownloadCacheFilePath];
    NSString *childFile = [NSString stringWithFormat:@"%@/%@",parentFile,identifier];
    
    return childFile;
}

+ (NSString *)getDownloadCacheFilePath {
    NSString *parentFile = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"XZDownloadCache/"]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:parentFile]) {
        [fileManager createDirectoryAtPath:parentFile withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return parentFile;
}

+ (NSUInteger)getFileDataSize:(NSString *)identifier {
    NSString *childFile = [FFFileManager getFullFile:identifier];
    
    NSData *data = [NSData dataWithContentsOfFile:childFile];
    return data ? data.length : 0;
}

+ (NSString *)getDownloadSucPist {
    NSString *parentFile = [FFFileManager getDownloadCacheFilePath];
    NSString *sucFile = [NSString stringWithFormat:@"%@/XZDownloadSuc.plist",parentFile];
    
    return sucFile;
}

+ (NSString *)getDownloadPist {
    NSString *parentFile = [FFFileManager getDownloadCacheFilePath];
    NSString *sucFile = [NSString stringWithFormat:@"%@/XZDownload.plist",parentFile];
    
    return sucFile;
}

+ (BOOL)saveModelDataToPlist:(id)data {
    if (!data) {
        return NO;
    }
    
    NSString *plistString = [self getDownloadPist];
    
    if ([FFFileManager isExistWithFileName:plistString]) {
        [FFFileManager deleteFile:plistString];
    }
    
    if ([data isKindOfClass:[NSArray class]]) {
        NSArray *arr = (NSArray *)data;
        [NSKeyedArchiver archiveRootObject:arr toFile:plistString];
    }
    
    return YES;
}

+ (NSArray *)getPlistModelData {
    NSString *plistString = [self getDownloadPist];
    
    NSArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:plistString];
    
    return data;
}

+ (BOOL)isExistWithFileName:(NSString *)fileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
}

+ (BOOL)deleteFile:(NSString *)fileName {
    if (![self isExistWithFileName:fileName]) {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] removeItemAtPath:fileName error:&error]) {
        return NO;
    }
    
    return YES;
}


// 是否创建下载记录
+ (BOOL)isHasDownloadFile:(NSString *)identifier {
    NSDictionary *plistDic = [[NSDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadPist]];
    
    if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
        NSArray *downloadRecordArr = [NSArray arrayWithArray:plistDic[@"downloadRecord"]];
        for (NSDictionary *dic in downloadRecordArr) {
            if (dic[@"identifier"] && [dic[@"identifier"] isEqualToString:identifier]) {
                return YES;
            }
        }
    }
    
    return NO;
}

// 创建下载文件状态
+ (BOOL)addNewDownloadFile:(NSString *)identifier downloadFileUrl:(NSString *)downloadFileUrl {
    NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadPist]];
    
    NSMutableArray *downloadRecordArr = [NSMutableArray new];
    if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
        downloadRecordArr = [NSMutableArray arrayWithArray:plistDic[@"downloadRecord"]];
    } else {
        plistDic = [NSMutableDictionary new];
    }
    
    NSDictionary *willAddDic = [NSDictionary dictionaryWithObjectsAndKeys:identifier,@"identifier",downloadFileUrl,@"downloadFileUrl", nil];
    [downloadRecordArr addObject:willAddDic];
    [plistDic setValue:downloadRecordArr forKey:@"downloadRecord"];
    
    [plistDic writeToFile:[FFFileManager getDownloadPist] atomically:YES];
    
    return YES;
}

// 删除下载文件状态
+ (BOOL)removeDownloadFile:(NSString *)identifier {
    NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadPist]];
    
    if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *downloadRecordArr = [NSMutableArray arrayWithArray:plistDic[@"downloadRecord"]];
        for (NSDictionary *dic in downloadRecordArr) {
            if (dic[@"identifier"] && [dic[@"identifier"] isEqualToString:identifier]) {
                [downloadRecordArr removeObject:dic];
                
                [plistDic setValue:downloadRecordArr forKey:@"downloadRecord"];
                
                return YES;
            }
        }
    }
    
    return NO;
}

// 是否创建下载成功记录
+ (BOOL)isHasDownloadSucFile:(NSString *)identifier {
    NSDictionary *plistDic = [[NSDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadSucPist]];
    
    if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
        NSArray *downloadRecordArr = [NSArray arrayWithArray:plistDic[@"downloadRecord"]];
        for (NSDictionary *dic in downloadRecordArr) {
            if (dic[@"identifier"] && [dic[@"identifier"] isEqualToString:identifier]) {
                return YES;
            }
        }
    }
    
    return NO;
}


// 保存下载成功文件状态
+ (BOOL)saveDownloadSucFile:(NSString *)identifier downloadFileUrl:(NSString *)downloadFileUrl {
    if ([FFFileManager isHasDownloadSucFile:identifier]) {
        return YES;
    } else {
        NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadSucPist]];
        
        NSMutableArray *downloadRecordArr = [NSMutableArray new];
        if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
            downloadRecordArr = [NSMutableArray arrayWithArray:plistDic[@"downloadRecord"]];
        } else {
            plistDic = [NSMutableDictionary new];
        }
        
        NSDictionary *willAddDic = [NSDictionary dictionaryWithObjectsAndKeys:identifier,@"identifier",downloadFileUrl,@"downloadFileUrl", nil];
        [downloadRecordArr addObject:willAddDic];
        [plistDic setValue:downloadRecordArr forKey:@"downloadRecord"];
        
        [plistDic writeToFile:[FFFileManager getDownloadPist] atomically:YES];
        
        return YES;
    }
}

// 删除下载成功文件状态
+ (BOOL)removeDownloadSucFile:(NSString *)identifier {
    NSMutableDictionary *plistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[FFFileManager getDownloadSucPist]];
    
    if (plistDic && plistDic[@"downloadRecord"] && [plistDic[@"downloadRecord"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *downloadRecordArr = [NSMutableArray arrayWithArray:plistDic[@"downloadRecord"]];
        for (NSDictionary *dic in downloadRecordArr) {
            if (dic[@"identifier"] && [dic[@"identifier"] isEqualToString:identifier]) {
                [downloadRecordArr removeObject:dic];
                
                [plistDic setValue:downloadRecordArr forKey:@"downloadRecord"];
                
                return YES;
            }
        }
    }
    
    return YES;
}

@end
