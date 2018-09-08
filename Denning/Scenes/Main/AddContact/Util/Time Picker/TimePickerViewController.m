//
//  TimePickerViewController.m
//  Denning
//
//  Created by DenningIT on 09/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "TimePickerViewController.h"

@interface TimePickerViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@end

@implementation TimePickerViewController

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentSizeInPopup = CGSizeMake(300, 350);
    self.landscapeContentSizeInPopup = CGSizeMake(350, 300);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
}

- (IBAction)nextBtnDidTap
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *pickerDate = [self.timePicker date];
    
    [self.popupController dismissWithCompletion:^{
        self.updateHandler([dateFormat stringFromDate:pickerDate]);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    if (_initialTime.length != 0) {
        _timePicker.date = [dateFormatter dateFromString:_initialTime];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
