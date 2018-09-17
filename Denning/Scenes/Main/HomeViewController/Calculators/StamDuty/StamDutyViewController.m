//
//  StamDutyViewController.m
//  Denning
//
//  Created by DenningIT on 21/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "StamDutyViewController.h"
#import "LoanViewController.h"
#import "SPAViewController.h"
#import "TenancyViewController.h"
#import "SharesViewController.h"

#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "QMAlert.h"

@interface StamDutyViewController ()<HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>

@property (weak, nonatomic) IBOutlet UIView *stampTypesView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@property (nonatomic, strong) HTHorizontalSelectionList *selectionList;
@property (nonatomic, strong) NSArray* stamdutyTypesArray;

@property (strong, nonatomic) NSArray* viewControllers;
@property (strong, nonatomic) NSArray* viewControllersIdentifiers;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containverViewTopConstraint;

@end

@implementation StamDutyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareStamDutyTypes];
    [self prepareUI];
    
    self.containverViewTopConstraint.constant -= 64;
    [self addView:self.viewControllers[0]];
    [self configureMenuRightBtnWithImagename:@"menu_home" withSelector:@selector(gotoHome)];
}

- (void) gotoHome {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action {
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 23)];
    [menuBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    [self.navigationItem setRightBarButtonItems:@[menuButtonItem] animated:YES];
}

- (void) prepareUI {
    self.title = @"Basic Legal Costs";
    self.viewControllersIdentifiers = @[@"SPAViewController", @"LoanViewController", @"TenancyViewController", @"SharesViewController"];
    
    SPAViewController *SPAVC = [[UIStoryboard storyboardWithName:@"Calculator" bundle:nil] instantiateViewControllerWithIdentifier:self.viewControllersIdentifiers[0]];
    LoanViewController *loanVC  = [[UIStoryboard storyboardWithName:@"Calculator" bundle:nil] instantiateViewControllerWithIdentifier:self.viewControllersIdentifiers[1]];
    TenancyViewController* tenancyVC = [[UIStoryboard storyboardWithName:@"Calculator" bundle:nil] instantiateViewControllerWithIdentifier:self.viewControllersIdentifiers[2]];
    SharesViewController* sharesVC = [[UIStoryboard storyboardWithName:@"Calculator" bundle:nil] instantiateViewControllerWithIdentifier:self.viewControllersIdentifiers[3]];
    self.viewControllers = @[SPAVC, loanVC, tenancyVC, sharesVC];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void) addView: (UIViewController*) viewController
{
    [self addChildViewController:viewController];
    [self.innerView addSubview:viewController.view];
    viewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [viewController didMoveToParentViewController:self];
}

- (void) removeView: (UIViewController*) viewController
{
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void) removeAllViews
{
    for (NSInteger i = 0; i < self.viewControllers.count; i++) {
        [self removeView:self.viewControllers[i]];
    }
}

- (void) prepareStamDutyTypes {
    self.stamdutyTypesArray = @[@"SPA", @"Loan", @"Tenancy", @"Shares"];
    self.selectionList = [[HTHorizontalSelectionList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.selectionList.delegate = self;
    self.selectionList.dataSource = self;
    
    self.selectionList.selectionIndicatorAnimationMode = HTHorizontalSelectionIndicatorAnimationModeLightBounce;
    self.selectionList.showsEdgeFadeEffect = YES;
    // self.selectionList.snapToCenter = YES;
    
    self.selectionList.selectionIndicatorColor = [UIColor colorWithHexString:@"FF3B2F"];
    [self.selectionList setTitleColor:[UIColor colorWithHexString:@"FF3B2F"] forState:UIControlStateHighlighted];
    [self.selectionList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont fontWithName:@"SFUIText-Medium" size:15.0f] forState:UIControlStateNormal];
    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:17] forState:UIControlStateSelected];
    [self.selectionList setTitleFont:[UIFont boldSystemFontOfSize:17] forState:UIControlStateHighlighted];
    
    [self.view addSubview:self.selectionList];
    
 //   self.selectionList.hidden = YES;
    self.selectionList.backgroundColor = [UIColor colorWithHexString:@"EBEBF1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {

    NSLog(@"%@", self.stamdutyTypesArray);
    return self.stamdutyTypesArray.count;
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {

    return self.stamdutyTypesArray[index];
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    [self removeAllViews];
    [self addView:self.viewControllers[index]];
    if (index == 0) {
        self.containverViewTopConstraint.constant -= 64;
    } else {
        self.containverViewTopConstraint.constant = 20;
    }
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
