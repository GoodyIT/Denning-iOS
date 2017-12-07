//
//  PersonalDocumentViewController.m
//  Denning
//
//  Created by DenningIT on 31/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PersonalDocumentViewController.h"
#import "DocumentCell.h"

@interface PersonalDocumentViewController ()< UIDocumentInteractionControllerDelegate>
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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

    FolderModel* model = folderModel.folders[section-2];
    return model.documents.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (section == 0){
        sectionName = @"Files";
    } else {
        FolderModel* model = folderModel.folders[section-2];
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
    
    FolderModel* model = folderModel.folders[indexPath.section-2];
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
        NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, file.URL];
        url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                           inDomain:NSUserDomainMask
                                                                  appropriateForURL:nil
                                                                             create:NO error:nil];
        
        NSString* newPath = [[documentsDirectory absoluteString] stringByAppendingString:[NSString stringWithFormat:@"DenningIT%@/", [DIHelpers randomTime]]];
        if (![FCFileManager isDirectoryItemAtPath:newPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return [[NSURL URLWithString:newPath] URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        selectedDocument = filePath;
        [self displayDocument:filePath];
    }];
    [downloadTask resume];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)displayDocument:(NSURL*)document {
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controlle
{
    return self;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[selectedDocument path] error:&error];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
