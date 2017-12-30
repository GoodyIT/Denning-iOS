//
//  QMGroupNameViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupNameViewController.h"
#import "QMCore.h"
#import "QMNavigationController.h"

typedef NS_ENUM(NSUInteger, QMUserInfoSection) {
    
    DIGroupNameSection,
    DIGroupTypeSection
};

@interface QMGroupNameViewController ()
{
    BOOL nameChanged, tagChanged, positionChanged;
    NSString* selectedTag;
}

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UITextField *groupPositionField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tagSegment;

@end

@implementation QMGroupNameViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (NSInteger) getTagAsIndex:(NSString*) tag {
    NSArray* tagArray = @[@"Colleagues", @"Clients", @"Matters", @"Denning"];
    return [tagArray indexOfObject:tag];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.groupNameField.text = self.chatDialog.name;
    self.groupPositionField.text = [DIHelpers getGroupPosition:self.chatDialog];
    
    [self updateGroupType];
    
    selectedTag = [DIHelpers getTag:self.chatDialog];
    
    _tagSegment.selectedSegmentIndex = [self getTagAsIndex:selectedTag];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

- (BOOL) isSupportChat {
    BOOL isCorrect = NO;
    NSString* tag = [_chatDialog.data valueForKey:@"tag"];
    if (tag != nil && [tag isEqualToString:@"Denning"]) {
        isCorrect = YES;
    }
    
    return isCorrect;
}

- (void) updateGroupType {
    if  (![[DataManager sharedManager] isDenningUser]) {
        [_tagSegment removeSegmentAtIndex:3 animated:YES];
        if ([self isSupportChat]) {
            
        }
    }
}

//MARK: - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    NSMutableArray* tasks = [NSMutableArray new];
    if (nameChanged) {
        BFTask* changeNameTask = [QMCore.instance.chatManager changeName:self.groupNameField.text forGroupChatDialog:self.chatDialog];
        [tasks addObject:changeNameTask];
    }
    if (tagChanged) {
        BFTask* changeTagTask = [QMCore.instance.chatManager changeTag:selectedTag forGroupChatDialog:self.chatDialog];
        [tasks addObject:changeTagTask];
    }
    if (positionChanged) {
        BFTask* positionTask = [QMCore.instance.chatManager changeCustomData:@{kGroupPositionTag:_groupPositionField.text} forGroupChatDialog:self.chatDialog];
        [tasks addObject:positionTask];
    }
    
    if (tasks.count > 0) {
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
        
        @weakify(self);
        [[BFTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            [(QMNavigationController *)navigationController dismissNotificationPanel];
            
            @strongify(self)
            if (!t.isFaulted) {
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            return nil;
        }];
    }
}

- (IBAction)groupNameFieldEditingChanged:(UITextField *)sender {
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if ([sender.text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0
        || [sender.text isEqualToString:self.chatDialog.name]) {
        nameChanged = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        return;
    }
    
    nameChanged = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (IBAction)groupPositionFieldEditingChanged:(UITextField *)sender {
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if ([sender.text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0
        || [sender.text isEqualToString:[DIHelpers getGroupPosition:self.chatDialog]]) {
        positionChanged = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        return;
    }
    
    positionChanged = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


- (IBAction)tagSelected:(UISegmentedControl*) sender {
    
    if (sender.selectedSegmentIndex == 0) {
        selectedTag = @"Colleagues";
    } else if (sender.selectedSegmentIndex == 1) {
        selectedTag = @"Clients";
    } else if (sender.selectedSegmentIndex == 2) {
        selectedTag = @"Matters";
    }
    
    if ([[DataManager sharedManager] isDenningUser]) {
        if (sender.selectedSegmentIndex == 3) {
            selectedTag = @"Denning";
        }
    }
    
    if  ([selectedTag isEqualToString:[DIHelpers getTag:self.chatDialog]]) {
        tagChanged = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        tagChanged = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![[DataManager sharedManager] isDenningUser]) {
        [_tagSegment removeSegmentAtIndex:3 animated:YES];
        if ([self isSupportChat]) {
            return 1;
        }
    }
    
    return 3;
}

@end
