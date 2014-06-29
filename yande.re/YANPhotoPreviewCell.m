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

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation YANPhotoPreviewCell

@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;

- (void)awakeFromNib {
    [super awakeFromNib];

    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)setPost:(YANPost *)post {
    _post = post;

    [self.imageView sd_setImageWithURL:_post.sampleURL
                      placeholderImage:nil
                               options:SDWebImageRetryFailed | SDWebImageProgressiveDownload];
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
        @weakify(self);
        [[_longPressGestureRecognizer rac_gestureSignal] subscribeNext:^(UILongPressGestureRecognizer *recognizer) {
            @strongify(self);
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:nil
                                                                cancelButtonTitle:@"Cancel"
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:@"Save Photo", nil];
                [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *idx) {
                    @strongify(self);
                    if ([idx intValue] == [actionSheet firstOtherButtonIndex]) {
                        UIImage *image = self.imageView.image;
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
                    }
                }];
                [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            }
        }];
    }

    return _longPressGestureRecognizer;
}

@end
