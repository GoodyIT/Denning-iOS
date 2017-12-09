//
//  BaseViewController.m
//  Reach-iOS
//
//  Created by MaksymRachytskyy on 11/21/15.
//  Copyright © 2015 Maksym Rachytskyy. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self removeKeyboardObservers];
    [super viewWillDisappear:animated];
    
    [[QMNetworkManager sharedManager] cancelAllOperations];
    
    [SVProgressHUD dismiss];
    [self.view endEditing:YES];
    if ([self.navigationController isKindOfClass:[QMNavigationController class]]) {
        [(QMNavigationController*)self.navigationController dismissNotificationPanel];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addKeyboardObservers];
}

#pragma mark - Keyboard Observers

- (void)addKeyboardObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];    
}

- (void)removeKeyboardObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)__unused notification{
  
}

- (void)keyboardWillHide:(NSNotification *) __unused notification{
    
}


- (void) viewDocument:(NSURL*) Url withCompletion:(void(^)(NSURL *filePath)) completion {
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
