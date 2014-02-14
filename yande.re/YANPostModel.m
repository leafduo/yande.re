//
//  YANPostModel.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostModel.h"
#import <ReactiveCocoa.h>
#import "YANHTTPSessionManager.h"

static const NSUInteger kPostPerRequest = 32;

@implementation YANPostModel

- (RACSignal *)loadData {
    return [RACSubject createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[YANHTTPSessionManager sharedManager] GET:@"/post.json"
                                        parameters:@{@"limit": @(kPostPerRequest)}
                                           success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                                               [subscriber sendNext:responseObject];
                                               [subscriber sendCompleted];                                               
                                           }
                                           failure:^(NSURLSessionDataTask *task, NSError *error) {
                                               [subscriber sendError:error];
                                           }];
        return nil;
    }];
}

@end
