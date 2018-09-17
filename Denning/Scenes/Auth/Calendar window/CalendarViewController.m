//
//  CalendarViewController.m
//  Pile
//
//  Created by Admin on 2016-11-14.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "CalendarViewController.h"
#import "QMAlert.h"
#import "RealPropertyGainTaxViewController.h"

@interface CalendarViewController ()
{
    NSDateFormatter *dateFormat;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CalendarViewController

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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.typeOfDate;
}

- (IBAction)nextBtnDidTap
{
   
    NSDate *pickerDate = [_datePicker date];
 
    [self.popupController dismissWithCompletion:^{
        if ([self.typeOfDate isEqualToString:@"Date of Disposal"]) {
            [self.realVC updateDateOfDisposal:[dateFormat stringFromDate:pickerDate]];
        } else {
            [self.realVC updateDateOfAcquisition:[dateFormat stringFromDate:pickerDate]];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMM yyyy"];
    if (_minDate != nil) {
        [self.datePicker setMinimumDate:[dateFormat dateFromString:_minDate]];
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
