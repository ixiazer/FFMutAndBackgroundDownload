//
//  FFFileManager.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFFileManager : NSObject

+ (NSString *)getFullFile:(NSString *)identifier;
+ (NSUInteger)getFileDataSize:(NSString *)identifier;

+ (NSString *)getDownloadSucPist;
+ (NSString *)getDownloadPist;

// 保存下载成功文件状态
+ (BOOL)saveDownloadSucFile:(NSString *)identifier downloadFileUrl:(NSString *)downloadFileUrl;
// 删除下载成功文件状态
+ (BOOL)removeDownloadSucFile:(NSString *)identifier;
// 是否创建下载成功记录
+ (BOOL)isHasDownloadSucFile:(NSString *)identifier;


// 创建下载文件状态
+ (BOOL)addNewDownloadFile:(NSString *)identifier downloadFileUrl:(NSString *)downloadFileUrl;
// 删除下载文件状态
+ (BOOL)removeDownloadFile:(NSString *)identifier;
// 是否创建下载记录
+ (BOOL)isHasDownloadFile:(NSString *)identifier;

@end
