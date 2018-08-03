//
//  FileUpload.m
//  Denning
//
//  Created by Ho Thong Mee on 19/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "FileUpload.h"

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMPhoto.h"
#import "SimpleMatterViewController.h"
#import "FileNameAutoComplete.h"

@interface FileUpload ()< UIImagePickerControllerDelegate, UINavigationControllerDelegate,
NYTPhotosViewControllerDelegate, UITextFieldDelegate>
{
    __block BOOL isLoading;
    NSString *systemNo;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *folderSegment;
@property (weak, nonatomic) IBOutlet UILabel *fileNoLabel;

@property (weak, nonatomic) IBOutlet UILabel *uploadTo;

@end

@implementation FileUpload

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fileNoLabel.text = [[_titleValue componentsSeparatedByString:@":"][1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    systemNo = [DIHelpers separateFileNameAndNoFromTitle:_titleValue][0];
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
    
    FileNameAutoComplete *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FileNameAutoComplete"];
    vc.url = url;
    vc.title = @"";
    vc.updateHandler =  ^(NSString* selectedString) {
        self.renameFile.text = selectedString;
    };
    
    [self showPopup:vc];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self showAutocomplete:@"v1/table/cboDocumentName?search="];
}

- (IBAction)didTapSend:(id)sender {
    if (isLoading) return;
    isLoading = YES;

    if (self.imagePreview.image == nil) {
        [QMAlert showAlertWithMessage:@"Please select the file to upload." actionSuccess:NO inViewController:self];
        return;
    }
    if (self.renameFile.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please input the file name." actionSuccess:NO inViewController:self];
        return;
    }
    NSData* imageData = UIImageJPEGRepresentation(self.imagePreview.image, 0.5);
    NSNumber* length = [NSNumber numberWithInteger:imageData.length];
    NSString* fileName = [NSString stringWithFormat:@"IMG_%@%@.jpg",  self.renameFile.text, [DIHelpers randomTime]];
    NSDictionary* params = @{@"fileNo1":systemNo,
                             @"documents":@[@{
                                     @"FileName":fileName,
                                     @"MimeType":@"jpg",
                                     @"dateCreate":[DIHelpers todayWithTime],
                                     @"dateModify":[DIHelpers todayWithTime],
                                     @"fileLength":length,
                                     @"remarks":self.remarks.text,
                                     @"base64":[self.imagePreview.image encodeToBase64String]
                                     }]
                             };
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    NSString* uploadURL = [[DataManager sharedManager].user.serverAPI stringByAppendingString:self.url];
    if ([[DataManager sharedManager].documentView isEqualToString:@"upload"]) {
        uploadURL = [[DataManager sharedManager].tempServerURL stringByAppendingString:self.url];
    }
    
    @weakify(self);
    [[QMNetworkManager sharedManager] uploadFileWithUrl:uploadURL params:params WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
        @strongify(self)
        if (self == nil) {
            return;
        }
        self->isLoading = NO;
        if (error == nil) {
            if ([result[0] isEqualToString:@"200"]) {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"Success" duration:1.0];
            } else {
                [navigationController showNotificationWithType:QMNotificationPanelTypeSuccess message:@"If you face this message again, please contact Denning support." duration:1.0];
            }
        } else {
           [navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:error.localizedDescription duration:1.0];
        }
    }];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 2;
    } else if (section == 2)
    {
        return 3;
    }
    return 0;
}
- (IBAction)didFolderChanged:(UISegmentedControl*)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.url = MATTER_STAFF_TRANSIT_FOLDER;
            break;
        case 1:
            self.url = MATTER_STAFF_FILEFOLDER;
            break;
        case 2:
            self.url = MATTER_STAFF_CONTACT_FOLDER;
            break;
            
        default:
            break;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self uploadFile];
        } else {
            [self takePhoto];
        }
    } else if (indexPath.section ==1) {
//        if (indexPath.row == 1) {
//            [self performSegueWithIdentifier:kSimpleMatterSegue sender:nil];
//        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            if (self.imagePreview.image == nil) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                return;
            }
            QMPhoto *photo = [[QMPhoto alloc] init];
            photo.image = self.imagePreview.image;
            
            NYTPhotoViewerSinglePhotoDataSource *photoDataSource =
            [NYTPhotoViewerSinglePhotoDataSource dataSourceWithPhoto:photo];
            
            NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithDataSource:photoDataSource];
            
            if ([self conformsToProtocol:@protocol(NYTPhotosViewControllerDelegate)]) {
                
                photosViewController.delegate = (UIViewController<NYTPhotosViewControllerDelegate> *)self;
            }
            
//            [photosViewController updateImageForPhoto:photo];
            
            [self presentViewController:photosViewController animated:YES completion:nil];
        } else if (indexPath.row == 1) {
//            [self performSegueWithIdentifier:kListWithCodeSegue sender:SEARCH_UPLOAD_SUGGESTED_FILENAME];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kSimpleMatterSegue]) {
        SimpleMatterViewController* matterVC = segue.destinationViewController;
        matterVC.title = @"Upload To";
        matterVC.updateHandler = ^(MatterSimple *model) {
            systemNo = model.systemNo;
            _uploadTo.text = model.primaryClient.name;
        };
        
    }
}


@end
