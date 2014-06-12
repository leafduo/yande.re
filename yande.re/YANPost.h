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

@property (nonatomic, assign) NSUInteger objectID;
@property (nonatomic, strong) NSURL *previewURL;
@property (nonatomic, strong) NSURL *sampleURL;
@property (nonatomic, assign) CGSize sampleSize;
@property (nonatomic, strong) NSURL *jpegURL;
@property (nonatomic, assign) CGSize jpegSize;
@property (nonatomic, strong) NSURL *URL;

- (CGSize)sizeForResolution:(YANPostImageResolution)resolution;

@end
