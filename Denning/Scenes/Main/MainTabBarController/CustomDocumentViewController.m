//
//  CustomDocumentViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 26/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CustomDocumentViewController.h"

@interface CustomDocumentViewController ()

@end

@implementation CustomDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDocument:(NSString*) Url {
    NSString *urlString = [NSString stringWithFormat:@"%@denningwcf/v1/%@", [DataManager sharedManager].user.serverAPI, Url];
    NSURL *url = [NSURL URLWithString:[urlString  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    [SVProgressHUD showWithStatus:@"Loading"];
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
        if (filePath != nil)
            [self displayDocument:filePath];
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
