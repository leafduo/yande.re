//
//  YANPostDetailViewController.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostDetailViewController.h"
#import "YANPost.h"
#import <MDRadialProgressView.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressLabel.h>

@interface YANPostDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) MDRadialProgressView *progressView;

@property (nonatomic, strong) UITapGestureRecognizer *dismissGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *moreActionGesture;

@end

@implementation YANPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.scrollView.maximumZoomScale = ({
        CGFloat scale = [[UIScreen mainScreen] scale];
        MAX(self.post.sampleSize.width / scale /
                CGRectGetWidth(self.scrollView.bounds),
            self.post.sampleSize.height / scale /
                CGRectGetHeight(self.scrollView.bounds));
    });

    self.progressView = ({
        MDRadialProgressView *view = [[MDRadialProgressView alloc] init];
        view.frame = CGRectMake(0, 0, 80, 80);
        view.center = self.imageView.center;
        view.theme.thickness = 20;
        view.label.hidden = YES;
        view.theme.sliceDividerHidden = YES;
        view.theme.incompletedColor = [UIColor colorWithRed:164 / 255.0
                                                      green:231 / 255.0
                                                       blue:134 / 255.0
                                                      alpha:0.5];
        view.theme.completedColor = [UIColor colorWithRed:90 / 255.0
                                                    green:212 / 255.0
                                                     blue:39 / 255.0
                                                    alpha:0.7];
        view.progressCounter = 1;
        view.progressTotal = 100;
        view;
    });
    [self.imageView addSubview:self.progressView];

    self.dismissGesture = ({
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
        gesture.numberOfTapsRequired = 2;
        [[gesture rac_gestureSignal] subscribeNext:^(id x) {
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:nil];
        }];
        gesture;
    });
    [self.imageView addGestureRecognizer:self.dismissGesture];

    self.moreActionGesture = ({
        UILongPressGestureRecognizer *gesture =
            [[UILongPressGestureRecognizer alloc] init];
        [[gesture rac_gestureSignal]
            subscribeNext:^(UIPanGestureRecognizer *recognizer) {
                if (recognizer.state == UIGestureRecognizerStateBegan) {
                    [self showMoreActionSheet:nil];
                }
            }];
        gesture;
    });
    [self.imageView addGestureRecognizer:self.moreActionGesture];

    @weakify(self);
    [RACObserve(self, post) subscribeNext:^(YANPost *post) {
        @strongify(self);
        [self.imageView setImageWithURL:post.previewURL];
        [self.imageView setImageWithURL:post.sampleURL
            placeholderImage:self.imageView.image
            options:0
            progress:^(NSUInteger receivedSize, long long expectedSize) {
                @strongify(self);
                if (expectedSize == -1) {
                    return;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.progressView.progressTotal = 100;
                        self.progressView.progressCounter =
                            100 * receivedSize / expectedSize;
                    });
                }
            }
            completed:^(UIImage *image, NSError *error,
                        SDImageCacheType cacheType) {
                @strongify(self);
                self.progressView.hidden = YES;
            }];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication]
        setStatusBarHidden:YES
             withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property

- (void)setPost:(YANPost *)post {
    _post = post;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - Action
- (IBAction)showMoreActionSheet:(id)sender {
    UIActionSheet *actionSheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:nil
                           cancelButtonTitle:@"Cancel"
                      destructiveButtonTitle:nil
                           otherButtonTitles:@"Save Photo", nil];
    [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *idx) {
        if ([idx intValue] == [actionSheet firstOtherButtonIndex]) {
            [self savePhoto];
        }
    }];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)savePhoto {
    UIImage *image = self.imageView.image;
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
}

@end
