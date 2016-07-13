//
//  FFDownloadResponse.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, FFDownloadStatus) {
    FFDownloadBackgroudSuccuss = 1 << 0, // 下载成功
    FFDownloadFail = 1 << 1, // 下载失败
    
    FFDownloadStart = 1 << 2, // 开始下载
    FFDownloadIng = 1 << 3, // 下载中
    FFDownloadPause = 1 << 4, // 暂停下载
    FFDownloadResume = 1 << 5, // 重启下载
    FFDownloadCancle = 1 << 6 // 取消下载
};


@interface FFDownloadResponse : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, assign) FFDownloadStatus downloadStatus;

@property (nonatomic, assign) double hasDownloadLength;
@property (nonatomic, assign) double totalLength;

+ (FFDownloadResponse *)getDownloadRespose:(FFDownloadStatus)status identity:(NSString *)identity hasDownloadLength:(NSInteger)hasDownloadLength totalLength:(NSInteger)totalLength;


@end
