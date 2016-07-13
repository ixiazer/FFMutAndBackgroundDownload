//
//  FFDownloadResponse.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDownloadResponse.h"

@implementation FFDownloadResponse

+ (FFDownloadResponse *)getDownloadRespose:(FFDownloadStatus)status identity:(NSString *)identity hasDownloadLength:(NSInteger)hasDownloadLength totalLength:(NSInteger)totalLength {
    FFDownloadResponse *response = [[FFDownloadResponse alloc] init];
    response.identifier = identity;
    response.downloadStatus = status;
    response.hasDownloadLength = hasDownloadLength;
    response.totalLength = totalLength;
    
    return response;
};


@end
