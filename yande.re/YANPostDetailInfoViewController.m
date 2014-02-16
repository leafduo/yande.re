//
//  YANPostDetailInfoViewController.m
//  yande.re
//
//  Created by Zuyang Kou on 2/17/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANPostDetailInfoViewController.h"
#import "YANPost.h"

@interface YANPostDetailInfoViewController ()

@property (nonatomic, strong) IBOutlet UIButton *resolutionSwitchButton;
@property (nonatomic, strong) RACSubject *resolutionChanged;

@end

@implementation YANPostDetailInfoViewController {
    YANPostImageResolution _imageResolution;
}

- (void)awakeFromNib {
    self.resolutionChanged = [RACSubject subject];
    _imageResolution = YANPostImageResolutionSample;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    [[self.resolutionSwitchButton
        rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(id x) {
            @strongify(self);
            switch (self->_imageResolution) {
            case YANPostImageResolutionSample:
                _imageResolution = YANPostImageResolutionJEPG;
                [self.resolutionSwitchButton setTitle:@"High Res"
                                             forState:UIControlStateNormal];
                self.resolutionSwitchButton.enabled = NO;
                [(RACSubject *)self->_resolutionChanged
                    sendNext:@(_imageResolution)];
                break;
            default:
                break;
            }
        }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
