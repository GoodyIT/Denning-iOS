    //
//  DocumentViewController.m
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DocumentViewController.h"
#import "DocumentCell.h"
#import "NewContactHeaderCell.h"

@interface DocumentViewController () <
UIDocumentInteractionControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate>

@property (strong, nonatomic) UIImageView *postView;
@property (strong, nonatomic) DocumentModel* originalDocumentModel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectBtn;

@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;

@end

@implementation DocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    [self configureSearch];
    if (self.previousScreen.length != 0) {
        [self prepareUI];
    }
    [self updateButtonsToMatchTableState];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.originalDocumentModel = self.documentModel;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareUI {
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popupScreen:)];
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItems:@[backButtonItem] animated:YES];
    
    self.tableView.delegate = self;
}

- (void) configureSearch
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (IBAction)didTapSelect:(id)sender {
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)didTapCancel:(id)sender {
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (NSURL*) getFileURL: (FileModel*) file
{
    NSURL *url = [NSURL URLWithString: file.URL];
    if (![file.ext isEqualToString:@".url"]) {
        NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/%@", [DataManager sharedManager].user.serverAPI, file.URL];
        url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    
    return url;
}

- (IBAction)didTapShare:(id)sender {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
    NSMutableArray* urlArray = [NSMutableArray new];
    for (NSIndexPath *selectionIndex in selectedRows)
    {
        if (selectionIndex.section == 0) {
            continue;
        }
        if (selectionIndex.section == 1) {
            FileModel* file = self.documentModel.documents[selectionIndex.row];
            [urlArray addObject:[self getFileURL:file]];
        } else {
            FolderModel* model = self.documentModel.folders[selectionIndex.section-2];
            FileModel* file = model.documents[selectionIndex.row];
            [urlArray addObject:[self getFileURL:file]];
        }
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 4;
    
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // share
        }];
    }];
    
    for (NSURL* url in urlArray)
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            NSData *data = [NSData dataWithContentsOfURL:url];
           
        }];
        [completionOperation addDependency:operation];
    }
    
    [queue addOperations:completionOperation.dependencies waitUntilFinished:NO];
    [queue addOperation:completionOperation];
//    UIImage *image = [UIImage imageWithData:[chart getImage]];
//    NSArray *activityItems = @[image];
//    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    activityViewControntroller.excludedActivityTypes = @[];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        activityViewControntroller.popoverPresentationController.sourceView = self.view;
//        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
//    }
//    [self presentViewController:activityViewControntroller animated:true completion:nil];
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.rightBarButtonItem = self.cancelBtn;
        
//        [self updateDeleteButtonTitle];
        
        // Show the delete button.
        self.navigationItem.leftBarButtonItem = self.shareBtn;
    }
    else
    {
        // Not in editing mode.
        self.navigationItem.leftBarButtonItem = self.backBtn;
        
        // Show the edit button, but disable the edit button if there's nothing to edit.
        int count = 0;
        count += self.documentModel.documents.count;
        for (int i = 0; i < _documentModel.folders.count; i++) {
            
            count += self.documentModel.folders[i].documents.count;
        }
        if (count > 0)
        {
            self.selectBtn.enabled = YES;
        }
        else
        {
            self.selectBtn.enabled = NO;
        }
        self.navigationItem.rightBarButtonItem = self.selectBtn;
    }
}

- (void) popupScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)registerNibs {
    [NewContactHeaderCell registerForReuseInTableView:self.tableView];
    [DocumentCell registerForReuseInTableView:self.tableView];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (void) filterDocument {
    DocumentModel *newDocument = [DocumentModel new];
    NSMutableArray* newFolders = [NSMutableArray new];
    for (FolderModel* model in self.originalDocumentModel.folders) {
        FolderModel* newFolderModel = [FolderModel new];
        NSMutableArray *fileArray =[NSMutableArray new];
        for (FileModel* file in model.documents) {
            if ([file.name localizedCaseInsensitiveContainsString:self.filter]) {
                [fileArray addObject:file];
            }
        }
        newFolderModel.documents = [fileArray copy];
        [newFolders addObject:newFolderModel];
    }
    
    NSMutableArray *fileArray =[NSMutableArray new];
    for (FileModel* file in self.originalDocumentModel.documents) {
        if ([file.name localizedCaseInsensitiveContainsString:self.filter]) {
            [fileArray addObject:file];
        }
    }
    newDocument.documents = [fileArray copy];
    
    newDocument.folders = [newFolders copy];
    newDocument.name = self.originalDocumentModel.name;
    newDocument.date = self.originalDocumentModel.date;
    
    self.documentModel = newDocument;
    
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

#pragma mark - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *) __unused searchController {
    self.filter = @"";
    searchController.searchBar.text = @"";
    self.documentModel = self.originalDocumentModel;
    [self.tableView reloadData];
}

#pragma mark - searchbar delegate

- (void)searchBar:(UISearchBar *) __unused searchBar textDidChange:(NSString *)searchText
{
    self.filter = searchText;
    if (self.filter.length == 0) {
        self.documentModel = self.originalDocumentModel;
        [self.tableView reloadData];
    } else {
        [self filterDocument];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

#pragma mark - Table view data source

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    }
    
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.documentModel.folders.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.documentModel.documents.count;
    }

    FolderModel* model = self.documentModel.folders[section-2];
    
    return model.documents.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (section == 0) {
        sectionName = @"";
    } else if (section == 1){
        sectionName = @"Files";
    } else {
        FolderModel* model = self.documentModel.folders[section-2];
        sectionName = model.name;
    }
    
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NewContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[NewContactHeaderCell cellIdentifier] forIndexPath:indexPath];
        NSArray *info = [DIHelpers separateNameIntoTwo: self.documentModel.name];
        [cell configureCellWithInfo:info[0] number:info[1] image:nil];
        cell.editBtn.hidden = YES;
        cell.chatBtn.hidden = YES;
        cell.editLabel.hidden = YES;
        cell.chatLabel.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    } else if (indexPath.section == 1) {
        DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:[DocumentCell cellIdentifier] forIndexPath:indexPath];
        FileModel* file = self.documentModel.documents[indexPath.row];
        [cell configureCellWithFileModel:file
         ];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:[DocumentCell cellIdentifier] forIndexPath:indexPath];
    FolderModel* model = self.documentModel.folders[indexPath.section-2];
    FileModel* file = model.documents[indexPath.row];
    [cell configureCellWithFileModel:file
         ];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.isEditing) {
        return;
    }
    
    FileModel* file;
    if (indexPath.section == 0) {
        return;
    } else if (indexPath.section == 1) {
        file = self.documentModel.documents[indexPath.row];
    } else {
        FolderModel* model = self.documentModel.folders[indexPath.section-2];
        file = model.documents[indexPath.row];
    }
    NSURL *url = [self getFileURL:file];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                           inDomain:NSUserDomainMask
                                                                  appropriateForURL:nil
                                                                             create:NO error:nil];
        
        NSString* newPath = [[documentsDirectory absoluteString] stringByAppendingString:[NSString stringWithFormat:@"DenningIT%@/", [DIHelpers randomTime]]];
        if (![FCFileManager isDirectoryItemAtPath:newPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return [documentsDirectory URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
