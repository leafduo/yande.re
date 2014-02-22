//
//  YANPostModel.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostModel.h"
#import "YANHTTPSessionManager.h"
#import "YANPost.h"

@interface YANPostModel ()

@property (nonatomic, strong) NSArray *postArray;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

@end

static const NSUInteger kPostPerRequest = 32;

@implementation YANPostModel

- (id)init {
    self = [super init];
    if (self) {
        _page = 0;
        self.postArray = [NSArray array];
    }
    return self;
}

- (RACSignal *)loadMoreDataReset:(BOOL)reset {
    NSAssert(!self.loading, @"We accept one request at a time");
    self.loading = YES;

    return [RACSubject createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        NSDictionary *params = @{
                                 @"limit": @(kPostPerRequest),
                                 @"page": @(reset ? 1 : self.page + 1)
                                };
        NSURLSessionDataTask *dataTask = [[YANHTTPSessionManager sharedManager] GET:@"/post.json"
            parameters:params
            success:^(NSURLSessionDataTask *task, NSArray *responseArray) {
                self.loading = NO;

                if (reset) {
                    [self clearLocalData];
                }

                ++self.page;
                for (NSDictionary *dict in responseArray) {
                    YANPost *post = [MTLJSONAdapter modelOfClass:[YANPost class] fromJSONDictionary:dict error:nil];
                    self.postArray = [self.postArray arrayByAddingObject:post];
                    [subscriber sendNext:post];
                }
                [subscriber sendCompleted];
            }
            failure:^(NSURLSessionDataTask *task, NSError *error) {
                self.loading = NO;
                [subscriber sendError:error];
            }];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

- (RACSignal *)loadMoreData {
    return [self loadMoreDataReset:NO];
}

- (RACSignal *)refreshData {
    return [self loadMoreDataReset:YES];
}

- (void)clearLocalData {
    self.page = 0;
    self.postArray = [NSArray array];
}

@end
