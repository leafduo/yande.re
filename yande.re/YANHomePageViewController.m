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
#import "YANPostModel.h"

@interface YANHomePageViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) YANPostModel *postModel;

@end

@implementation YANHomePageViewController {
    NSArray *_imageURLArray;
}

- (void)awakeFromNib {
    self.postModel = [[YANPostModel alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refershControlAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    [self refresh:nil];
}

- (IBAction)refresh:(id)sender {
    [self.refreshControl beginRefreshing];
    [[self.postModel loadData] subscribeNext:^(id x) {
        _imageURLArray = [[[x rac_sequence] map:^NSURL *(NSDictionary *value) {
            return [NSURL URLWithString:value[@"preview_url"]];
        }] array];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    } error:^(NSError *error) {
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)refershControlAction:(id)sender {
    [self refresh:nil];
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
