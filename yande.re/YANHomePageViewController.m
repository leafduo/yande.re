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
#import "YANPostDetailCollectionViewController.h"
#import <CHTCollectionViewWaterfallLayout.h>
#import <SDWebImagePrefetcher.h>

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
    [self.refreshControl addTarget:self
                            action:@selector(refershControlAction:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];

    CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        layout.columnCount = 2;
    } else {
        layout.columnCount = 1;
    }
    layout.minimumColumnSpacing = 2;
    layout.minimumInteritemSpacing = 2;

    [self refreshData:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.collectionView reloadData];

    if (self.postModel.activePostIndex < [self.collectionView numberOfItemsInSection:0]) {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.postModel.activePostIndex inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionNone
                                        animated:YES];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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
        [self prefetchImages];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (IBAction)loadMoreData:(id)sender {
    if (self.postModel.loading) {
        return;
    }

    [[self.postModel loadMoreData] subscribeCompleted:^{
        [self prefetchImages];
        [self.collectionView reloadData];
    }];
}

- (void)prefetchImages {
    NSArray *URLs = [[self.postModel.postArray.rac_sequence map:^NSURL *(YANPost *post) {
        return post.sampleURL;
    }] array];
    [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:URLs];
}

- (IBAction)refershControlAction:(id)sender {
    [self refreshData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.postModel.postArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YANPhotoPreviewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell"
                                                  forIndexPath:indexPath];
    cell.post = self.postModel.postArray[indexPath.item];
    return cell;
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

#pragma segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        YANPostDetailCollectionViewController *controller = segue.destinationViewController;
        self.postModel.activePostIndex = [(NSIndexPath *)[[self.collectionView indexPathsForSelectedItems] firstObject] item];
        controller.postModel = self.postModel;
    }
}

@end
