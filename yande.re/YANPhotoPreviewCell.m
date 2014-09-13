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
@property (nonatomic, weak) IBOutlet UIViewController *viewController;
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
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                         message:nil
                                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
                @weakify(alertController);
                alertController.popoverPresentationController.sourceView = self;
                alertController.popoverPresentationController.sourceRect = self.bounds;
                [alertController addAction:[UIAlertAction actionWithTitle:@"Save Photo"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
                                                                      UIImage *image = self.imageView.image;
                                                                      UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
                                                                  }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction *action) {
                                                                      @strongify(alertController);
                                                                      [alertController dismissViewControllerAnimated:YES completion:nil];
                                                                  }]];
                [self.viewController presentViewController:alertController
                                                  animated:YES
                                                completion:nil];
            }
        }];
    }

    return _longPressGestureRecognizer;
}

@end
