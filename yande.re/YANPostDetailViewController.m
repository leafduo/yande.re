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

@interface YANPostDetailViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet MDRadialProgressView *progressView;

@end

@implementation YANPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
                                                      alpha:1.0];
        view.theme.completedColor = [UIColor colorWithRed:90 / 255.0
                                                    green:212 / 255.0
                                                     blue:39 / 255.0
                                                    alpha:1.0];
        view.progressCounter = 1;
        view.progressTotal = 100;
        view;
    });
    [self.imageView addSubview:self.progressView];

    UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];

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

- (void)setPost:(YANPost *)post {
    _post = post;
}

@end
