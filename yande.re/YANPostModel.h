//
//  YANPostModel.h
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface YANPostModel : NSObject

@property (nonatomic, readonly) NSArray *postArray;

- (RACSignal *)loadMoreData;
- (RACSignal *)refreshData;

@end
