//
//  FFDownloadHandle.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFDownloadItem.h"

typedef void(^downloadResultBlock)(FFDownloadItem *response);

@interface FFDownloadHandle : NSObject

- (void)configDownloadResultBlock:(void(^)(FFDownloadItem *response))downloadResultBlock;

- (void)startDownload:(NSString *)identify downloadUrl:(NSString *)downloadUrl;
- (void)pauseDownload:(NSString *)identify;
- (void)resumeDownload:(NSString *)identify;
- (void)cancleDownload:(NSString *)identify;

@end
