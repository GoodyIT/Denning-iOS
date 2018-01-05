//
//  ShareDocumentViewController.m
//  DenningShare
//
//  Created by Denning IT on 2018-01-05.
//  Copyright © 2018 DenningIT. All rights reserved.
//

#import "ShareDocumentViewController.h"
#import "DocumentCell.h"
#import "NewContactHeaderCell.h"
#import "DIGlobal.h"
#import "DocumentModel.h"
#import "FileModel.h"
#import "ShareHelper.h"

static int THE_CELL_HEIGHT = 450;

@interface ShareDocumentViewController ()< UISearchBarDelegate, UISearchControllerDelegate, UIDocumentInteractionControllerDelegate>
{
    NSUserDefaults* defaults;
}
@property (strong, nonatomic) DocumentModel* documentModel;

@property (strong, nonatomic) UIImageView *postView;
@property (strong, nonatomic) DocumentModel* originalDocumentModel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectBtn;

@property (strong, nonatomic) UISearchController *searchController;
@property (copy, nonatomic) NSString *filter;
@end

@implementation ShareDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNibs];
    [self configureSearch];
    
     defaults = [[NSUserDefaults alloc] initWithSuiteName:kGroupShareIdentifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/%@", [defaults valueForKey:@"api"], file.URL];
        url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    }
    
    return url;
}

- (IBAction)didTapShare:(id)sender {
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    NSMutableArray* urlArray = [NSMutableArray new];
    for (NSIndexPath *selectionIndex in selectedRows)
    {
        if (selectionIndex.section == 0) {
            continue;
        }
        if (selectionIndex.section == 1) {
            FileModel* file = self.documentModel.documents[selectionIndex.row];
            [urlArray addObject:@[[self getFileURL:file], file.name]];
        } else {
            DocumentModel* model = self.documentModel.folders[selectionIndex.section-2];
            FileModel* file = model.documents[selectionIndex.row];
            [urlArray addObject:@[[self getFileURL:file], file.name]];
        }
    }
}

- (void) shareDocument:(NSArray*) urls {
    NSMutableArray* activityItems = [NSMutableArray new];
    for (NSURL* url in urls) {
        [activityItems addObject:[NSData dataWithContentsOfURL:url]];
    }
    
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityViewControntroller.popoverPresentationController.sourceView = self.view;
        activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
    }
    activityViewControntroller.completionWithItemsHandler = ^(NSString *activityType,
                                                              BOOL completed,
                                                              NSArray *returnedItems,
                                                              NSError *error){
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
    [self presentViewController:activityViewControntroller animated:true completion:nil];
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
        self.navigationItem.leftBarButtonItem = self.sendBtn;
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
    
    //    self.navigationItem.rightBarButtonItem = nil;
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
    for (DocumentModel* model in self.originalDocumentModel.folders) {
        DocumentModel* newDocumentModel = [DocumentModel new];
        newDocumentModel.name = model.name;
        newDocumentModel.date = model.date;
        NSMutableArray *fileArray =[NSMutableArray new];
        for (FileModel* file in model.documents) {
            if ([file.name localizedCaseInsensitiveContainsString:self.filter]) {
                [fileArray addObject:file];
            }
        }
        if (fileArray.count > 0) {
            newDocumentModel.documents = [fileArray copy];
            [newFolders addObject:newDocumentModel];
        }
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
    [self searchBar:searchBar textDidChange:searchBar.text];
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
    
    DocumentModel* model = self.documentModel.folders[section-2];
    
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
        DocumentModel* model = self.documentModel.folders[section-2];
        sectionName = model.name;
    }
    
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.0;
    }
    
    if (section == 1 && self.documentModel.documents.count == 0) {
        return 0;
    } else if (section > 1 && self.documentModel.folders[section-2].folders.count == 0) {
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
        NSArray *info = [ShareHelper separateNameIntoTwo: self.documentModel.name];
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
    
    DocumentModel* model = self.documentModel.folders[indexPath.section-2];
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
        DocumentModel* model = self.documentModel.folders[indexPath.section-2];
        file = model.documents[indexPath.row];
    }
    NSURL *url = [self getFileURL:file];
    
    [self displayDocument:url];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) displayDocument:(NSURL*) document
{
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return self;
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
