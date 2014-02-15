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
                        self.progressView.progressTotal = expectedSize;
                        self.progressView.progressCounter = receivedSize;
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
    self.progressView.frame = CGRectMake(0, 0, 40, 40);
    self.progressView.center = self.imageView.center;
    self.progressView.theme.thickness = 15;
    self.progressView.theme.incompletedColor = [UIColor clearColor];
    self.progressView.theme.completedColor = [UIColor orangeColor];
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
