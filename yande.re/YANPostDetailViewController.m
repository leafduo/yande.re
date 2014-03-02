//
//  YANPostDetailViewController.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostDetailViewController.h"
#import "YANPost.h"
#import "YANPostDetailInfoViewController.h"
#import <MDRadialProgressView.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressLabel.h>

@interface YANPostDetailViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *infoViewControllerContainerView;
@property (nonatomic, strong)
    YANPostDetailInfoViewController *infoViewController;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) MDRadialProgressView *progressView;

@property (nonatomic, strong) IBOutlet UISwipeGestureRecognizer *dismissGesture;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *zoomingGesture;
@property (nonatomic, strong)
    IBOutlet UILongPressGestureRecognizer *moreActionGesture;
@property (nonatomic, strong)
    IBOutlet UITapGestureRecognizer *triggerInfoGesture;

@property (nonatomic, strong) NSMutableArray *imageConstraits;

@end

@implementation YANPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _imageConstraits = [[NSMutableArray alloc] init];

    @weakify(self);

    [RACObserve(self.imageView, image) subscribeNext:^(UIImage *image) {
        @strongify(self);
        self.scrollView.maximumZoomScale = 1;
        self.scrollView.minimumZoomScale = ({
            CGSize imageSize = [self.imageView intrinsicContentSize];
            1. / MAX(imageSize.width /
                    CGRectGetWidth(self.scrollView.bounds),
                imageSize.height /
                    CGRectGetHeight(self.scrollView.bounds));
        });
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
        [self recalculateImageViewConstraits];
    }];

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
    [self.view addSubview:self.progressView];

    [[self.dismissGesture rac_gestureSignal]
        subscribeNext:^(UISwipeGestureRecognizer *gesture) {
            @strongify(self);
            [self.presentingViewController dismissViewControllerAnimated:YES
                                                              completion:nil];
        }];

    [[self.zoomingGesture rac_gestureSignal] subscribeNext:^(id x) {
        @strongify(self);
        if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
            CGPoint tapLocation =
                [self.zoomingGesture locationInView:self.imageView];
            [self.scrollView
                zoomToRect:CGRectMake(tapLocation.x, tapLocation.y, 0, 0)
                  animated:YES];
        } else {
            [self.scrollView setZoomScale:self.scrollView.minimumZoomScale
                                 animated:YES];
        }
    }];

    [[self.triggerInfoGesture rac_gestureSignal]
        subscribeNext:^(id x) {
            @strongify(self);
            [self triggerInfoViewController];
        }];
    [self.triggerInfoGesture
        requireGestureRecognizerToFail:self.zoomingGesture];

    [[self.moreActionGesture rac_gestureSignal]
        subscribeNext:^(UIPanGestureRecognizer *recognizer) {
            @strongify(self);
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                [self showMoreActionSheet:nil];
            }
        }];

    [RACObserve(self, post) subscribeNext:^(YANPost *post) {
        @strongify(self);
        [self loadImageWithURL:self.post.sampleURL
                placeholderURL:self.post.previewURL];
    }];

    [[RACObserve(self, infoViewController) take:1] subscribeNext:^(id x) {
        @strongify(self);
        [self triggerInfoViewController];
    }];

    [self.infoViewController.resolutionChanged
        subscribeNext:^(NSNumber *resolution) {
            @strongify(self);
            switch ([resolution unsignedIntegerValue]) {
            case YANPostImageResolutionJEPG:
                [self loadImageWithURL:self.post.jpegURL
                        placeholderURL:self.post.sampleURL];
                break;

            default:
                break;
            }
        }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedInfoViewController"]) {
        self.infoViewController = segue.destinationViewController;
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.infoViewControllerContainerView.hidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSMutableArray *)imageConstraits {
    if (!_imageConstraits) {
        _imageConstraits = [[NSMutableArray alloc] init];
    }

    return _imageConstraits;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self recalculateImageViewConstraits];
}

- (void)recalculateImageViewConstraits {
    for (NSLayoutConstraint *constraint in self.imageConstraits) {
        [self.scrollView removeConstraint:constraint];
    }
    [self.imageConstraits removeAllObjects];


    if (CGRectGetHeight(self.imageView.frame) < CGRectGetHeight(self.scrollView.frame)) {
        [self.imageConstraits addObject:
         [NSLayoutConstraint constraintWithItem:self.imageView
                                      attribute:NSLayoutAttributeCenterY
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.scrollView
                                      attribute:NSLayoutAttributeCenterY
                                     multiplier:1.0f
                                       constant:0]];
    } else {
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView);
        [self.imageConstraits addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }

    if (CGRectGetWidth(self.imageView.frame) < CGRectGetWidth(self.scrollView.frame)) {
        [self.imageConstraits addObject:
         [NSLayoutConstraint constraintWithItem:self.imageView
                                      attribute:NSLayoutAttributeCenterX
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:self.scrollView
                                      attribute:NSLayoutAttributeCenterX
                                     multiplier:1.0f
                                       constant:0]];
    } else {
        NSDictionary *views = NSDictionaryOfVariableBindings(_imageView);
        [self.imageConstraits addObjectsFromArray:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_imageView]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }

    [self.scrollView addConstraints:self.imageConstraits];
    [self.scrollView setNeedsUpdateConstraints];
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

- (void)triggerInfoViewController {
    if (self.infoViewControllerContainerView.hidden) {
        self.infoViewControllerContainerView.hidden = NO;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.infoViewControllerContainerView.alpha = 1;
                             [self setNeedsStatusBarAppearanceUpdate];
                         }];
    } else {
        self.infoViewControllerContainerView.hidden = YES;
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.infoViewControllerContainerView.alpha = 0;
                             [self setNeedsStatusBarAppearanceUpdate];
                         }];
    }
}

- (void)loadImageWithURL:(NSURL *)URL placeholderURL:(NSURL *)placeholderURL {
    [self.imageView setImageWithURL:placeholderURL];
    @weakify(self);
    self.progressView.hidden = NO;
    [self.imageView setImageWithURL:URL
        placeholderImage:self.imageView.image
        options:SDWebImageProgressiveDownload | SDWebImageRetryFailed
        progress:^(NSUInteger receivedSize, long long expectedSize) {
            @strongify(self);
            if (expectedSize == -1) {
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* MDRadialProgressView is suck.
                     * It can't handle large progress, because it draw
                     * each
                     * count as an arc.
                     */
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
}

@end
