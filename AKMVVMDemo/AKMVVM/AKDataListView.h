//
//  AKDataListView.h
//  AKMVVMDemo
//
//  Created by AKing on 16/5/31.
//  Copyright © 2016年 AKing. All rights reserved.
//

/**
整个逻辑如下：
 //1.AKDataListView提供调用请求数据的时间点，然后调用AKDataListViewModel的getData:该方法进行接口的请求，，
 //2.请求接口结束后，getData的success&fail回调到AKDataListView中的block实现，，
 //3.在AKDataListView中的success&fail实现中刷新tableView&collectionView（reloadData），，
 //4.调用reloadData刷新，AKDataListView的相应子类实现tableView&collectionView的代理方法，从而完成数据的展示，，
 
图示：
 AKDataListView —> AKDataListViewModel （AKDataListView 发起接口请求，AKDataListViewModel实现接口请求）
 
 AKDataListViewModel —> 其子类 （AKDataListViewModel的子类重写父类getData实现相应的接口请求）
 
 AKDataListViewModel子类 -> AKDataListView （AKDataListViewModel子类的getData方法在请求结束后回到block到AKDataListView的block实现中）
 
 AKDataListView -> 其子类 （在AKDataListView的block实现中，调用reloadData方法刷新tableView&collectionView；在AKDataListView的子类中实现代理方法展示数据）
 */

#import <UIKit/UIKit.h>

typedef  int(^DHDataBindFilterBlock)(NSArray *array, int pageOrOffset);
typedef void(^DHDataBindSuccessBlock)(NSArray *results, int page, DHDataBindFilterBlock filterBlock);
typedef void(^DHDataBindFailBlock)(NSError *error);
typedef void(^DHDataBindBlock)(NSInteger pageOrOffset, NSMutableArray *dataList, DHDataBindSuccessBlock success, DHDataBindFailBlock fail);
typedef void(^DHDataBindScrollBlock)(UIScrollView *scrollView, BOOL endDrag, BOOL endDecelerate);

typedef void(^DHNoParamBlock)();

@class AKDataListViewModel;

@interface AKDataListView : UIView<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//viewModel管理view相关配置及逻辑处理，，
@property (strong, nonatomic) AKDataListViewModel              *viewModel;
//是否正在loading数据，，
@property (assign, nonatomic) BOOL                             loading;
//以tableView显示数据（默认）
@property (strong, nonatomic) UITableView                      *tableView;
//以collectionView显示数据。。
@property (strong, nonatomic) UICollectionView                 *collectionView;

//绑定数据model
- (void)bindViewModel:(AKDataListViewModel *)viewModel;

//view将要出现，进行数据请求的一个时间点，，
- (void)viewWillAppear;

- (void)viewWillDisappear;


//加载数据。如果有数据则只刷新表，如果没有数据则加载请求数据，，
- (void)reloadData;
//先加载数据，如果有数据则只刷新；如果没数据则加载请求数据，然后再执行block，，
- (void)reloadDataBeforeExecuteBlock:(DHNoParamBlock)block;
//先执行block，然后加载数据。如果有数据则只刷新表，如果没有数据则加载请求数据，，
- (void)reloadDataAfterExecuteBlock:(CommonBlock)block;
//无论有无数据，都加载请求数据，，
- (void)forceReloadData;

//不支持自动加载下一页时手动加载，，
- (void)loadNextData;

//滑动到顶端
- (void)scrollToTop;

//注册cell（子类（以collectionView展示数据时）要实现该方法）
- (void)registCollectionCell;

@end
