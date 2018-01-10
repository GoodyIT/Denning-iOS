//
//  PersonalDocumentViewController.m
//  Denning
//
//  Created by DenningIT on 31/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PersonalDocumentViewController.h"
#import "DocumentCell.h"

@interface PersonalDocumentViewController ()
{
    NSURL* selectedDocument;
    NSString* email, *sessionID;
}

@end

@implementation PersonalDocumentViewController
@synthesize folderModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
    [self registerNibs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissScreen:(id)sender {
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void) prepareUI {
    email = [DataManager sharedManager].user.email;
    sessionID = [DataManager sharedManager].user.sessionID;
}

- (void)registerNibs {
    [DocumentCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return folderModel.folders.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return folderModel.documents.count;
    }

    DocumentModel* model = folderModel.folders[section-1];
    return model.documents.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (section == 0){
        sectionName = @"Files";
    } else {
        DocumentModel* model = folderModel.folders[section-2];
        sectionName = model.name;
    }

    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:[DocumentCell cellIdentifier] forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        FileModel* file = folderModel.documents[indexPath.row];
        [cell configureCellWithFileModel:file
         ];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:[DocumentCell cellIdentifier] forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    DocumentModel* model = folderModel.folders[indexPath.section-2];
    FileModel* file = model.documents[indexPath.row];
    [cell configureCellWithFileModel:file
     ];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD show];
    FileModel* file = folderModel.documents[indexPath.row];

    NSURL *url = [NSURL URLWithString: file.URL];
    if (![file.ext isEqualToString:@".url"]) {
        NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].tempServerURL, file.URL];
        url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    
    [[DIDocumentManager shared] downloadFileFromURL:url withProgress:^(CGFloat progress) {
        [SVProgressHUD showProgress:progress];
    } completion:^(NSURL *filePath) {
        [SVProgressHUD dismiss];
        [[DIDocumentManager shared] displayDocument:filePath inView:self];
    } onError:^(NSError *error) {
        [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:self];
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
