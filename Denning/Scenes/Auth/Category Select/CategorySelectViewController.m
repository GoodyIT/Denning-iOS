//
//  CategorySelectViewController.m
//  Denning
//
//  Created by DenningIT on 07/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CategorySelectViewController.h"

@interface CategorySelectViewController ()
@property (weak, nonatomic) IBOutlet UIButton *denningBtn;
@property (weak, nonatomic) IBOutlet UIButton *bussinessBtn;
@property (weak, nonatomic) IBOutlet UIButton *personalBtn;

@end

@implementation CategorySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapDenningCategory:(id)sender {
}

- (IBAction)tapBussinessCategory:(id)sender {
}

- (IBAction)tapPersonalCategory:(id)sender {
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
