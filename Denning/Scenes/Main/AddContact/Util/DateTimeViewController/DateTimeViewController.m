//
//  DateTimeViewController.m
//  Denning
//
//  Created by Denning IT on 2017-11-20.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DateTimeViewController.h"

@interface DateTimeViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation DateTimeViewController

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
    [dateFormat setDateFormat:@"d MMM yyyy HH:mm:ss"];
    NSDate *pickerDate = [self.timePicker date];
    
    [self.popupController dismissWithCompletion:^{
        self.updateHandler([dateFormat stringFromDate:pickerDate]);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
