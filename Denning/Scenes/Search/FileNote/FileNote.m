//
//  FileNote.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileNote.h"
#import "DateTimeView.h"

@interface FileNote ()
{
    NSString* curDate;
    __block BOOL isLoading;
}
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

@property (weak, nonatomic) IBOutlet UIButton *date;
//@property (weak, nonatomic) IBOutlet UITextField *date;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileNoLabel;
@property (weak, nonatomic) IBOutlet UITextView *note;
@end

@implementation FileNote

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void) prepareUI {
    _fileNoLabel.text = _fileNo;
    _fileNameLabel.text = _fileName;
    [_date setTitle:[DIHelpers getDateInShortForm:[DIHelpers todayWithTime]] forState:UIControlStateNormal];
    
    if (_noteModel != nil) {
        [_date setTitle:[DIHelpers getDateInShortForm:_noteModel.dtDate] forState:UIControlStateNormal];
        _note.text = _noteModel.strNote;
        [_btnSave setTitle:@"Update" forState:UIControlStateNormal];
    } else {
        [_btnSave setTitle:@"Save" forState:UIControlStateNormal];
    }
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.note.inputAccessoryView = accessoryView;
}

- (void) handleTap {
    [self.view endEditing:YES];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showCalendar {
    [self.view endEditing:YES];
    
    DateTimeView *calendarViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarView"];
    calendarViewController.updateHandler =  ^(NSString* date) {
        [_date setTitle:date forState:UIControlStateNormal];
        curDate = date;
    };
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:calendarViewController];
    [STPopupNavigationBar appearance].barTintColor = [UIColor flatBlackColorDark];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:17], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}
- (IBAction)didTapDate:(id)sender {
    [self showCalendar];
}

- (IBAction)didTapSave:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    
    NSMutableDictionary *param = [@{
                                    @"dtDate":[DIHelpers convertDateToMySQLFormat:curDate],
                                    @"strFileNo":[DIHelpers trim:_fileNo],
                                    @"strNote":_note.text} mutableCopy];
    
    @weakify(self)
    if(_noteModel != nil) {
        [param addEntriesFromDictionary:@{@"code":_noteModel.noteCode}];
        [SVProgressHUD showWithStatus:@"Updating"];
        
        [[QMNetworkManager sharedManager] updateFileNoteWithParams:param completion:^(FileNoteModel* _Nonnull result, NSError * _Nonnull error) {
            @strongify(self)
            self->isLoading = NO;
            if (error == nil) {
                [SVProgressHUD showInfoWithStatus:@"Success"];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    } else {
        [SVProgressHUD showWithStatus:@"Saving"];
        [[QMNetworkManager sharedManager] saveFileNoteWithParams:param completion:^(FileNoteModel* _Nonnull result, NSError * _Nonnull error) {
            @strongify(self)
            self->isLoading = NO;
            if (error == nil) {
                [SVProgressHUD showSuccessWithStatus:@"Success"];
                _noteModel = result;
                [self prepareUI];
            } else {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }
        }];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
