//
//  YANURLSessionManager.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANHTTPSessionManager.h"

@implementation YANHTTPSessionManager

static YANHTTPSessionManager *_sharedManager;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseURL = [[NSURL alloc] initWithString:@"https://yande.re/"];
        _sharedManager = [[YANHTTPSessionManager alloc] initWithBaseURL:baseURL];
    });
    return _sharedManager;
}

@end
