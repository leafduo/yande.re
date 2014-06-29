//
//  YANPhotoPreviewCell.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPhotoPreviewCell.h"
#import "YANPost.h"
#import <SDWebImageManager.h>

@interface YANPhotoPreviewCell ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation YANPhotoPreviewCell

- (void)setPost:(YANPost *)post {
    _post = post;

    if ([[SDWebImageManager sharedManager]
            diskImageExistsForURL:_post.sampleURL]) {
        [self.imageView sd_setImageWithURL:_post.sampleURL
                       placeholderImage:nil
                                options:SDWebImageRetryFailed];
    } else {
        [self.imageView sd_setImageWithURL:_post.previewURL
                       placeholderImage:nil
                                options:SDWebImageRetryFailed];
    }
}

@end
