//
//  BaseTableViewController.m
//  Denning
//
//  Created by Denning IT on 2017-12-08.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[QMNetworkManager sharedManager] cancelAllOperations];
    
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
    if ([self.navigationController isKindOfClass:[QMNavigationController class]]) {
        [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return 0;
}

- (void) viewDocument:(NSURL*) Url withCompletion:(void(^)(NSURL *filePath)) completion{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSError* err = nil;
        NSFileManager *fm = [NSFileManager new];
        NSURL *documentsDirectory = [fm URLForDirectory:NSDocumentDirectory
                                               inDomain:NSUserDomainMask appropriateForURL:nil
                                                 create:YES error:&err];
        
        NSURL* newPath = [documentsDirectory URLByAppendingPathComponent:@"DenningIT"];
        [fm createDirectoryAtURL:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
        
        return [newPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [DIHelpers randomTime],[response suggestedFilename]]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        if (error == nil) {
            if  (filePath != nil) {
                [self displayDocument:filePath];
                completion(filePath);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
    [downloadTask resume];
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


@end
