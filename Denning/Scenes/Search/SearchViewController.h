//
//  ViewController.h
//  Denning
//
//  Created by DenningIT on 19/01/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MLPAutoCompleteTextField;

@interface SearchViewController : BaseViewController

@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *searchTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;

@property (nonatomic, strong) NSDictionary *generalSearchFilters;
@property (nonatomic, strong) NSDictionary *publicSearchFilters;
@property (weak, nonatomic) IBOutlet UIButton *searchTypeBtn;

@property (strong, nonatomic) NSMutableArray* searchResultArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchContainerConstraint;
@property (weak, nonatomic) IBOutlet UIView *searchContainerView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSNumber* page;

@end

