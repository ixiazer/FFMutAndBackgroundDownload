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

- (void)startDownload:(NSString *)identifier downloadUrl:(NSString *)downloadUrl;
- (void)pauseDownload:(NSString *)identifier;
- (void)resumeDownload:(NSString *)identifier;
- (void)cancleDownload:(NSString *)identifier;

@end
