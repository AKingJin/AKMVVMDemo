//
//  AKDataListView.m
//  AKMVVMDemo
//
//  Created by AKing on 16/5/31.
//  Copyright © 2016年 AKing. All rights reserved.
//

#import "AKDataListViewModel.h"

@implementation AKDataListViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.resultList = [[NSMutableArray alloc] init];
        _page = 0;
        _offset = 0;
        _pageSize = 1;//默认服务器返回每页数据数10,用于判断值小一些
        _offsetSize = 1;//默认服务器返回数据偏移量21,用于判断值小一些
        _supportAutoRefreshFooter = YES;
//        _requestErrorPageType = DHErrorTypeRefreshUnableLoadResults;
//        _noDataErrorPageType = DHErrorPageTypeNoData;
//        _showErrorPage = YES;
//        _forbidScrollWhenShowErrorPage = YES;
//        _showRequestErrorAnimation = YES;
//        _showFirstLoadingAnimation = YES;
        _collectionSectionNumber = 1;
        self.flowLayout= [[UICollectionViewFlowLayout alloc]init];
//        self.collectionFooterSize = CGSizeZero;
    }
    return self;
}

//子类中实现该方法
- (void)getData:(AKDataListView*)view
           page:(NSInteger)pageOrOffset
        results:(NSMutableArray *)dataList
        success:(DHDataBindSuccessBlock)success
           fail:(DHDataBindFailBlock)fail
{
    
}

- (BOOL)hasScrollToBottom:(NSIndexPath*)indexPath
{
    if (self.supportSectionDecideLast) {
        if (indexPath.section >= self.resultList.count - 1){
            return YES;
        }
        
    }else{
        if (indexPath.row >= self.resultList.count - 1) {
            return YES;
        }
    }
    return NO;
}

//子类中实现该方法
- (void)dataListCollectionViewLayout
{
    
}

@end
