//
//  YANHomePageViewController.m
//  yande.re
//
//  Created by Zuyang Kou on 2/15/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "YANHomePageViewController.h"
#import "YANHTTPSessionManager.h"
#import "YANPhotoPreviewCell.h"
#import <ReactiveCocoa.h>
#import <UIImageView+WebCache.h>

@interface YANHomePageViewController ()

@end

@implementation YANHomePageViewController {
    NSArray *_imageURLArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[YANHTTPSessionManager sharedManager] GET:@"/post.json"
                                    parameters:@{@"limit": @32}
                                       success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
                                           _imageURLArray = [[[responseObject rac_sequence] map:^NSURL *(NSDictionary *value) {
                                               return [NSURL URLWithString:value[@"preview_url"]];
                                           }] array];
                                           [self.collectionView reloadData];
                                       }
                                       failure:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_imageURLArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YANPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell.imageView setImageWithURL:_imageURLArray[indexPath.row]];
    return cell;
}

@end
