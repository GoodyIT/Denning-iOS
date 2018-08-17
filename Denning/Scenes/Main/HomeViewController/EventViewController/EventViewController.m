//
//  EventViewController.m
//  Denning
//
//  Created by DenningIT on 15/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EventViewController.h"
#import "EventCell.h"
#import "CalendarRangeView.h"
#import "CourtDiaryViewController.h"
#import "PersonalDiaryViewController.h"
#import "OfficeDiaryViewController.h"
#import "TodayEventViewController.h"

@interface EventViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate,FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance>
{
    NSString* currentTopFilter, *currentBottomFilter;
    NSString* curYear, *curMonth;
    __block BOOL isLoading, isAppending;
    NSString* startDate, *endDate;
    
    CGFloat lastContentOffset;
}
@property (weak, nonatomic) IBOutlet UIView *calendarView;

@property (weak, nonatomic) FSCalendar *calendar;
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
   
    [self setupTopBottomFilters];
    [self getMonthlySummaryWithCompletion:nil];
    [self registerNibs];
    [self presetDateRange];
}

- (void) loadView
{
    [super loadView];
    [self configureCalendar];
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
    //  calendar.allowsMultipleSelection = YES;
    FSCalendar* calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(10, 0, _calendarView.frame.size.width-20, _calendarView.frame.size.height)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.swipeToChooseGesture.enabled = YES;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    calendar.appearance.titleWeekendColor = [UIColor babyRed];
    calendar.appearance.headerTitleColor = [UIColor babyRed];
    [_calendarView addSubview:calendar];
    _calendar = calendar;
    [_calendar layoutIfNeeded];
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
    self.tableView.tableFooterView = [UIView new];
    
    self.calendar.accessibilityIdentifier = @"calendar";
    self.dateFormatter2 = [[NSDateFormatter alloc] init];
    self.dateFormatter2.dateFormat = @"yyyy-MM-dd";
    _datesWithEvent = [NSMutableArray new];
    
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    // Set custom indicator
    self.tableView.infiniteScrollIndicatorView = indicator;
    
    // Set custom indicator margin
    self.tableView.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tableView.infiniteScrollTriggerOffset = 500;
    
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
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
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
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] getLatestEventWithStartDate:startDate endDate:endDate filter:currentBottomFilter search:_search page:_page withCompletion:^(NSArray * _Nonnull eventsArray, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = NO;
        [navigationController dismissNotificationPanel];
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (isAppending) {
                _originalArray = [[_originalArray arrayByAddingObjectsFromArray:eventsArray] mutableCopy];
            } else {
                self.originalArray = eventsArray;
            }
            
            self.eventsArray = _originalArray;
            if (eventsArray.count > 0) {
                _page = [NSNumber numberWithInteger:([_page integerValue] + 1)];
                // update table view
                
            }
            [self.tableView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        self->isAppending = NO;
    }];
}

- (void) appendEvent {
    isAppending = YES;
    [self loadEventFromFilters];
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
    _page = @(1);
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:0];
}

- (IBAction) officeFilter: (id) sender  {
    currentBottomFilter = self.bottomFilters[1];
    _page = @(1);
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:1];
}

- (IBAction) personalFilter: (id) sender  {
    currentBottomFilter = self.bottomFilters[2];
    _page = @(1);
    [self loadEventFromFilters];
    [self updateBottomTabStateWithAnimate:2];
}

- (IBAction) allFilter: (id) sender {
    currentBottomFilter = self.bottomFilters[3];
    _page = @(1);
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
  //  startDate = [DIHelpers sevenDaysBefore];
    startDate = @"1000-01-01";
    endDate = [DIHelpers today];
    [self loadEventFromFilters];
    [self updateTabStateWithAnimate:3];
}

- (IBAction)didTapCalendar:(id)sender {
    [self performSegueWithIdentifier:kCalendarRangeSegue sender:self.currentRange];
}

- (void) updateEvents {
    _page = @(1);
    [self loadEventFromFilters];
}

#pragma mark - Calenar Datasource

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated
{
    // Do other updates here
    [self.view layoutIfNeeded];
}

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

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    [self showTodayEvent:[self.dateFormatter2 stringFromDate:date]];
}

- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (void) showTodayEvent:(NSString*) date {
    [self.view endEditing:YES];
    
    TodayEventViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TodayEventViewController"];
    vc.startDate = vc.endDate = date;
    [self showPopup:vc];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   lastContentOffset = scrollView.contentOffset.y;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
    _searchBar.showsCancelButton = NO;
    
    if (lastContentOffset < scrollView.contentOffset.y) {
        // up
    } else if (lastContentOffset > scrollView.contentOffset.y) {
        // moved to bottom
       
    } else {
        // didn't move
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
    _search = searchText;
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
    [self updateEvents];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     EventCell *cell = [tableView dequeueReusableCellWithIdentifier:[EventCell cellIdentifier] forIndexPath:indexPath];
    
    cell.tag = indexPath.section;
    [cell configureCellWithEvent:self.eventsArray[indexPath.section]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventModel* event = self.eventsArray[indexPath.section];
    NSString *courtString;
    if ([event.eventType isEqualToString:@"1court"]) {
        courtString = @"courtDiary";
    } else if ([event.eventType isEqualToString:@"2office"]) {
        courtString = @"OfficeDiary";
    } else {
        courtString = @"PersonalDiary";
    }
    
    NSString* url = [NSString stringWithFormat:@"%@%@/%@", [DataManager sharedManager].user.serverAPI,courtString,  event.eventCode];
    if (isLoading) return;
    isLoading = YES;
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] sendPrivateGetWithURL:url completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        @strongify(self)
        self->isLoading = NO;
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:@"Successfully Loaded" duration:1.0];
            id model;
            if ([event.eventType isEqualToString:@"1court"]) {
                model = [EditCourtModel getEditCourtFromResponse:result];
                 [self performSegueWithIdentifier:kEditCourtSegue sender:model];
            } else if ([event.eventType isEqualToString:@"2office"]) {
                model = [OfficeDiaryModel getOfficeDiaryFromResponse:result];
                 [self performSegueWithIdentifier:kEditOfficeDiarySegue sender:model];
            } else {
                model = [OfficeDiaryModel getOfficeDiaryFromResponse:result];
                [self performSegueWithIdentifier:kEditPersonalDiarySegue sender:model];
            }
        } else {
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:error.localizedDescription duration:1.0];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCalendarRangeSegue]) {
        CalendarRangeView* calendarRangeViewVC = segue.destinationViewController;
        calendarRangeViewVC.currentRange = self.currentRange;
    } else if ([segue.identifier isEqualToString:kEditCourtSegue]) {
        UINavigationController *navVC = segue.destinationViewController;
        CourtDiaryViewController* vc = navVC.viewControllers.firstObject;
        vc.courtDiary = sender;
    } else if ([segue.identifier isEqualToString:kEditPersonalDiarySegue]) {
        UINavigationController *navVC = segue.destinationViewController;
        PersonalDiaryViewController* editCourtVC = navVC.viewControllers.firstObject;
        editCourtVC.personalDiary = sender;
    } else if ([segue.identifier isEqualToString:kEditOfficeDiarySegue]) {
        UINavigationController *navVC = segue.destinationViewController;
        OfficeDiaryViewController* editCourtVC = navVC.viewControllers.firstObject;
        editCourtVC.officeDiary = sender;
    }
}


@end
