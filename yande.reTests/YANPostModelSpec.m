//
//  YANPostModelSpec.m
//  yande.re
//
//  Created by Zuyang Kou on 2/23/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostModel.h"
#import "YANPost.h"

SpecBegin(YANPostModel)

static YANPostModel *model;

describe(@"YANPostModel", ^{
    beforeEach(^{
        model = [[YANPostModel alloc] init];
    });

    it(@"should load posts", ^AsyncBlock {
        [[model loadMoreData] subscribeNext:^(YANPost *post) {
            expect(model.postArray).toNot.beEmpty();
            done();
        }];
    });

    it(@"should have no duplicated posts when load more twice", ^AsyncBlock {
        [[model loadMoreData] subscribeCompleted:^{
            [[model refreshData] subscribeCompleted:^() {
                expect([[[model.postArray rac_sequence] filter:^BOOL(YANPost *post) {
                    return post.objectID == [(YANPost *)[model.postArray firstObject] objectID];
                }] array]).to.haveCountOf(1);
                done();
            }];
        }];
    });

    // How to solve this?
    pending(@"should have no duplicated posts when load more and refresh", ^AsyncBlock {
        RACSignal *loadMoreSignal = [model loadMoreData];
        RACSignal *refreshSignal = [model refreshData];
        [[RACSignal combineLatest:@[loadMoreSignal, refreshSignal]] subscribeCompleted:^{
            expect([[[model.postArray rac_sequence] filter:^BOOL(YANPost *post) {
                return post.objectID == [(YANPost *)[model.postArray firstObject] objectID];
            }] array]).to.haveCountOf(1);
            done();
        }];
    });
});

SpecEnd