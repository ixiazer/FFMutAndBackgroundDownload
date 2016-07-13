//
//  FFDownloadHandle.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFDownloadResponse.h"

typedef void(^downloadResultBlock)(FFDownloadResponse *response);

@interface FFDownloadHandle : NSObject

- (void)configDownloadResultBlock:(void(^)(FFDownloadResponse *response))downloadResultBlock;

- (void)startDownload:(NSString *)identify downloadUrl:(NSString *)downloadUrl;
- (void)pauseDownload:(NSString *)identify;
- (void)resumeDownload:(NSString *)identify;
- (void)cancleDownload:(NSString *)identify;

@end
