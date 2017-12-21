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

@interface QMGroupNameViewController ()
{
    BOOL nameChanged, tagChanged;
    NSString* selectedTag;
}

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tagSegment;

@end

@implementation QMGroupNameViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (NSString*) getTag {
    NSString* tag = [_chatDialog.data valueForKeyNotNull:@"tag"];
    return tag.length == 0 ? @"Colleagues" : tag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.groupNameField.text = self.chatDialog.name;
    
    selectedTag = [self getTag];
    
    if  ([[DataManager sharedManager] isDenningUser]) {
        [_tagSegment insertSegmentWithTitle:@"Denning" atIndex:2 animated:YES];
    } else {
        [_tagSegment removeSegmentAtIndex:3 animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

//MARK: - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    BFTask* changeNameTask = [QMCore.instance.chatManager changeName:self.groupNameField.text forGroupChatDialog:self.chatDialog];
    BFTask* changeTagTask = [QMCore.instance.chatManager changeTag:selectedTag forGroupChatDialog:self.chatDialog];
    NSMutableArray* tasks = [NSMutableArray new];
    if (nameChanged) {
        [tasks addObject:changeTagTask];
    }
    if (tagChanged) {
        [tasks addObject:changeNameTask];
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

- (void) updateGroupTag:(NSInteger) index {
    
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
    
    if  ([selectedTag isEqualToString:[self getTag]]) {
        tagChanged = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        tagChanged = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

@end
