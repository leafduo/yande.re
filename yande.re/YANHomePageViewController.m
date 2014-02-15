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
#import "YANPost.h"

@interface YANHomePageViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) YANPostModel *postModel;
@property (nonatomic, assign) BOOL loadingData;

@end

@implementation YANHomePageViewController

- (void)awakeFromNib {
    self.postModel = [[YANPostModel alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refershControlAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];

    [self refreshData:nil];
}

- (IBAction)refreshData:(id)sender {
    [self.refreshControl beginRefreshing];
    [[self.postModel refreshData] subscribeError:^(NSError *error) {
        self.loadingData = NO;
        [self.refreshControl endRefreshing];
    }
        completed:^{
            self.loadingData = NO;
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
        }];
}

- (IBAction)loadMoreData:(id)sender {
    if (self.loadingData) {
        return;
    }
    self.loadingData = YES;

    [[self.postModel loadMoreData] subscribeCompleted:^{
        self.loadingData = NO;
        [self.collectionView reloadData];
    }];
}

- (IBAction)refershControlAction:(id)sender {
    [self refreshData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.postModel.postArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YANPhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    YANPost *post = self.postModel.postArray[indexPath.row];
    [cell.imageView setImageWithURL:post.previewURL];
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height - 60) {
        [self loadMoreData:nil];
    }
}

@end
