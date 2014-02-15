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

    @weakify(self);
    [RACObserve(self.post, URL) subscribeNext:^(NSURL *URL) {
        @strongify(self);
        [self.imageView setImageWithURL:URL
            placeholderImage:nil
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

    self.progressView = [[MDRadialProgressView alloc] init];
    self.progressView.frame = CGRectMake(0, 0, 80, 80);
    self.progressView.center = self.imageView.center;
    self.progressView.theme.thickness = 20;
    self.progressView.label.hidden = YES;
    self.progressView.theme.sliceDividerHidden = YES;
    self.progressView.theme.incompletedColor = [UIColor colorWithRed:164 / 255.0
                                                               green:231 / 255.0
                                                                blue:134 / 255.0
                                                               alpha:1.0];
    self.progressView.theme.completedColor = [UIColor colorWithRed:90 / 255.0
                                                             green:212 / 255.0
                                                              blue:39 / 255.0
                                                             alpha:1.0];
    self.progressView.progressCounter = 1;
    self.progressView.progressTotal = 100;
    [self.imageView addSubview:self.progressView];

    UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] init];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [[tapGestureRecognizer rac_gestureSignal] subscribeNext:^(id x) {
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                          completion:nil];
    }];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
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
