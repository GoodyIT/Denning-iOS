//
//  DateTimeView.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DateTimeView.h"

@interface DateTimeView ()


@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation DateTimeView

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMM yyyy"];
    if (_initialDate.length != 0) {
        _datePicker.date = [dateFormatter dateFromString:_initialDate];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
