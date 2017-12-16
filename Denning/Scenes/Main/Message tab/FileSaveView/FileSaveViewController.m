//
//  FileSaveViewController.m
//  Denning
//
//  Created by Denning IT on 2017-12-16.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileSaveViewController.h"
#import "MLPAutoCompleteTextField.h"
#import "DEMOCustomAutoCompleteCell.h"
#import "DashboardContact.h"
#import "FileListViewController.h"
#import "AFHTTPSessionOperation.h"

@interface FileSaveViewController ()<MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource>
{
    NSString* fileNo1, *contactKey, *fileKey;
    NSURL* openedItem;
    NSString* fileType;
    NSString* base64Data;
    NSNumber* fileLength;
    
    NSString* customString;
    NSString* serverAPI;
    NSString* sessionID;
    
    __block BOOL isLoading;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *fileName;
@property (weak, nonatomic) IBOutlet UITextView *remarks;

@property (weak, nonatomic) IBOutlet UILabel *uploadToValue;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmented;

@property (strong, nonatomic) NSString* url;
@end

@implementation FileSaveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareUI];
    
    [self configureFileNameAutoComplete];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_fileName.isFirstResponder) {
        [_fileName resignFirstResponder];
    }
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWillShow:(NSNotification*)aNotification
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
- (void)keyboardWillHide:(NSNotification*)aNotification
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

- (void) prepareUI {
    fileNo1 = @"Transit Folder";
    _fileName.text = [[_fileURL.absoluteString lastPathComponent] stringByDeletingPathExtension];
    fileType = [_fileURL.absoluteString pathExtension];
    
    [[DIDocumentManager shared] downloadFileFromURL:_fileURL withProgress:^(CGFloat progress) {
        [SVProgressHUD showProgress:progress maskType:SVProgressHUDMaskTypeClear];
    } completion:^(NSURL *filePath) {
        [SVProgressHUD dismiss];
        openedItem = filePath;
        NSData* data = [NSData dataWithContentsOfURL:filePath];
        fileLength = [NSNumber numberWithInteger:data.length];
        
        base64Data = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    } onError:^(NSError *error) {
         [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
   
    // Add Tap to imageview
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImage)];
    gesture.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:gesture];
}

- (void) didTapImage {
//    [[DIDocumentManager shared] displayDocument:openedItem inView:self];
    
    [[DIDocumentManager shared] viewDocument:_fileURL inViewController:self withCompletion:^(NSURL *filePath) {
        openedItem = filePath;
    }];
}

- (void) configureFileNameAutoComplete {
    serverAPI = [DataManager sharedManager].user.serverAPI;
    sessionID = [DataManager sharedManager].user.sessionID;
    
    _fileName.autoCompleteDataSource = self;
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

- (IBAction)didTapUploadTo:(UISegmentedControl*)sender {
    
    if (sender.selectedSegmentIndex == 0) {
        self.uploadToValue.text = @"Transit Folder";
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSend:(id)sender {
    
    if (self.segmented.selectedSegmentIndex == 2 && fileNo1.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the correct contact." actionSuccess:NO inViewController:self];
        self.segmented.selectedSegmentIndex = 0;
        self.uploadToValue.text = @"Transit Folder";
        return;
    }
    if (self.segmented.selectedSegmentIndex == 1 && fileNo1.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the correct contact." actionSuccess:NO inViewController:self];
        self.segmented.selectedSegmentIndex = 0;
        self.uploadToValue.text = @"Transit Folder";
        return;
    }
    
    [self.view endEditing:YES];
    [self didSelectPost];
}

- (void)didSelectPost {
 // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
 
 if (isLoading) return;
 isLoading = YES;
 
 if (self.fileName.text.length == 0) {
     [QMAlert showAlertWithMessage:@"Please input the file name" actionSuccess:NO inViewController:self];
     return;
 }
 
 NSString* name = [NSString stringWithFormat:@"%@.%@", self.fileName.text, fileType];
 
 NSDictionary* params = @{@"fileNo1":fileNo1,
                          @"FileName":name,
                          @"MimeType": fileType,
                          @"dateCreate":[DIHelpers todayWithTime],
                          @"dateModify":[DIHelpers todayWithTime],
                          @"fileLength":fileLength,
                          @"remarks":self.remarks.text,
                          @"base64":base64Data
                          };
 
 // Create the request.
    NSString* saveURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString:_url];
    [[QMNetworkManager sharedManager] sendPrivatePostWithURL:saveURL params:params completion:^(NSDictionary * _Nonnull result, NSError * _Nonnull error, NSURLSessionDataTask * _Nonnull task) {
        
    }];
}

- (NSArray*) parseResponse: (id) response
{
    NSMutableArray* keywords = [NSMutableArray new];
    for (id obj in response) {
        [keywords addObject:[obj valueForKeyNotNull:@"strSuggestedFilename"]];
    }
    
    return keywords;
}

//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler
{
    if ([NSOperationQueue mainQueue].operationCount > 0) {
        [[NSOperationQueue mainQueue] cancelAllOperations];
    }
    
    [[QMNetworkManager sharedManager].manager.requestSerializer setValue:sessionID  forHTTPHeaderField:@"webuser-sessionid"];
    
    NSString* autocompleteUrl = [NSString stringWithFormat:@"%@%@%@", serverAPI, self.url, [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    NSOperation *operation = [AFHTTPSessionOperation operationWithManager:[QMNetworkManager sharedManager].manager
                                                               HTTPMethod:@"GET"
                                                                URLString:autocompleteUrl
                                                               parameters:nil
                                                           uploadProgress:nil
                                                         downloadProgress:nil
                                                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                                                      NSLog(@"%@", responseObject);
                                                                      
                                                                      handler([self parseResponse:responseObject]);                     } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                                                                          NSLog(@"%@", error);
                                                                      }];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ContactGetlistSegue"]) {
        UINavigationController* nav = segue.destinationViewController;
        DashboardContact* vc = nav.viewControllers.firstObject;
        vc.url = GENERAL_CONTACT_URL;
        vc.callback = @"callback";
        vc.updateHandler = ^(SearchResultModel *model) {
            self.uploadToValue.text = contactKey = [model.JsonDesc valueForKey:@"name"];
            
            fileNo1 = model.key;
        };
    } else if ([segue.identifier isEqualToString:@"FileListGetSegue"]) {
        FileListViewController* vc = segue.destinationViewController;
        vc.url = GENERAL_MATTER_LISTING_URL;
        vc.updateHandler = ^(SearchResultModel *model) {
            if ([model.title containsString:@"File No."]) {
                fileKey = [DIHelpers separateNameIntoTwo:[model.title substringFromIndex:10]][1];
            } else {
                fileKey = [DIHelpers separateNameIntoTwo:model.title][1];
            }
            self.uploadToValue.text = fileKey;
            
            fileNo1 = model.key;
        };
    }
}

@end
