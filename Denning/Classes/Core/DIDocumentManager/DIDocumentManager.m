//
//  DIDocumentManager.m
//  Denning
//
//  Created by Denning IT on 2017-12-13.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DIDocumentManager.h"
#import <QuickLook/QuickLook.h>

@interface DIDocumentManager()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    NSURL* selectedDocument;
    BOOL isCustomPreview;
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

-(void)initiateQuickLoookController{
    
    QLPreviewController *previewController=[[QLPreviewController alloc]init];
    
    previewController.delegate=self;
    
    previewController.dataSource=self;
    
    [_viewController presentViewController:previewController animated:YES completion:nil];
    
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    return selectedDocument;
}

#pragma mark – delegate methods

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item

{
    return YES;
    
}

- (void) initManager {
    isCustomPreview = NO;
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

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withCompletion:(void(^)(NSURL *filePath)) completion withCustomParam:(NSString*) custom
{
    if ([custom isEqualToString:@"custom"]) {
        isCustomPreview = YES;
    }
    
    [self viewDocument:Url inViewController:viewController withCompletion:completion];
}

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withData:(id) data forPost:(BOOL) isPost withFileName:(NSString*) fileName withCompletion:(void(^)(NSURL *filePath)) completion
{
    _viewController = viewController;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:Url];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[DataManager sharedManager].user.email  forHTTPHeaderField:@"webuser-id"];
    [request setValue:[DataManager sharedManager].user.sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    if (isPost) {
        [request setHTTPMethod:@"POST"];
        NSError* error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
        [request setHTTPBody:postData];
    }
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL* newPath = [self createNewDir:@"DenningIT"];
        
        NSURL* fileURL;
        if (fileName.length != 0) {
            fileURL = [newPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
        } else {
            fileURL = [newPath URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [response suggestedFilename]]];
        }
        
        return fileURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [SVProgressHUD dismiss];
        if (((NSHTTPURLResponse *)response).statusCode == 408) {
            [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_SESSION_EXPIRED", nil) actionSuccess:NO inViewController:viewController];
            [DataManager sharedManager].isSessionExpired = YES;
        } else if (error == nil) {
            if  (filePath != nil) {
                [self displayDocument:filePath inView:viewController];
                selectedDocument = filePath;
                completion(filePath);
            }
        } else if (((NSHTTPURLResponse *)response).statusCode == 404) {
            [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_FILE_NOT_FOUNT", nil) actionSuccess:NO inViewController:viewController];
        } else  {
            [QMAlert showAlertWithMessage:error.localizedDescription actionSuccess:NO inViewController:viewController];
        }
    }];
    [downloadTask resume];
}

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withData:(id) data withCompletion:(void(^)(NSURL *filePath)) completion {
    [self viewDocument:Url inViewController:viewController withData:data forPost:NO withFileName:@"" withCompletion:completion];
}

- (void) viewDocument:(NSURL*) Url inViewController:(UIViewController*) viewController withCompletion:(void(^)(NSURL *filePath)) completion {
    [self viewDocument:Url inViewController:viewController withData:nil withCompletion:completion];
}

- (void)displayDocument:(NSURL*)document inView:(UIViewController*) viewController {
    _viewController = viewController;
    
    UIDocumentInteractionController *documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:document];
    documentInteractionController.delegate = self;
    [documentInteractionController presentPreviewAnimated:YES];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
    return _viewController;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(nullable NSString *)application
{
    NSLog(@"%@", application);
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
    NSError *error;
//    [[NSFileManager defaultManager] removeItemAtPath:[selectedDocument path] error:&error];
}

@end
