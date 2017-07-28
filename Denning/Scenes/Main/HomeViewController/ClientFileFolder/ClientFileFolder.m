//
//  ClientFileFolder.m
//  Denning
//
//  Created by Ho Thong Mee on 26/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ClientFileFolder.h"

@interface ClientFileFolder ()
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


- (IBAction)didTapSend:(id)sender {
    if (isLoading) return;
    isLoading = YES;
    
//    if (self.uploadedFile.text.length == 0) {
//        [QMAlert showAlertWithMessage:@"Please select the file to upload" actionSuccess:NO inViewController:self];
//        return;
//    }
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
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:kListWithCodeSegue sender:SEARCH_UPLOAD_SUGGESTED_FILENAME];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
