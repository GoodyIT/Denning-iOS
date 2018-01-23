//
//  SearchMatterCodeDetail.m
//  Denning
//
//  Created by Ho Thong Mee on 16/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SearchMatterCodeDetail.h"

@interface SearchMatterCodeDetail ()
@property (weak, nonatomic) IBOutlet UILabel *category;
@property (weak, nonatomic) IBOutlet UILabel *matterDescription;
@property (weak, nonatomic) IBOutlet UILabel *matterFormName;
@property (weak, nonatomic) IBOutlet UILabel *groupName1;
@property (weak, nonatomic) IBOutlet UILabel *groupName2;
@property (weak, nonatomic) IBOutlet UILabel *groupName3;
@property (weak, nonatomic) IBOutlet UILabel *groupName4;
@property (weak, nonatomic) IBOutlet UILabel *groupName5;
@property (weak, nonatomic) IBOutlet UILabel *turnAround;

@end

@implementation SearchMatterCodeDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _category.text = _model.category;
    _matterDescription.text = _model.matterDescription;
    _matterFormName.text = _model.formName;
    _groupName1.text = _model.groupName1;
    _groupName2.text = _model.groupName2;
    _groupName3.text = _model.groupName3;
    _groupName4.text = _model.groupName4;
    _groupName5.text = _model.groupName5;
    _turnAround.text = _model.turnAround;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 9;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMatterCode" forIndexPath:indexPath];
//    
//    
//    
//    return cell;
//}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
