//
//  FFDownloadItem.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFDownloadItem : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *downloadUrl;
@property (nonatomic, strong) NSString *willSaveUrl;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

// 显示数据部分
@property (nonatomic, strong) NSString *downloadTaskName;
@end
