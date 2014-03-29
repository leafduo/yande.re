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
#import "YANPostDetailViewController.h"
#import <CHTCollectionViewWaterfallLayout.h>

@interface YANHomePageViewController () <CHTCollectionViewDelegateWaterfallLayout>

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) YANPostModel *postModel;

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

    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    layout.columnCount = 2;
    layout.minimumColumnSpacing = 2;
    layout.minimumInteritemSpacing = 2;

    [self refreshData:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (IBAction)refreshData:(id)sender {
    if (self.postModel.loading) {
        [self.refreshControl endRefreshing];
        return;
    }

    [self.refreshControl beginRefreshing];
    [[self.postModel refreshData] subscribeError:^(NSError *error) {
        [self.refreshControl endRefreshing];
    } completed:^{
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)loadMoreData:(id)sender {
    if (self.postModel.loading) {
        return;
    }

    [[self.postModel loadMoreData] subscribeCompleted:^{
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPostDetail"]) {
        YANPostDetailViewController *postDetailViewController =
            segue.destinationViewController;
        NSIndexPath *selectedIndex =
            [[self.collectionView indexPathsForSelectedItems] firstObject];
        YANPost *post = self.postModel.postArray[selectedIndex.item];
        postDetailViewController.post = post;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.postModel.postArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YANPhotoPreviewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"cell"
                                                  forIndexPath:indexPath];
    cell.post = self.postModel.postArray[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showPostDetail" sender:self];
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    YANPost *post = self.postModel.postArray[indexPath.item];
    return post.sampleSize;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (![_postModel.postArray count]) {
        return;
    }
    
    if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.frame) >
        scrollView.contentSize.height - 640) {
        [self loadMoreData:nil];
    }
}

@end
