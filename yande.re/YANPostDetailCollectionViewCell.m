//
//  YANPostDetailCollectionViewCell.m
//  yande.re
//
//  Created by Zuyang Kou on 6/30/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostDetailCollectionViewCell.h"

@interface YANPostDetailCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation YANPostDetailCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPost:(YANPost *)post {
    _post = post;

    if (self.post) {
        [self.imageView sd_setImageWithURL:self.post.jpegURL
                          placeholderImage:nil
                                   options:SDWebImageRetryFailed | SDWebImageProgressiveDownload];
    }
}

@end
