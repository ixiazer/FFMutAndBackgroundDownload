//
//  FFDownloadItem.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDownloadItem.h"

@implementation FFDownloadItem


#pragma mark - coder method
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self=[super init]) {
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
        self.downloadUrl = [aDecoder decodeObjectForKey:@"downloadUrl"];
        self.willSaveUrl = [aDecoder decodeObjectForKey:@"willSaveUrl"];
        self.downloadTaskName = [aDecoder decodeObjectForKey:@"downloadTaskName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.downloadUrl forKey:@"downloadUrl"];
    [aCoder encodeObject:self.willSaveUrl forKey:@"willSaveUrl"];
    [aCoder encodeObject:self.downloadTaskName forKey:@"downloadTaskName"];
}

+ (FFDownloadItem *)getDownloadRespose:(FFDownloadStatus)status identity:(NSString *)identity hasDownloadLength:(NSInteger)hasDownloadLength totalLength:(NSInteger)totalLength {
    FFDownloadItem *response = [[FFDownloadItem alloc] init];
    response.identifier = identity;
    response.downloadStatus = status;
    response.hasDownloadLength = hasDownloadLength;
    response.totalLength = totalLength;
    
    return response;
};


@end
