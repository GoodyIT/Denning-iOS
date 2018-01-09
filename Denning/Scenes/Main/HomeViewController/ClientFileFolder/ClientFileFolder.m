//
//  ClientFileFolder.m
//  Denning
//
//  Created by Ho Thong Mee on 26/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ClientFileFolder.h"
#import "FileNameAutoComplete.h"

@interface ClientFileFolder ()<UITextFieldDelegate>
{
    __block BOOL isLoading;
}

@end

@implementation ClientFileFolder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = MATTER_CLIENT_FILEFOLDER;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void) showPopup: (UIViewController*) vc {
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:vc];
    [STPopupNavigationBar appearance].barTintColor = [UIColor blackColor];
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Cochin" size:18], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;;
    popupController.containerView.layer.cornerRadius = 4;
    popupController.containerView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
    popupController.containerView.layer.shadowOffset = CGSizeMake(4, 4);
    popupController.containerView.layer.shadowOpacity = 1;
    popupController.containerView.layer.shadowRadius = 1.0;
    
    [popupController presentInViewController:self];
}

- (void) showAutocomplete:(NSString*) url {
    [self.view endEditing:YES];
    
    FileNameAutoComplete *vc = [[UIStoryboard storyboardWithName:@"Search" bundle:nil] instantiateViewControllerWithIdentifier:@"FileNameAutoComplete"];
    vc.url = url;
    vc.title = @"";
    vc.updateHandler =  ^(NSString* selectedString) {
        self.renameFile.text = selectedString;
    };
    
    [self showPopup:vc];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self showAutocomplete:@"denningwcf/v1/table/cboDocumentName?search="];
}

- (IBAction)didTapSend:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    
    if (self.imagePreview.image == nil) {
        [QMAlert showAlertWithMessage:@"Please select the file to upload" actionSuccess:NO inViewController:self];
        return;
    }
    if (self.renameFile.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please input the file name" actionSuccess:NO inViewController:self];
        return;
    }
    NSData* imageData = UIImageJPEGRepresentation(self.imagePreview.image, 1);
    NSString* fileNo1 = @"0";
    if (_model != nil) {
        fileNo1 = _model.key;
    }
    NSNumber* length = [NSNumber numberWithInteger:imageData.length];
    NSDictionary* params = @{@"fileNo1":fileNo1,
                             @"documents":@{
                                     @"FileName":[self.renameFile.text stringByAppendingString:@".jpg"],
                                     @"MimeType":@"jpg",
                                     @"dateCreate":[DIHelpers todayWithTime],
                                     @"dateModify":[DIHelpers todayWithTime],
                                     @"fileLength":length,
                                     @"remarks":self.remarks.text,
                                     @"base64":[self.imagePreview.image encodeToBase64String]
                                     }
                             };
    
    NSString* uploadURL;
    if ([[DataManager sharedManager].documentView isEqualToString:@"upload"]) {
        uploadURL = [[DataManager sharedManager].tempServerURL stringByAppendingString:self.url];
    } else {
        uploadURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString:self.url];
    }
    
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] uploadFileWithUrl:uploadURL params:params WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        self->isLoading = NO;
        if (error == nil && [result[0] isEqualToString:@"200"]) {
            [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
        } else {
            [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1)
    {
        return 3;
    }

    return 0;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self uploadFile];
        } else {
            [self takePhoto];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            if (self.imagePreview.image == nil) {
                return;
            }
            QMPhoto *photo = [[QMPhoto alloc] init];
            photo.image = self.imagePreview.image;
            
            NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:@[photo]];
            
            if ([self conformsToProtocol:@protocol(NYTPhotosViewControllerDelegate)]) {
                
                photosViewController.delegate = (UIViewController<NYTPhotosViewControllerDelegate> *)self;
            }
            
            [photosViewController updateImageForPhoto:photo];
            
            [self presentViewController:photosViewController animated:YES completion:nil];
        }
    }
    
   
}

@end
