//
//  AKDataListView.h
//  AKMVVMDemo
//
//  Created by AKing on 16/5/31.
//  Copyright © 2016年 AKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKDataListView.h"

@interface AKDataListViewModel : NSObject

//以collectionView显示数据，默认是tableView
@property (nonatomic, assign) BOOL                       supportCollectionView;
//自定义collectionView的布局，，
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGSize                      collectionFooterSize;

//是否支持头部刷新
@property (nonatomic, assign) BOOL                       supportRefreshHeader;
//是否支持尾部自动刷新(当快滑动到底部时自动加载下一页数据)
@property (nonatomic, assign) BOOL                       supportAutoRefreshFooter;

//当显示view时需要强制刷新数据，置为YES
@property (nonatomic, assign) BOOL                       needForceReloadDataOnce;

//是否支持以page计算（请求数据方式：分页请求还是偏移量请求）
@property (nonatomic, assign) BOOL                       supportPage;
@property (nonatomic, assign) int                        page;
@property (nonatomic, assign) int                        pageSize;
@property (nonatomic, assign) int                        offset;
@property (nonatomic, assign) int                        offsetSize;

//section从resultlist取值（以section作为展示单元）
@property (nonatomic, assign) BOOL                        supportSectionDecideLast;
@property (nonatomic, assign) NSInteger                   collectionSectionNumber;

//数据绑定前调用
@property (nonatomic, copy) CommonBlock                  dataBindBeforeBlock;
//数据绑定后调用
@property (nonatomic, copy) CommonBlock                  dataBindAfterBlock;

//scroll滑动回调到外部，使外部获取滑动回调从而进行相应处理，，
@property (nonatomic, copy) DHDataBindScrollBlock        scrollBlock;

//请求接口返回的结果数据封装后的数据源数组
@property (nonatomic, strong) NSMutableArray             *resultList;

//子类中实现该方法，，
//1.AKDataListView提供调用该方法的时间点，AKDataListViewModel的子类实现该方法进行相应接口的请求，，
//2.请求接口结束后，success&fail回调到AKDataListView中的block实现，，
//3.在AKDataListView中的success&fail实现中刷新tableView&collectionView（reloadData），，
//4.调用reloadData刷新，AKDataListView的相应子类实现tableView&collectionView的代理方法，从而完成数据的展示，，
- (void)getData:(AKDataListView*)view
           page:(NSInteger)pageOrOffset
        results:(NSMutableArray *)dataList
        success:(DHDataBindSuccessBlock)success
           fail:(DHDataBindFailBlock)fail;

//返回值作为是否加载下一页的判断依据
- (BOOL)hasScrollToBottom:(NSIndexPath*)indexPath;

//子类中实现该方法
//CollectionView布局
- (void)dataListCollectionViewLayout;

@end
