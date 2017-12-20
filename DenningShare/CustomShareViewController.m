//
//  CustomShareViewController.m
//  Denning
//
//  Created by Ho Thong Mee on 27/08/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CustomShareViewController.h"
#import "ContactListViewController.h"
#import "FileListViewController.h"
#import "StaffModel.h"
#import "SearchResultModel.h"
@import MobileCoreServices;
#import "DIGlobal.h"
#import "MLPAutoCompleteTextField.h"
#import "DEMOCustomAutoCompleteCell.h"
#import "CoreDataOperation.h"
#import "Items.h"
#import "GetJSONOperation.h"
#import "Constants.h"
#import "NSString+URLEncoding.h"
#import "RequestObject.h"


@interface CustomShareViewController ()<NSURLSessionDelegate, UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource, UIDocumentInteractionControllerDelegate>
{
    NSString* fileNo1, *contactKey, *fileKey;
    NSURL* openedItem;
    NSString* fileType;
    NSString* base64Data;
    NSNumber* fileLength;
    NSURLSession* mySession;
    NSString* userType, *customString;
    NSUserDefaults* defaults;
    
    BOOL isLoading;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *fileName;
@property (weak, nonatomic) IBOutlet UITextView *remarks;
@property (weak, nonatomic) IBOutlet UILabel *uploadToLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *uploadToValue;

@property (strong, nonatomic) UIAlertController *uploadingIndicator;

@property (strong, nonatomic) NSString* url;
@property RequestObject *requestDataObject;
@end

@implementation CustomShareViewController

//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];

    [self prepareUI];

    [self configureFileNameAutoComplete];
    
    [self registerForKeyboardNotifications];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_fileName.isFirstResponder) {
        [_fileName resignFirstResponder];
    }
}

UIImage *QMStatusBarBackgroundImage(void) {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

UIColor *QMSecondaryApplicationColor() {
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:74.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}


// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSNumber* durationValue  = info[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    

    NSInteger options = UIViewAnimationOptionCurveLinear;
    
    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - kbSize.height/2, self.view.frame.size.width, self.view.frame.size.height);
    } completion:nil];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSNumber* durationValue  = info[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    
    NSInteger options = UIViewAnimationOptionCurveLinear;
    
    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + kbSize.height/2, self.view.frame.size.width, self.view.frame.size.height);
    } completion:nil];
}

- (void) getDataFromItem:(NSURL*) item
{
    NSData* imgData;
    if ([(NSObject*)item isKindOfClass:[NSURL class]]) {
        imgData = [NSData dataWithContentsOfURL:item];
    }
    
    if ([(NSObject*)item isKindOfClass:[UIImage class]]) {
        imgData = UIImagePNGRepresentation((UIImage*)item);
    }
    
    fileLength = [NSNumber numberWithInteger:imgData.length];

    base64Data = [[NSData dataWithContentsOfFile:(NSString*)item] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (void) prepareUI {
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    for (NSItemProvider* itemProvider in ((NSExtensionItem*)self.extensionContext.inputItems[0]).attachments) {
        if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeImage]) {
            [itemProvider loadItemForTypeIdentifier:(NSString*)kUTTypeImage options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                [self getDataFromItem:(NSURL*)item];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // When the task has completed.
                     self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:(NSString*)item ]];
                });
               
                fileType = [(NSString*)item pathExtension];
            }];
        } else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString*)kUTTypePDF]){
            dispatch_async(dispatch_get_main_queue(), ^{
                // When the task has completed.
                self.imageView.image = [UIImage imageNamed:@"share_pdf"];
            });
            
            [itemProvider loadItemForTypeIdentifier:(NSString*)kUTTypePDF options:nil completionHandler:^(id<NSSecureCoding>  _Nullable item, NSError * _Null_unspecified error) {
                openedItem = (NSURL*)item;
                [self getDataFromItem:(NSURL*)item];
                fileType = [(NSString*)item pathExtension];
            }];
        }
    }
    
    fileNo1 = @"Transit Folder";

    self.sendBtn.enabled = YES;
    self.segmented.hidden = YES;
    NSUserDefaults* defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.denningshare.extension"];
    userType = [defaults valueForKey:@"userType"];
    
    self.url = MATTER_STAFF_TRANSIT_FOLDER;
    
    if (userType == nil) {
        [self showAlertWithMessage:@"You cannot upload file. please login into Denning." actionSuccess:NO inViewController:self];
        self.sendBtn.enabled = NO;
        return;
    }
    if (![userType isEqualToString:@"denning"]) {
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
    
    // Add Tap to imageview
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage)];
    gesture.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:gesture];
}

- (void) didTapImage {
    if ([fileType isEqualToString:@"pdf"]) {
        [self displayDocument:openedItem];
    }
}

- (void) configureFileNameAutoComplete {
    _fileName.autoCompleteDataSource = self;
    _fileName.delegate = self;
    _fileName.autoCompleteDelegate = self;
    _fileName.backgroundColor = [UIColor whiteColor];
    [_fileName registerAutoCompleteCellClass:[DEMOCustomAutoCompleteCell class]
                      forCellReuseIdentifier:@"CustomCellId"];
    _fileName.maximumNumberOfAutoCompleteRows = 3;
    _fileName.applyBoldEffectToAutoCompleteSuggestions = YES;
    _fileName.showAutoCompleteTableWhenEditingBegins = YES;
    _fileName.disableAutoCompleteTableUserInteractionWhileFetching = YES;
    [_fileName setAutoCompleteRegularFontName:@"Helvetica"];
    [_fileName setAutoCompleteBoldFontName:@"Helvetica-Bold"];
    [_fileName setAutoCompleteFontSize:13];
    
    UIToolbar* _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    _accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    _accessoryView.tintColor = [UIColor redColor];
    
    _accessoryView.items = @[
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [_accessoryView sizeToFit];
    _fileName.inputAccessoryView = _accessoryView;
    _remarks.inputAccessoryView = _accessoryView;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
//    [self showAutocomplete:@"denningwcf/v1/table/cboDocumentName?search=letter&pagesize=5"];
}

- (IBAction)didTapUploadTo:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.uploadToValue.text = @"Transit Folder";
        self.uploadToLabel.text = @"Transit Folder";
        self.url = MATTER_STAFF_TRANSIT_FOLDER;
        fileNo1 = @"Transit Folder";
    } else if (sender.selectedSegmentIndex == 1) {
        self.uploadToValue.text = @"File Folder";
        if (fileKey.length > 0) {
            self.uploadToValue.text = fileKey;
        }
        self.url = MATTER_STAFF_FILEFOLDER;
        fileNo1 = fileKey;
        [self performSegueWithIdentifier:@"FileListGetSegue" sender:nil];
    } else {
        self.uploadToValue.text = @"Contact Folder";
        if (contactKey.length > 0) {
            self.uploadToValue.text = contactKey;
        }
        fileNo1 = contactKey;

        self.url = MATTER_STAFF_CONTACT_FOLDER;
        [self performSegueWithIdentifier:@"ContactGetlistSegue" sender:nil];
    }
}

- (IBAction)didTapCancel:(id)sender {
    NSError* error;
    [self.extensionContext cancelRequestWithError:error];
}

- (IBAction)didTapSend:(id)sender {

    if ([userType isEqualToString:@""]) {
        [self showAlertWithMessage:@"You cannot upload file. please login" actionSuccess:NO inViewController:self];
        return;
    } 
    
    if (self.segmented.selectedSegmentIndex == 2 && fileNo1.length == 0) {
        [self showAlertWithMessage:@"Please select the correct contact." actionSuccess:NO inViewController:self];
        self.segmented.selectedSegmentIndex = 0;
        self.uploadToValue.text = @"Transit Folder";
        return;
    }
    if (self.segmented.selectedSegmentIndex == 1 && fileNo1.length == 0) {
        [self showAlertWithMessage:@"Please select the correct contact." actionSuccess:NO inViewController:self];
        self.segmented.selectedSegmentIndex = 0;
        self.uploadToValue.text = @"Transit Folder";
        return;
    }
    
    [self.view endEditing:YES];
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

- (NSURLSession *) configureMySession {
    if (!mySession) {
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"group.denningshare.extension"];
        // To access the shared container you set up, use the sharedContainerIdentifier property on your configuration object.
        config.sharedContainerIdentifier = @"group.denningshare.extension";
        mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return mySession;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    if (isLoading) return;
    isLoading = YES;
    
    if (self.fileName.text.length == 0) {
        [self showAlertWithMessage:@"Please input the file name" actionSuccess:NO inViewController:self];
        return;
    }
    
    self.uploadingIndicator = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Uploading..."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [self.uploadingIndicator addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull __unused action) {
        
    }]];
    
    [self presentViewController:self.uploadingIndicator animated:YES completion:nil];

  
    NSString* name = [NSString stringWithFormat:@"%@.%@", self.fileName.text, fileType];
    
    NSDictionary* params = @{@"fileNo1":fileNo1,
                             @"FileName":name,
                             @"MimeType": fileType,
                             @"dateCreate":[self todayWithTime],
                             @"dateModify":[self todayWithTime],
                             @"fileLength":fileLength,
                             @"remarks":self.remarks.text,
                             @"base64":base64Data
                             };
    
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
                                                              options:0 error:nil];
    //                NSString* bodyStr = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    NSURLSession* session = [self configureMySession];
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        NSURLSessionDataTask *task = [session
                                      dataTaskWithRequest: request];
        [task resume];
    });
}

- (void)URLSession:(NSURLSession *)session
dataTask:(NSURLSessionDataTask *)dataTask
didReceiveData:(NSData *)data{
//    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    NSLog(@"data %@", dataArray);

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

    isLoading = NO;
    if (!error) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self showAlertWithMessage:@"Success" actionSuccess:YES inViewController:self];
    }
}

- (NSArray*) separateNameIntoTwo:(NSString*) title
{
    NSMutableArray *items = [[title componentsSeparatedByString:@"("] mutableCopy];
    if ([items count] > 1) {
        items[1] = [items[1] substringToIndex:((NSString*)items[1]).length-1];
    } else {
        [items addObject:@""];
    }
    
    
    return items;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    self.requestDataObject = [RequestObject new];
    [self.requestDataObject setIncompleteString:[string urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    [self.requestDataObject setCompletionBlock:handler];
    NSString* urlString = [NSString stringWithFormat:@"%@denningwcf/v1/table/cboDocumentName?search=%@", [defaults valueForKey:@"api"], string];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *downloadURL = [NSURL URLWithString:urlString];
    GetJSONOperation *operation = [[GetJSONOperation alloc] initWithDownloadURL:downloadURL
                                                            withCompletionBlock:self.requestDataObject.completionBlock];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - MLPAutoCompleteTextField Delegate

- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    cell.textLabel.text = autocompleteString;
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    customString = selectedString;
    _fileName.text = selectedString;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
    
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ContactGetlistSegue"]) {
        ContactListViewController* contactVC = segue.destinationViewController;
        contactVC.url = GENERAL_CONTACT_URL;
        contactVC.updateHandler = ^(SearchResultModel *model) {
            self.uploadToValue.text = contactKey = [model.JsonDesc valueForKey:@"name"];
            
            fileNo1 = model.key;
        };
    } else if ([segue.identifier isEqualToString:@"FileListGetSegue"]) {
        FileListViewController* vc = segue.destinationViewController;
        vc.url = GENERAL_MATTER_LISTING_URL;
        vc.updateHandler = ^(SearchResultModel *model) {
            if ([model.title containsString:@"File No."]) {
                fileKey = [self separateNameIntoTwo:[model.title substringFromIndex:10]][1];
            } else {
                fileKey = [self separateNameIntoTwo:model.title][1];
            }
            self.uploadToValue.text = fileKey;
            
            fileNo1 = model.key;
        };
    }
}
@end
