//
//  CustomShareViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 27/08/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CustomShareViewController.h"
#import "ContactListViewController.h"
#import "StaffModel.h"
@import MobileCoreServices;
#import "DIGlobal.h"
//#import "UIImage+Base64.h"

@interface CustomShareViewController ()<NSURLSessionDelegate>
{
    NSString* selectedContactCode;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *fileName;
@property (weak, nonatomic) IBOutlet UITextView *remarks;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *uploadToLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *uploadToValue;

@property (strong, nonatomic) NSString* url;
@end

@implementation CustomShareViewController

//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments) {
        if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeImage]) {
            [itemProvider loadItemForTypeIdentifier:(NSString*)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
          //      self.imageView.image = (UIImage*)item;
            }];
        }
    }

    selectedContactCode = @"";
    self.activity.hidden = YES;
    self.sendBtn.enabled = YES;
    self.segmented.hidden = YES;
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    NSString* userType = [defaults valueForKey:@"userType"];
    if (userType == nil) {
        [self showAlertWithMessage:@"You cannot upload file. please login into Denning." actionSuccess:NO inViewController:self];
        self.sendBtn.enabled = NO;
        return;
    }
    if (![[defaults valueForKey:@"userType"] isEqualToString:@"denning"]) {
        self.uploadToLabel.hidden = YES;
        self.segmented.hidden = YES;
        self.topConstraint.constant = 0;
        self.bottomConstraint.constant = 0;
    } else {
        self.uploadToLabel.hidden = NO;
        self.segmented.hidden = NO;
        self.topConstraint.constant = 16;
        self.bottomConstraint.constant = 21;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapUploadTo:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.uploadToLabel.text = @"Transit Folder";
        self.url = MATTER_STAFF_TRANSIT_FOLDER;
    } else if (sender.selectedSegmentIndex == 1) {
        self.uploadToLabel.text = @"File Folder";
        self.url = MATTER_STAFF_FILEFOLDER;
    } else {
        self.uploadToLabel.text = @"Contact Folder";
        self.url = MATTER_STAFF_CONTACT_FOLDER;
        [self performSegueWithIdentifier:@"ContactGetlistSegue" sender:nil];
    }
}

- (IBAction)didTapCancel:(id)sender {
    NSError* error;
    [self.extensionContext cancelRequestWithError:error];
}

- (IBAction)didTapSend:(id)sender {
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    if ([[defaults valueForKey:@"userType"] isEqualToString:@""]) {
        [self showAlertWithMessage:@"You cannot upload file. please login" actionSuccess:NO inViewController:self];
        return;
    } else if (![[defaults valueForKey:@"userType"] isEqualToString:@"denning"]) {
        self.url = MATTER_CLIENT_FILEFOLDER;
    } else {
        self.url = MATTER_STAFF_TRANSIT_FOLDER;
    }
    
    if (self.segmented.selectedSegmentIndex == 2 && selectedContactCode.length == 0) {
        [self showAlertWithMessage:@"Please slect the correct contact." actionSuccess:NO inViewController:self];
        self.segmented.selectedSegmentIndex = 0;
        return;
    }
    
    
    
    [self.view endEditing:YES];
    self.activity.hidden = NO;
    [self.activity startAnimating];
    [self didSelectPost];
}

- (void)showAlertWithMessage:(NSString *)message actionSuccess:(BOOL)success inViewController:(UIViewController *)viewController {
    
    NSString *title = success ? NSLocalizedString(@"Success", nil) : NSLocalizedString(@"Error", nil);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        
    }]];
    
    [viewController presentViewController:alertController animated:YES completion:nil];
}

- (NSString*) todayWithTime {
    NSString* date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[[NSTimeZone localTimeZone] secondsFromGMT]/3600];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments) {
        if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeImage]) {
            [itemProvider loadItemForTypeIdentifier:(NSString*)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                NSData* imgData;
                if ([(NSObject*)item isKindOfClass:[NSURL class]]) {
                    imgData = [NSData dataWithContentsOfURL:(NSURL*) item];
                }
                
                if ([(NSObject*)item isKindOfClass:[UIImage class]]) {
                    imgData = UIImagePNGRepresentation((UIImage*)item);
                }
                
                
                if (self.fileName.text.length == 0) {
                                        [self showAlertWithMessage:@"Please input the file name" actionSuccess:NO inViewController:self];
                    return;
                }
                
                NSString* fileNo1 = @"0";
                
                self.imageView.image = [UIImage imageWithData:imgData];
                
                NSNumber* length = [NSNumber numberWithInteger:imgData.length];
                NSDictionary* params = @{@"fileNo1":fileNo1,
                                         @"FileName":[self.fileName.text stringByAppendingString:@".jpg"],
                                         @"MimeType":@"jpg",
                                         @"dateCreate":[self todayWithTime],
                                         @"dateModify":[self todayWithTime],
                                         @"fileLength":length,
                                         @"remarks":self.remarks.text,
                                         @"base64":[UIImagePNGRepresentation((UIImage*)item) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]
                                         };
                NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
                // Create the request.
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[(NSString*)[defaults valueForKey:@"api"] stringByAppendingString:self.url]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0];
                
                
                
                // Specify that it will be a POST request
                [request setHTTPMethod:  @"POST"];
                
                // This is how we set header fields
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [request setValue:[defaults valueForKey:@"sessionID"]  forHTTPHeaderField:@"webuser-sessionid"];
                [request setValue:[defaults valueForKey:@"email"] forHTTPHeaderField:@"webuser-id"];
                
                // Convert your data and set your request's HTTPBody property
                //                NSString *stringData = @"some data";
                NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:params
                                                                          options:0 error:&error];
                //                NSString* bodyStr = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
                request.HTTPBody = requestBodyData;
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.denningshare.extension"];
                configuration.sharedContainerIdentifier = @"group.denningshare.extension";
                NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    NSURLSessionDataTask *task = [session
                                                  dataTaskWithRequest: request];
                    [task resume];
                });
            }];
        }
    }
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)URLSession:(NSURLSession *)session
dataTask:(NSURLSessionDataTask *)dataTask
didReceiveData:(NSData *)data{
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler{
    NSLog(@"%s",__func__);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    NSLog(@"%s",__func__);
    [self.activity stopAnimating];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ContactGetlistSegue"]) {
        ContactListViewController* contactVC = segue.destinationViewController;
        contactVC.url = CONTACT_GETLIST_URL;
        contactVC.updateHandler = ^(StaffModel *model) {
            self.uploadToLabel.text = model.name;
        };
    }
}

@end
