//
//  YANPost.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPost.h"
#import <libextobjc/extobjc.h>

@interface YANPost ()

@property (nonatomic, assign) CGFloat sampleWidth;
@property (nonatomic, assign) CGFloat sampleHeight;
@property (nonatomic, assign) CGFloat jpegWidth;
@property (nonatomic, assign) CGFloat jpegHeight;
@property (nonatomic, assign) CGFloat previewHeight;
@property (nonatomic, assign) CGFloat previewWidth;

@end

@implementation YANPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @keypath(YANPost.new, objectID): @"id",
        @keypath(YANPost.new, previewURL): @"preview_url",
        @keypath(YANPost.new, sampleURL): @"sample_url",
        @keypath(YANPost.new, sampleWidth): @"sample_width",
        @keypath(YANPost.new, sampleHeight): @"sample_height",
        @keypath(YANPost.new, jpegURL): @"jpeg_url",
        @keypath(YANPost.new, jpegWidth): @"jpeg_width",
        @keypath(YANPost.new, jpegHeight): @"jpeg_height",
        @keypath(YANPost.new, previewHeight): @"preview_height",
        @keypath(YANPost.new, previewWidth): @"preview_width"
    };
}

- (CGSize)sizeForResolution:(YANPostImageResolution)resolution {
    switch (resolution) {
    case YANPostImageResolutionSample:
        return self.sampleSize;
        break;
    case YANPostImageResolutionJEPG:
        return self.jpegSize;
        break;

    default:
        return CGSizeZero;
        break;
    }
}

+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {
    if ([key rangeOfString:@"URL"].location != NSNotFound) {
        return [NSValueTransformer
            valueTransformerForName:MTLURLValueTransformerName];
    }

    return nil;
}

- (CGSize)sampleSize {
    return CGSizeMake(self.sampleWidth, self.sampleHeight);
}

- (CGSize)jpegSize {
    return CGSizeMake(self.jpegWidth, self.jpegHeight);
}

- (CGSize)previewSize {
    return CGSizeMake(self.previewWidth, self.previewHeight);
}

@end
