//
//  YANPost.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPost.h"

@implementation YANPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"objectID": @"id",
             @"previewURL": @"preview_url"
             };
}

@end
