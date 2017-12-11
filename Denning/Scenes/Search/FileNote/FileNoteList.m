//
//  FileNoteList.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileNoteList.h"
#import "FileNoteCell.h"
#import "FileNote.h"

@interface FileNoteList ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    __block BOOL isLoading;
    BOOL isAppending;
    NSNumber* _page;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *fileNo;
@property (weak, nonatomic) IBOutlet UILabel *fileName;

@end

@implementation FileNoteList

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    [self updateHeaderInfo];
    [self registerNibs];
}

- (void) prepareUI {
    CustomInfiniteIndicator *indicator = [[CustomInfiniteIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    // Set custom indicator
    self.tableView.infiniteScrollIndicatorView = indicator;
    // Set custom indicator margin
    self.tableView.infiniteScrollIndicatorMargin = 40;
    
    // Set custom trigger offset
    self.tableView.infiniteScrollTriggerOffset = 200;
    
    // Add infinite scroll handler
    @weakify(self)
    [self.tableView addInfiniteScrollWithHandler:^(UITableView *tableView) {
        @strongify(self)
        [self appendList];
    }];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    _page = @(1);
    [self openFileNote];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerNibs {
    [FileNoteCell registerForReuseInTableView:self.tableView];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = THE_CELL_HEIGHT;
}

- (void) updateHeaderInfo {
    _fileNo.text = _key;
    _fileName.text = _clientName;

    _page = @(1);
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) openFileNote {
    if (isLoading) return;
    isLoading = YES;
    
    [SVProgressHUD showWithStatus:@"Loading"];
    @weakify(self);
    [[QMNetworkManager sharedManager] loadFileNoteListWithCode:_key withPage:_page completion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        
        @strongify(self);
        self->isLoading = NO;
        [SVProgressHUD dismiss];
        [self.tableView finishInfiniteScroll];
        if (error == nil) {
            if (result.count != 0) {
                _page = [NSNumber numberWithInteger:[_page integerValue] + 1];
            }
            if (isAppending) {
                _listOfFileNotes = [[_listOfFileNotes arrayByAddingObjectsFromArray:result] mutableCopy];
                
            } else {
                _listOfFileNotes = result;
            }
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
}

- (void) appendList {
    isAppending = YES;
    [self openFileNote];
}

- (IBAction)addNewNote:(id)sender {
    [self performSegueWithIdentifier:kFileNoteSegue sender:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _listOfFileNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileNoteModel *model = _listOfFileNotes[indexPath.row];
    
    FileNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileNoteCell cellIdentifier] forIndexPath:indexPath];
    
    [cell configureCellWithModel:model];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kFileNoteSegue sender:_listOfFileNotes[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kFileNoteSegue]) {
        FileNote *vc = segue.destinationViewController;
        vc.noteModel = sender;
        vc.fileNo = _fileNo.text;
        vc.fileName = _fileName.text;
    }
}


@end
