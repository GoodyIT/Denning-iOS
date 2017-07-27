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

@interface FileUpload ()< UIImagePickerControllerDelegate, UINavigationControllerDelegate,
NYTPhotosViewControllerDelegate>
{
    __block BOOL isLoading;
    NSString *systemNo;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *folderSegment;
@property (weak, nonatomic) IBOutlet UILabel *uploadTo;

@end

@implementation FileUpload

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissScreen:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSend:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    if (self.firmName.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the firm to upload" actionSuccess:NO inViewController:self];
        return;
    }

    if (self.uploadedFile.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please select the file to upload" actionSuccess:NO inViewController:self];
        return;
    }
    if (self.renameFile.text.length == 0) {
        [QMAlert showAlertWithMessage:@"Please input the file name" actionSuccess:NO inViewController:self];
        return;
    }
    NSData* imageData = UIImageJPEGRepresentation(self.imagePreview.image, 1);
    NSNumber* length = [NSNumber numberWithInteger:imageData.length];
    NSDictionary* params = @{@"fileNo1":systemNo,
                             @"FileName":[self.renameFile.text stringByAppendingString:@".jpg"],
                             @"MimeType":@"jpg",
                             @"dateCreate":[DIHelpers todayWithTime],
                             @"dateModify":[DIHelpers todayWithTime],
                             @"fileLength":length,
                             @"remarks":self.remarks.text,
                             @"base64":[self.imagePreview.image encodeToBase64String]
                             };
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    __weak UINavigationController *navigationController = self.navigationController;
    @weakify(self);
    [[QMNetworkManager sharedManager] uploadFileWithUrl:self.url params:params WithCompletion:^(NSArray * _Nonnull result, NSError * _Nonnull error) {
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

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        return 2;
    } else if (section == 3)
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
        [self changeBranch];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self uploadFile];
        } else {
            [self takePhoto];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kSimpleMatterSegue sender:nil];
        }
    } else if (indexPath.section == 3) {
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
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kListWithCodeSegue sender:SEARCH_UPLOAD_SUGGESTED_FILENAME];
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
