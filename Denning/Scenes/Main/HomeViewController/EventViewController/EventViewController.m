//
//  EventViewController.m
//  Denning
//
//  Created by DenningIT on 15/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EventViewController.h"
#import "EventCell.h"
#import <GLCalendarView.h>
#import <GLDateUtils.h>
#import "CalendarRangeView.h"
#import "EditCourtDiaryViewController.h"

@interface EventViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
{
    NSString* currentTopFilter, *currentBottomFilter;
    NSString* curYear, *curMonth;
    __block BOOL isLoading;
    NSString* startDate, *endDate;
}
@property (weak, nonatomic) IBOutlet UIView *calendarView;

@property (strong  , nonatomic) FSCalendar *calendar;
@property (strong, nonatomic) NSMutableArray<NSString *> *datesWithEvent;

@property (strong, nonatomic) NSDateFormatter *dateFormatter2;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray* eventsArray;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventSummaryLabel;

@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *thisWeekBtn;
@property (weak, nonatomic) IBOutlet UIButton *futureBtn;
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;

@property (strong, nonatomic) IBOutlet UIButton* allBtn;
@property (strong, nonatomic) IBOutlet UIButton* courtBtn;
@property (strong, nonatomic) IBOutlet UIButton* officeBtn;
@property (strong, nonatomic) IBOutlet UIButton* personalBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabbarIndicatorLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLeading;
@property (strong, nonatomic) EventModel* latestEvent;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (copy, nonatomic) NSString *search;

@property (strong, nonatomic) NSArray* topFilters;
@property (strong, nonatomic) NSArray* bottomFilters;

@property (strong, nonatomic) NSNumber* page;
@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self prepareUI];
    [self configureCalendar];
    [self setupTopBottomFilters];
    [self getMonthlySummaryWithCompletion:nil];
    [self registerNibs];
//    [self configureSearch];
    [self presetDateRange];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupTopBottomFilters {
    self.topFilters = @[@"Today", @"This Week", @"Future", @"Previous"];
    self.bottomFilters = @[@"1court", @"2office", @"3personal", @"0All"];
    currentTopFilter = self.topFilters[0];
    currentBottomFilter = self.bottomFilters[0];
}

- (void) presetDateRange {
    NSDate *today = [NSDate date];
    
    NSDate *beginDate1 = today;
    NSDate *endDate1 = [GLDateUtils dateByAddingDays:6 toDate:today];
    self.currentRange = [GLCalendarDateRange rangeWithBeginDate:beginDate1 endDate:endDate1];
    self.currentRange.backgroundColor = [UIColor colorWithHexString:@"79a9cd"];
    self.currentRange.editable = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void) configureCalendar
{
    _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, self.calendarView.frame.size.width, self.calendarView.frame.size.height)];
    _calendar.dataSource = self;
    _calendar.delegate = self;
    //  calendar.allowsMultipleSelection = YES;
    _calendar.swipeToChooseGesture.enabled = YES;
    _calendar.backgroundColor = [UIColor whiteColor];
    _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    [self.calendarView addSubview:_calendar];
}

- (void) prepareUI
{
    self.page = @(2);
    _search = @"";
    self.eventsArray = self.originalArray;
    startDate = [DIHelpers today];
    endDate = [DIHelpers today];
    curYear = [DIHelpers currentYear];
    curMonth = [DIHelpers currentMonth];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.calendar.accessibilityIdentifier = @"calendar";
    self.dateFormatter2 = [[NSDateFormatter alloc] init];
    self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
    _datesWithEvent = [NSMutableArray new];
    
    // Set custom indicator margin
    self.tableView.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tableView.infiniteScrollTriggerOffset = 300;
    
    // Add infinite scroll handler
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        @strongify(self)
        [self appendEvent];
    }];
}

- (NSString*) getTwoMonthWords:(NSString*) month {
//    NSString* string = [NSString stringWithFormat:@"%ld", [month integerValue]-1];
    NSString* string = month;
    if (string.length == 1) {
        string = [@"0" stringByAppendingString:string];
    }
    return string;
}

- (void) getMonthlySummaryWithCompletion:(void(^)(void)) completion {
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] getCalenarMonthlySummaryWithYear:curYear month:curMonth filter:currentBottomFilter withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        @strongify(self)
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            for (int i = 0; i < eventsArray.count; i++) {
                NSString* _eventDate = [NSString stringWithFormat:@"%@-%@-%@", curYear, curMonth, [self getTwoMonthWords: eventsArray[i]]];
                [_datesWithEvent addObject:_eventDate];
            }
            
            [_calendar reloadData];
        }
    }];
}

- (void) loadEventFromFilters {
    
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] getLatestEventWithStartDate:startDate endDate:endDate filter:currentBottomFilter search:_search page:_page withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            self.originalArray = eventsArray;
            self.eventsArray = _originalArray;
            if (eventsArray.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
                // update table view
                
            }
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}


- (void) appendEvent {
    
    if (isLoading) return;
    isLoading = YES;
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] getLatestEventWithStartDate:startDate endDate:endDate filter:currentBottomFilter search:_search page:_page withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        if (error == nil) {
            
            _originalArray = [[_originalArray arrayByAddingObjectsFromArray:eventsArray] mutableCopy];
            
            self.eventsArray = _originalArray;
            
            if (eventsArray.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
                // update table view
                
                [self.tableView reloadData];
            }
            
            [self.tableView finishInfiniteScroll];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) resetState: (UIButton*) button {
    [button setTitleColor:[UIColor darkBarColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
}

- (void) resetButtonState {
    [self resetState:self.allBtn];
    [self resetState:self.courtBtn];
    [self resetState:self.officeBtn];
    [self resetState:self.personalBtn];
}

- (IBAction) courtFilter: (id) sender  {
    currentBottomFilter = self.bottomFilters[0];
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:0];
}

- (IBAction) officeFilter: (id) sender  {
    currentBottomFilter = self.bottomFilters[1];
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:1];
}

- (IBAction) personalFilter: (id) sender  {
    currentBottomFilter = self.bottomFilters[2];
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:2];
}

- (IBAction) allFilter: (id) sender {
    currentBottomFilter = self.bottomFilters[3];
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:3];
}

- (IBAction) onBackAction: (id) sender
{
    [self.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerNibs {
    
    [EventCell registerForReuseInTableView:self.tableView];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT/2;
}

- (void) resetTopFilterButtons {
    self.page = @(1);
    [self resetState:self.todayBtn];
    [self resetState:self.thisWeekBtn];
    [self resetState:self.futureBtn];
    [self resetState:self.previousBtn];
}

- (void) updateBottomTabStateWithAnimate:(NSInteger)index {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f animations:^{
            [self updateBottomTabState:index];
        } completion:^(BOOL __unused finished) {
            
        }];
    });
}

- (void) updateTabStateWithAnimate:(NSInteger)index {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.3f animations:^{
            [self updateTabState:index];
        } completion:^(BOOL __unused finished) {
            
        }];
    });
}

- (void) updateBottomTabState:(NSInteger)tab {
    CGFloat width = CGRectGetWidth(self.view.frame)/4;
    self.bottomLeading.constant = tab * width;
}

- (void) updateTabState:(NSInteger)tab {
    CGFloat width = CGRectGetWidth(self.view.frame)/4;
    self.tabbarIndicatorLeading.constant = tab * width;
}

- (IBAction)didTapToday:(id)sender {
    [self resetTopFilterButtons];
    [self.todayBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startDate = [DIHelpers today];
    endDate = [DIHelpers today];
    [self loadEventFromFilters];
    [self updateTabStateWithAnimate:0];
}

- (IBAction)didTapThisWeek:(id)sender {
    [self resetTopFilterButtons];
    [self.thisWeekBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startDate = [DIHelpers today];
    endDate = [DIHelpers sevenDaysLater];
    [self loadEventFromFilters];
    [self updateTabStateWithAnimate:1];
}

- (IBAction)didTapFuture:(id)sender {
    [self resetTopFilterButtons];
    [self.futureBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startDate = [DIHelpers today];
    endDate = @"2999-12-31";
    [self loadEventFromFilters];
    [self updateTabStateWithAnimate:2];
}

- (IBAction)didTapPrevious:(id)sender {
    [self resetTopFilterButtons];
    [self.previousBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startDate = [DIHelpers sevenDaysBefore];
    endDate = [DIHelpers today];
    [self loadEventFromFilters];
    [self updateTabStateWithAnimate:3];
}

- (IBAction)didTapCalendar:(id)sender {
    [self performSegueWithIdentifier:kCalendarRangeSegue sender:self.currentRange];
}

- (void) updateEvents {
    self.search = @"";
    self.eventsArray = self.originalArray;
    [self.tableView reloadData];
}

#pragma mark - Calenar Datasource

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    if ([self.datesWithEvent containsObject:[self.dateFormatter2 stringFromDate:date]]) {
        return 1;
    }
    return 0;
}

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar
{
    curMonth = [DIHelpers currentMonthFromDate:calendar.currentPage];
    curYear = [DIHelpers currentYearFromDate:calendar.currentPage];
    [self getMonthlySummaryWithCompletion:nil];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    //    CGFloat contentHeight = scrollView.contentSize.height;
    if (offsetY > 10) {
        
        [self.searchBar endEditing:YES];
        _searchBar.showsCancelButton = NO;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    _searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar resignFirstResponder];
    _searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [self searchBarSearchButtonClicked:searchBar];
}

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    [self updateEvents];
}

#pragma mark - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    searchController.searchBar.text = @"";
    [self updateEvents];
}

#pragma mark - searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.search = searchBar.text;
    [self loadEventFromFilters];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)__unused tableView {
    
    return [self.eventsArray count];
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 5;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     EventCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventCell cellIdentifier] forIndexPath:indexPath];
    
    cell.tag = indexPath.section;
    [cell configureCellWithEvent:self.eventsArray[indexPath.section]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    EventModel* event = self.eventsArray[indexPath.section];
//    if (isLoading) return;
//    isLoading = YES;
//    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
//    __weak UINavigationController *navigationController = self.navigationController;
//    @weakify(self);
//    [[QMNetworkManager sharedManager] getCourtWithCode:event.eventCode WithCompletion:^(EditCourtModel * _Nonnull model, NSError * _Nonnull error) {
//        
//        @strongify(self)
//        self->isLoading = NO;
//        if (error == nil) {
//            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Loaded" duration:1.0];
//            [self performSegueWithIdentifier:kEditCourtSegue sender:model];
//            
//        } else {
//            [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
//        }
//    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCalendarRangeSegue]) {
        CalendarRangeView* calendarRangeViewVC = segue.destinationViewController;
        calendarRangeViewVC.currentRange = self.currentRange;
    }
    
    if ([segue.identifier isEqualToString:kEditCourtSegue]) {
        UINavigationController *navVC = segue.destinationViewController;
        EditCourtDiaryViewController* editCourtVC = navVC.viewControllers.firstObject;
        editCourtVC.courtModel = sender;
    }
}


@end
