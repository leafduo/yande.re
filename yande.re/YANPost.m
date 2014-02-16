//
//  YANPost.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPost.h"

@interface YANPost ()

@property (nonatomic, assign) CGFloat sampleWidth;
@property (nonatomic, assign) CGFloat sampleHeight;
@property (nonatomic, assign) CGFloat jpegWidth;
@property (nonatomic, assign) CGFloat jpegHeight;

@end

@implementation YANPost

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"objectID": @"id",
        @"previewURL": @"preview_url",
        @"URL": @"jpeg_url",
        @"sampleURL": @"sample_url",
        @"sampleWidth": @"sample_width",
        @"sampleHeight": @"sample_height",
        @"jpegURL": @"jpeg_url",
        @"jpegWidth": @"jpeg_width",
        @"jpegHeight": @"jpeg_height",
    };
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

- (void)setSampleSize:(CGSize)sampleSize {
    self.sampleWidth = sampleSize.width;
    self.sampleHeight = sampleSize.height;
}

- (CGSize)jpegSize {
    return CGSizeMake(self.jpegWidth, self.jpegHeight);
}

- (void)setJpegSize:(CGSize)jpegSize {
    self.jpegWidth = jpegSize.width;
    self.jpegHeight = jpegSize.height;
}

@end
