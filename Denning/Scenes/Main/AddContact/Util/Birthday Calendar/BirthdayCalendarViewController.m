//
//  CalendarViewController.m
//  Pile
//
//  Created by Admin on 2016-11-14.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "BirthdayCalendarViewController.h"
#import "QMAlert.h"

@interface BirthdayCalendarViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation BirthdayCalendarViewController

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
    [dateFormat setDateFormat:@"d MMM yyyy"];
    NSDate *pickerDate = [_datePicker date];
 
    [self.popupController dismissWithCompletion:^{
        self.updateHandler([dateFormat stringFromDate:pickerDate]);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMM yyyy"];
    if (_initialDate.length != 0) {
        _datePicker.date = [dateFormatter dateFromString:_initialDate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
