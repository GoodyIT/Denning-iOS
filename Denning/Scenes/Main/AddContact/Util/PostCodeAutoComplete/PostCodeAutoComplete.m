//
//  PostCodeAutoComplete.m
//  Denning
//
//  Created by Ho Thong Mee on 05/06/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "PostCodeAutoComplete.h"
#import "MLPAutoCompleteTextField.h"
#import "DEMOCustomAutoCompleteCell.h"
#import "DEMOCustomAutoCompleteObject.h"
#import "AFHTTPSessionOperation.h"

@interface PostCodeAutoComplete ()<UITextFieldDelegate,MLPAutoCompleteTextFieldDelegate, MLPAutoCompleteTextFieldDataSource
>
{
    NSString* customString;
    NSArray* cityArray;
    CityModel* curCity;
    NSString* serverAPI;
    NSString* sessionID;
}
@property (weak, nonatomic) IBOutlet MLPAutoCompleteTextField *autocompleteTF;
@end

@implementation PostCodeAutoComplete

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAutocompleteSearch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void) configureAutocompleteSearch {
    serverAPI = [DataManager sharedManager].user.serverAPI;
    sessionID = [DataManager sharedManager].user.sessionID;
    UIToolbar* _accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    _accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    _accessoryView.tintColor = [UIColor babyRed];
    
    _accessoryView.items = @[
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [_accessoryView sizeToFit];
    
    self.autocompleteTF.delegate = self;
    self.autocompleteTF.autoCompleteDataSource = self;
    self.autocompleteTF.autoCompleteDelegate = self;
    self.autocompleteTF.backgroundColor = [UIColor whiteColor];
    [self.autocompleteTF registerAutoCompleteCellClass:[DEMOCustomAutoCompleteCell class]
                                forCellReuseIdentifier:@"CustomCellId"];
    self.autocompleteTF.maximumNumberOfAutoCompleteRows = 7;
    self.autocompleteTF.applyBoldEffectToAutoCompleteSuggestions = YES;
    self.autocompleteTF.showAutoCompleteTableWhenEditingBegins = YES;
    self.autocompleteTF.disableAutoCompleteTableUserInteractionWhileFetching = YES;
    [self.autocompleteTF setAutoCompleteRegularFontName:@"SFUIText-Regular"];
    self.autocompleteTF.inputAccessoryView = _accessoryView;
    [self.autocompleteTF becomeFirstResponder];
    //    self.details.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    
    
    // add search icon to the left view
    self.autocompleteTF.leftViewMode = UITextFieldViewModeAlways;
    UIImageView* searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search_black"]];
    self.autocompleteTF.leftView = searchImageView;
}

- (void)handleTap {
    [self.view endEditing:YES];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    customString = textField.text;
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    customString = textField.text;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentSizeInPopup = CGSizeMake(250, 250);
    self.landscapeContentSizeInPopup = CGSizeMake(250, 250);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(nextBtnDidTap)];
    self.navigationController.title = @"Autocomplete / Select";
}

- (void) nextBtnDidTap
{
    [self selectCity];
    [self.popupController dismissWithCompletion:^{
        self.updateHandler(curCity);
    }];
}

#pragma mark - MLPAutoCompleteTextField DataSource

- (NSArray*) parseResponse: (id) response
{
    NSMutableArray* keywords = [NSMutableArray new];
    for (id obj in response) {
        [keywords addObject:[obj objectForKey:@"postcode"]];
    }
    
    cityArray = [CityModel getCityModelArrayFromResponse:response];
    
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
                                                                          if (((NSHTTPURLResponse *)task.response).statusCode == 408) { // Session expired.
                                                                              [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_SESSION_EXPIRED", nil) actionSuccess:NO inViewController:self];
                                                                          }
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

- (void) selectCity {
    BOOL isSame = NO;
    for (CityModel* model in cityArray) {
        if ([model.postcode isEqualToString:customString]) {
            curCity = model;
            curCity.postcode = customString;
            isSame = YES;
            break;
        }
    }
    
    if (!isSame) {
        curCity = [CityModel new];
        curCity.postcode = customString;
        curCity.city = @"";
        curCity.country = @"";
        curCity.state = @"";
    }
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    customString = selectedString;
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

@end
