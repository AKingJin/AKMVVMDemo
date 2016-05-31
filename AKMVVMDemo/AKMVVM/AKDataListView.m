//
//  AKDataListView.m
//  AKMVVMDemo
//
//  Created by AKing on 16/5/31.
//  Copyright © 2016年 AKing. All rights reserved.
//

#import "AKDataListView.h"
#import "AKDataListViewModel.h"
#import "MJRefresh.h"
#import "UIDevice-Reachability.h"
#import "DHFooterLoadingView.h"

@interface AKDataListView ()

@property (nonatomic, strong) DHFooterLoadingView                *footerLoadingView;
@property (nonatomic, strong) DHFooterLoadingView                *cFooterLoadingView;
@property (nonatomic, assign) BOOL                               isFooterRefreshLoading;
@property (nonatomic, copy)   CommonBlock                        afterReloadDataBlock;
@property (nonatomic, copy) DHNoParamBlock                       afterReloadDataExecuteBlock;

@property (nonatomic, copy) DHDataBindSuccessBlock               dataBindSuccessBlock;
@property (nonatomic, copy) DHDataBindFailBlock                  dataBindFailBlock;

@end

@implementation AKDataListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //默认以tableView展示数据，，
        [self loadListTableView];
    }
    
    return self;
}

#pragma mark - extern

//绑定数据model，（主要是根据viewModel的相关设置加载view）
- (void)bindViewModel:(AKDataListViewModel *)viewModel
{
    self.viewModel = viewModel;
    [self layoutDataListView];
    [self layoutRefreshHeader];
}

//view将要出现，进行数据请求的一个时间点，，
- (void)viewWillAppear
{
    [self dataListView].scrollsToTop = YES;
    
    //强制请求数据刷新，，
    if (self.viewModel.needForceReloadDataOnce) {
        self.viewModel.needForceReloadDataOnce = NO;
        [self forceReloadData];
        return;
    }
    
    [self reloadData];
}

- (void)viewWillDisappear
{
    [self dataListView].scrollsToTop = NO;
}

//加载数据。如果有数据则只刷新表，如果没有数据则加载请求数据，，
- (void)reloadData
{
    if (self.viewModel.resultList.count > 0) {
        [self refreshDataWhenDelay:0.2f];
    } else {
        [self loadFirstData];
    }

}

//先加载数据，如果有数据则只刷新；如果没数据则加载请求数据，然后再执行block，，
- (void)reloadDataBeforeExecuteBlock:(DHNoParamBlock)block
{
    self.afterReloadDataExecuteBlock = block;
}

//先执行block，然后加载数据。如果有数据则只刷新表，如果没有数据则加载请求数据，，
- (void)reloadDataAfterExecuteBlock:(CommonBlock)block
{
    if (block) {
        block(self.viewModel.resultList);
    }
    
    [self reloadData];
}

//无论有无数据，都加载请求数据，，
- (void)forceReloadData;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.viewModel.resultList removeAllObjects];
    [self removeFooterLoadingViewAfterReloadDataBlock:^(id response) {
        self.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
        self.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
    }];
    [self refreshDataWhenDelay:0];
    
    
    BOOL reach = [UIDevice networkAvailable];
    if (reach) {
        
        [self loadFirstData];
        
    }else{
        
    }

}

//不支持自动加载下一页时手动加载，，
- (void)loadNextData
{
    if (![UIDevice networkAvailable]) {
        [[self dataListView] headerEndRefreshing];
        [self removeFooterLoadingViewAfterReloadDataBlock:^(id response) {
            self.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
            self.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
        }];
        return;
    }
    
    if (self.viewModel.supportRefreshHeader && [[self dataListView] isHeaderRefreshing]) {
        [[self dataListView] headerEndRefreshing];
        return;
    }
    
    
    if (self.isFooterRefreshLoading){
        return;
    }
    
    self.isFooterRefreshLoading = YES;
    
    if (self.viewModel.supportPage) {
        [self loadDataWithIndex:self.viewModel.page+1];
    }else{
        [self loadDataWithIndex:self.viewModel.offset];
    }
}

//滑动到顶端
- (void)scrollToTop
{
    [[self dataListView] scrollsToTop];
}

//注册cell（子类（以collectionView展示数据时）要实现该方法）
- (void)registCollectionCell
{
    
}


#pragma mark - View

-(void)layoutRefreshHeader
{
    //根据viewModel.supportRefreshHeader的配置决定是否加载头部刷新，，
    if (self.viewModel.supportRefreshHeader) {
        [self loadHeaderRefreshView];
    }else{
        [self removeHeaderRefreshView];
    }
}

-(void)layoutDataListView
{
    //根据supportCollectionView的配置决定以什么方式展示数据，，
    if (self.viewModel.supportCollectionView) {
        [self.tableView removeFromSuperview];
        [self loadListCollectionView];
    }else{
        [self.collectionView removeFromSuperview];
        [self loadListTableView];
    }
}

- (void)loadListTableView
{
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //        self.tableView.backgroundColor =
        self.tableView.scrollsToTop = NO;
        [self addSubview:self.tableView];
    }
}

- (void)loadListCollectionView
{
    if (!self.collectionView) {
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                 collectionViewLayout:self.viewModel.flowLayout];
        //        self.collectionView.backgroundColor =
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.alwaysBounceVertical  =YES;
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[DHFooterLoadingView class]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:@"DHFooterLoadingView"];
        [self registCollectionCell];
    }
}


- (void)loadHeaderRefreshView
{
    [[self dataListView] addHeaderWithTarget:self action:@selector(loadFirstData)];
}


- (void)removeHeaderRefreshView
{
    [[self dataListView] removeHeader];
}


- (void)loadFooterLoadingView
{
    if (!self.viewModel.supportAutoRefreshFooter) {
        return;
    }
    
    if (self.viewModel.supportCollectionView) {
        if (!self.cFooterLoadingView) {
            self.cFooterLoadingView = [[DHFooterLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.width, DHFooterLoadingHeight)];
        }
        self.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeLoad;
        self.cFooterLoadingView.height = DHFooterLoadingHeight;
        [self.cFooterLoadingView startAnimating];
        self.viewModel.collectionFooterSize = CGSizeMake(self.width, DHFooterLoadingHeight);
        
    }else{
        
        if (!self.footerLoadingView) {
            self.footerLoadingView = [[DHFooterLoadingView alloc] initWithFrame:CGRectMake(0, 0, self.width, DHFooterLoadingHeight)];
        }
        
        if (self.tableView.tableFooterView.height < 10) {
            self.tableView.tableFooterView = self.footerLoadingView;
        }
        
        self.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeLoad;
        [self.footerLoadingView startAnimating];
    }
    
}


- (void)removeFooterLoadingViewAfterReloadDataBlock:(CommonBlock)completeReloadData
{
    if (!self.viewModel.supportAutoRefreshFooter) {
        return;
    }
    
    self.afterReloadDataBlock = completeReloadData;
    
    if (self.viewModel.supportCollectionView) {
        self.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeRemove;
        self.cFooterLoadingView.height = 0;
        self.viewModel.collectionFooterSize = CGSizeZero;
        [self.cFooterLoadingView stopAnimating];
    }else{
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
        self.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeRemove;
        [self.footerLoadingView stopAnimating];
    }
}


- (UIScrollView*)dataListView
{
    if (self.viewModel.supportCollectionView) {
        return self.collectionView;
    }
    
    return self.tableView;
}


#pragma mark - Data

- (void)loadFirstData
{
    if (self.viewModel.supportRefreshHeader && [[self dataListView] isHeaderRefreshing]) {
        [[self dataListView] headerEndRefreshing];
        return;
    }
    
    if (self.isFooterRefreshLoading) {
        [[self dataListView] headerEndRefreshing];
        return;
    }
    
    if (![UIDevice networkAvailable]) {
        [[self dataListView] headerEndRefreshing];
        [self removeFooterLoadingViewAfterReloadDataBlock:^(id response) {
            self.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
            self.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
        }];
        [self refreshDataWhenDelay:0];
        
        return;
    }
    
    if (self.viewModel.supportPage) {
        [self loadDataWithIndex:1];
    }else{
        [self loadDataWithIndex:0];
    }

}


//关键方法，，
- (void)loadDataWithIndex:(int)aPage
{
    __weak typeof(self) weakSelf = self;;
    
    if (!self.dataBindSuccessBlock){
        //在viewModel子类中请求接口获取数据后回调该block，，
        self.dataBindSuccessBlock = ^(NSArray *results, int pageOrOffset, DHDataBindFilterBlock filterBlock){
            
            if (weakSelf.viewModel.supportPage) {
                
                if (pageOrOffset == 1){
                    [weakSelf.viewModel.resultList removeAllObjects];
                    
                    //只在第一页请求时，调用before
                    if (weakSelf.viewModel.dataBindBeforeBlock) {
                        weakSelf.viewModel.dataBindBeforeBlock(weakSelf.viewModel.resultList);
                    }
                }
                
            }else{
                
                if (pageOrOffset == 0){
                    [weakSelf.viewModel.resultList removeAllObjects];
                    
                    //只在第一页请求时，调用before
                    if (weakSelf.viewModel.dataBindBeforeBlock) {
                        weakSelf.viewModel.dataBindBeforeBlock(weakSelf.viewModel.resultList);
                    }
                }
            }
            
            
            if (weakSelf.viewModel.supportPage) {
                weakSelf.viewModel.page = pageOrOffset;
            }else{
                weakSelf.viewModel.offset = pageOrOffset;
            }
            
            
            if (results.count > 0){

                //header刷新处理，，
                [[weakSelf dataListView] headerEndRefreshing];
                //footer刷新处理,,下一次开始请求时状态（reloadData表刷新下一次请求时footer状态）
                weakSelf.isFooterRefreshLoading = NO;
                [weakSelf loadFooterLoadingView];//1）collection 设置footer size viewModel.collectionFooterSize
                
                [weakSelf.viewModel.resultList addObjectsFromArray:results];//2) collection 获取布局的数据
                
                if (!weakSelf.viewModel.supportPage && filterBlock) {
                    weakSelf.viewModel.offset = filterBlock(results, weakSelf.viewModel.offset);
                }
                
                [weakSelf refreshDataWhenDelay:0];//3）collection 调用dataListCollectionViewLayout进行布局
                
                //结束整个加载，，
                weakSelf.loading = NO;
            
                
            }else{
                
                //header刷新处理，，
                [[weakSelf dataListView] headerEndRefreshing];
                //footer刷新处理，，下一次开始请求时状态（reloadData表刷新下一次请求时footer状态）
                weakSelf.isFooterRefreshLoading = NO;
                [weakSelf removeFooterLoadingViewAfterReloadDataBlock:nil];//已无数据
                
                [weakSelf refreshDataWhenDelay:0];
                
                //结束整个加载，，
                weakSelf.loading = NO;
                
                //显示ErrorPage，，
//                if (weakSelf.viewModel.resultList.count == 0) {
//                    [weakSelf performSelector:@selector(showErrorPageWithType:) withObject:[NSNumber numberWithInteger:weakSelf.viewModel.noDataErrorPageType] afterDelay:0.2];
//                    weakSelf.isShowFirstLoading = YES;
//                }
            }
            
            
            if (weakSelf.viewModel.dataBindAfterBlock) {
                weakSelf.viewModel.dataBindAfterBlock(weakSelf.viewModel.resultList);
            }
        };
    }
    
    
    if (!self.dataBindFailBlock){
        self.dataBindFailBlock = ^(NSError* error){
            
            //header刷新处理，，
            [[weakSelf dataListView] headerEndRefreshing];
            //footer刷新处理
            weakSelf.isFooterRefreshLoading = NO;
            [weakSelf removeFooterLoadingViewAfterReloadDataBlock:^(id response) {
                weakSelf.cFooterLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
                weakSelf.footerLoadingView.footerLoadingViewType = DHFooterLoadingViewTypeReload;
            }];
            
            [weakSelf refreshDataWhenDelay:0];
            
            //结束整个加载，，
            weakSelf.loading = NO;
            
            //显示ErrorPage，，
//            if (weakSelf.viewModel.resultList.count == 0){
//                [weakSelf performSelector:@selector(showErrorPageWithType:) withObject:[NSNumber numberWithInteger:weakSelf.viewModel.requestErrorPageType] afterDelay:0.2];
//                weakSelf.isShowFirstLoading = YES;
//            }else {//只有动画提示
//                if (weakSelf.viewModel.showRequestErrorAnimation) {
//                    CGRect rect = [[weakSelf dataListView] convertRect:[weakSelf dataListView].bounds toView:WINDOW];
//                    [DHPromptView showPromptAnimationWithTop:rect.origin.y errorType:weakSelf.viewModel.requestErrorPageType];
//                }
//            }
        };
    }
    
    
    if (self.viewModel){
        self.loading = YES;
        NSMutableArray *listArray = [NSMutableArray arrayWithArray:self.viewModel.resultList];
        if (self.viewModel.supportPage) {//第一页数据在请求结束且成功时才清除
            if (aPage == 1) {
                [listArray removeAllObjects];
            }
        }else {
            if (aPage == 0) {
                [listArray removeAllObjects];
            }
        }
        [self.viewModel getData:self
                           page:aPage
                        results:listArray
                        success:self.dataBindSuccessBlock
                           fail:self.dataBindFailBlock];
    }
    
}


- (void)refreshDataWhenDelay:(CGFloat)delay
{
    if (self.viewModel.supportCollectionView) {
        [self.viewModel dataListCollectionViewLayout];
    }
    
    [self setDataListViewForbidScroll:NO];
    
    [[self dataListView] performSelector:@selector(reloadData) withObject:nil afterDelay:delay];
    [self performSelector:@selector(performAfterReloadDataBlock) withObject:nil afterDelay:delay + 0.1f];
    
    if (self.afterReloadDataExecuteBlock ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((delay + 0.0f) * NSEC_PER_SEC)), dispatch_get_main_queue(), self.afterReloadDataExecuteBlock);
    }
    
    self.afterReloadDataExecuteBlock = nil;
    
}


- (void)performAfterReloadDataBlock
{
    if (self.afterReloadDataBlock) {
        self.afterReloadDataBlock(nil);
    }
    
}

#pragma mark - config

- (void)setDataListViewForbidScroll:(BOOL)forbid
{
    [[self dataListView] setScrollEnabled:!forbid];
}

#pragma mark - UITableViewDelegate



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.viewModel.supportAutoRefreshFooter) {
        return;
    }
    
    //如果总数量少于则不加载下一页，直接移除footer，，已无数据
    if (self.viewModel.supportPage) {
        if (self.viewModel.resultList.count <= self.viewModel.pageSize) {
            [self removeFooterLoadingViewAfterReloadDataBlock:nil];
        }
    }else {
        if (self.viewModel.resultList.count <= self.viewModel.offsetSize) {
            [self removeFooterLoadingViewAfterReloadDataBlock:nil];
        }
    }
    
    
    //自动加载下一页逻辑
    if ([self.viewModel hasScrollToBottom:indexPath]) {
        if (self.viewModel.resultList.count > 0)  {
            if (!self.footerLoadingView) {
                [self loadFooterLoadingView];
            }
            
            [self.footerLoadingView startAnimating];
        } else  {
            [self.footerLoadingView stopAnimating];
        }
        
        if (!self.isFooterRefreshLoading &&
            !self.loading &&
            tableView.tableFooterView.height > 10 &&
            self.viewModel.resultList.count > 0) {
            [self loadNextData];
            
        }else if (self.footerLoadingView.footerLoadingViewType == DHFooterLoadingViewTypeReload &&
                  !self.isFooterRefreshLoading) {
            [self loadFooterLoadingView];
            [self loadNextData];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.viewModel.resultList.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}


//具体子类实现，，
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark -
#pragma mark - UICollectionViewDelegate


-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.viewModel.supportAutoRefreshFooter) {
        return;
    }
    
    //如果总数量少于等于，则不加载下一页，直接移除footer,,已无数据
    if (self.viewModel.supportPage) {
        if (self.viewModel.resultList.count <= self.viewModel.pageSize) {
            [self removeFooterLoadingViewAfterReloadDataBlock:nil];
        }
    }else {
        if (self.viewModel.resultList.count <= self.viewModel.offsetSize) {
            [self removeFooterLoadingViewAfterReloadDataBlock:nil];
        }
    }
    //自动加载下一页逻辑
    if ([self.viewModel hasScrollToBottom:indexPath])  {
        if (self.viewModel.resultList.count > 0) {
            if (!self.cFooterLoadingView) {
                [self loadFooterLoadingView];
            }
            [self.cFooterLoadingView startAnimating];
        }else {
            [self.cFooterLoadingView stopAnimating];
        }
        
        
        if (!self.isFooterRefreshLoading &&
            !CGSizeEqualToSize(CGSizeZero, self.viewModel.collectionFooterSize) &&
            !self.loading &&
            self.viewModel.resultList.count > 0) {
            [self loadNextData];
            
        }else if (self.cFooterLoadingView.footerLoadingViewType == DHFooterLoadingViewTypeReload &&
                  !self.isFooterRefreshLoading) {
            [self loadFooterLoadingView];
            [self loadNextData];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.resultList.count;
}

//具体子类实现
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.viewModel.collectionSectionNumber - 1) return nil;
    
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        DHFooterLoadingView *footerV = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"DHFooterLoadingView" forIndexPath:indexPath];
        reusableview = footerV;
        if (self.cFooterLoadingView.footerLoadingViewType == DHFooterLoadingViewTypeLoad) {
            [footerV startAnimating];
        }else {
            [footerV stopAnimating];
        }
        self.cFooterLoadingView = footerV;
    }
    
    return reusableview;
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section < self.viewModel.collectionSectionNumber - 1) return CGSizeZero;
    
    return self.viewModel.collectionFooterSize;
}


#pragma mark -
#pragma mark - UIScrollViewDelegate

//回调到外部进行具体响应处理，，，
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.viewModel.scrollBlock) {
        self.viewModel.scrollBlock(scrollView, NO, NO);
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.viewModel.scrollBlock) {
        self.viewModel.scrollBlock(scrollView, NO, YES);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.viewModel.scrollBlock) {
        self.viewModel.scrollBlock(scrollView, YES, NO);
    }
}




















@end
