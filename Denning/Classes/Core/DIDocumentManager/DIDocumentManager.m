//
//  DIDocumentManager.m
//  Denning
//
//  Created by Denning IT on 2017-12-13.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DIDocumentManager.h"

@interface DIDocumentManager()
{
    NSURL* selectedDocument;
}

@property (nonatomic, strong) AFURLSessionManager *manager;
@property (nonatomic, strong) UIViewController* viewController;
@end

@implementation DIDocumentManager

+ (instancetype) shared
{
    static DIDocumentManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DIDocumentManager alloc] init];
    });
    
    return manager;
}

- (instancetype) init {
    if (self = [super init]) {
        [self initManager];
    }
    
    return self;
}

- (void) initManager {
    
}

- (NSURL*) isAttachedFileExist:(NSString*) fileName
{
    NSURL* newPath = [self createNewDir:@"DenningITAttaches"];
    
    NSArray *directoryList = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:newPath
                                        includingPropertiesForKeys:nil
                                                           options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    __block NSURL* filePath = nil;
    [directoryList enumerateObjectsUsingBlock:^(NSURL*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.absoluteString containsString:fileName]) {
            filePath = obj;
            *stop = YES;
        }
    }];
    
    return filePath;
}

- (NSURL*) createNewDir:(NSString*) subDir {
    NSError* err = nil;
    NSFileManager *fm = [NSFileManager new];
    NSURL *documentsDirectory = [fm URLForDirectory:NSDocumentDirectory
                                           inDomain:NSUserDomainMask appropriateForURL:nil
                                             create:YES error:&err];
    
    NSURL* newPath = [documentsDirectory URLByAppendingPathComponent:subDir];
    [fm createDirectoryAtURL:newPath  withIntermediateDirectories:YES attributes:nil error:nil];
    
    return newPath;
}

- (void) downloadFileFromURL: (NSURL *) url withProgress:(void (^)(CGFloat progress))progressBlock completion:(void (^)(NSURL *filePath))completionBlock onError:(void (^)(NSError *error))errorBlock
{
    //Configuring the session manager
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    //Most URLs I come across are in string format so to convert them into an NSURL and then instantiate the actual request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    //Watch the manager to see how much of the file it's downloaded
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        //Convert totalBytesWritten and totalBytesExpectedToWrite into floats so that percentageCompleted doesn't get rounded to the nearest integer
        CGFloat written = totalBytesWritten;
        CGFloat total = totalBytesExpectedToWrite;
        CGFloat percentageCompleted = written/total;
        
        //Return the completed progress so we can display it somewhere else in app
        progressBlock(percentageCompleted);
    }];
    
    //Start the download
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //Getting the path of the document directory
        NSURL* newPath = [self createNewDir:@"DenningITAttaches"];
        
        return [newPath URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            selectedDocument = filePath;
            //If there's no error, return the completion block
            completionBlock(filePath);
        } else {
            //Otherwise return the error block
            errorBlock(error);
        }
    }];
    
    [downloadTask resume];
}

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withCompletion:(void(^)(NSURL *filePath)) completion {
    _viewController = viewController;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL* newPath = [self createNewDir:@"DenningIT"];
        
        return [newPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", [DIHelpers randomTime],[response suggestedFilename]]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        if (((NSHTTPURLResponse *)response).statusCode == 410) {
            [QMAlert showAlertWithMessage:@"Session expired. Please log in again." actionSuccess:NO inViewController:viewController];
        } else if (error == nil) {
            if  (filePath != nil) {
                [self displayDocument:filePath inView:viewController];
                selectedDocument = filePath;
                completion(filePath);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
    }];
    [downloadTask resume];
}

- (void)displayDocument:(NSURL*)document inView:(UIViewController*) viewController {
    _viewController = viewController;
    
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:_viewController];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return _viewController;
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:[selectedDocument path] error:&error];
}

@end
