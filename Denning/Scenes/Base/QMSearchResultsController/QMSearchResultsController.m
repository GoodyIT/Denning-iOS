//
//  QMSearchResultsController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/17/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchResultsController.h"

@interface QMSearchResultsController ()

@end

@implementation QMSearchResultsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    CGRect rect  = self.view.frame;
//    self.view.frame = CGRectMake(rect.origin.x, rect.origin.y  + 44, rect.size.width, rect.size.height);
}

//- (void) viewWillAppear:(BOOL)animated
//{
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 100, 0, 0);
//    [super viewWillAppear:animated];
//}
//
//- (void) viewWillDisappear:(BOOL)animated
//{
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    [super viewWillDisappear:animated];
//}

- (void)performSearch:(NSString *)searchText {
    
    [self.searchDataSource.searchDataProvider performSearch:searchText];
}

//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)__unused tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id obj = [self.searchDataSource objectAtIndexPath:indexPath];
    [self.delegate searchResultsController:self didSelectObject:obj];
}

//MARK: - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate searchResultsController:self willBeginScrollResults:scrollView];
}

//MARK: - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

//MARK: - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    if ([self.tableView.dataSource isKindOfClass:[QMSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)__unused data {
    
    if ([self.tableView.dataSource isKindOfClass:[QMSearchDataSource class]]
        && self.searchDataSource.searchDataProvider != searchDataProvider) {
        // search data provider is not visible right now
        // no need to reload current table view
        return;
    }
    
    [self.tableView reloadData];
}

@end
