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

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tagSegment;

@end

@implementation QMGroupNameViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.groupNameField.text = self.chatDialog.name;
    
    if  ([[DataManager sharedManager] isDenningUser]) {
        [_tagSegment insertSegmentWithTitle:@"Denning" atIndex:2 animated:YES];
    } else {
        [_tagSegment removeSegmentAtIndex:2 animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

//MARK: - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    @weakify(self);
    [[QMCore.instance.chatManager changeName:self.groupNameField.text forGroupChatDialog:self.chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        @strongify(self);
        
        [(QMNavigationController *)navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

- (IBAction)groupNameFieldEditingChanged:(UITextField *)sender {
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if ([sender.text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0
        || [sender.text isEqualToString:self.chatDialog.name]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void) updateGroupTag:(NSInteger) index {
    
}

- (IBAction)tagSelected:(UISegmentedControl*) sender {
    
    if (sender.selectedSegmentIndex == 0) {
        
    } else if (sender.selectedSegmentIndex == 1) {
        
    }
    
    if  ([[DataManager sharedManager] isDenningUser]) {
        if (sender.selectedSegmentIndex == 2) {
            
        }
    }
}

@end
