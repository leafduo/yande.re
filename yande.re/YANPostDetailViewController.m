//
//  YANPostDetailViewController.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostDetailViewController.h"
#import "YANPost.h"

@interface YANPostDetailViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation YANPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [RACObserve(self.post, URL) subscribeNext:^(NSURL *URL) {
        [self.imageView setImageWithURL:URL
                       placeholderImage:nil
                                options:0
                               progress:^(NSUInteger receivedSize,
                                          long long expectedSize) {
                                   NSLog(@"receivedSize: %lu",
                                         (unsigned long)receivedSize);
                                   NSLog(@"expectedSize: %lld", expectedSize);
                               }
                              completed:nil];
    }];

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
