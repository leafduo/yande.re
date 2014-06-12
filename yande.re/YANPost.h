//
//  YANPost.h
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

@import UIKit;
#import <Mantle/Mantle.h>

typedef NS_ENUM(NSUInteger, YANPostImageResolution) {
    YANPostImageResolutionPreview,
    YANPostImageResolutionSample,
    YANPostImageResolutionJEPG,
    YANPostImageResolutionOriginal
};

@interface YANPost : MTLModel <MTLJSONSerializing>

@property (nonatomic, readonly) NSUInteger objectID;
@property (nonatomic, readonly) NSURL *previewURL;
@property (nonatomic, readonly) CGSize previewSize;
@property (nonatomic, readonly) NSURL *sampleURL;
@property (nonatomic, readonly) CGSize sampleSize;
@property (nonatomic, readonly) NSURL *jpegURL;
@property (nonatomic, readonly) CGSize jpegSize;

- (CGSize)sizeForResolution:(YANPostImageResolution)resolution;

@end
