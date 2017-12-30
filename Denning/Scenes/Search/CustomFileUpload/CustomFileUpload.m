//
//  CustomFileUpload.m
//  Denning
//
//  Created by Ho Thong Mee on 26/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "CustomFileUpload.h"

#import "ChangeBranchViewController.h"
#import "SuggestedFileName.h"

@interface CustomFileUpload ()< UIImagePickerControllerDelegate, UINavigationControllerDelegate,
NYTPhotosViewControllerDelegate>

@end

@implementation CustomFileUpload

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) prepareUI {
    _url = MATTER_STAFF_FILEFOLDER;
    
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.view.frame), 50)];
    accessoryView.barTintColor = [UIColor groupTableViewBackgroundColor];
    accessoryView.tintColor = [UIColor babyRed];
    
    accessoryView.items = @[
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleTap)]];
    [accessoryView sizeToFit];
    self.remarks.inputAccessoryView = accessoryView;
}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.uploadedFile.placeholder = [@"IMG_" stringByAppendingString:[[[DIHelpers todayWithTime] stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    self.renameFile.text = self.uploadedFile.placeholder;
    self.imagePreview.image = [info valueForKey:UIImagePickerControllerOriginalImage];
    _imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //.. done dismissing
    }];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromButton:(UIBarButtonItem *)button
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle =
    (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    UIPopoverPresentationController *presentationController = imagePickerController.popoverPresentationController;
    presentationController.barButtonItem = button;  // display popover from the UIBarButtonItem as an anchor
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // The user wants to use the camera interface. Set up our custom overlay view for the camera
        
        /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
    }
    
    _imagePickerController = imagePickerController; // we need this for later
    
    [self presentViewController:self.imagePickerController animated:YES completion:^{
        //.. done presenting
    }];
}


- (void) handleTap {
    [self.view endEditing:YES];
}


- (void)changeBranch {
    if ([DataManager sharedManager].isPublicUser) {
        [QMAlert showAlertWithMessage:@"You cannot access this folder. please subscribe dening user" actionSuccess:NO inViewController:self];
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
    
    [[QMNetworkManager sharedManager] userSignInWithEmail:[DataManager sharedManager].user.email password:[DataManager sharedManager].user.password withCompletion:^(BOOL success, NSError * _Nonnull error, NSInteger statusCode, NSDictionary* responseObject) {
        [SVProgressHUD dismiss];
        if (success){
            [[DataManager sharedManager] setUserInfoFromLogin:responseObject];
            
            if ([DataManager sharedManager].isStaff){
                [self performSegueWithIdentifier:kChangeBranchSegue sender:[DataManager sharedManager].denningArray];
            } else if ([DataManager sharedManager].personalArray.count > 0) {
                [self performSegueWithIdentifier:kChangeBranchSegue sender:[DataManager sharedManager].personalArray];
            } else {
                [QMAlert showAlertWithMessage:@"No more branches" actionSuccess:NO inViewController:self];
            }
        }
    }];
}

- (void) takePhoto {
    //    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //    [self presentViewController:self.imagePicker animated:YES completion:nil];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        // Denies access to camera, alert the user.
        // The user has previously denied access. Remind the user that we need camera access to be useful.
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"Unable to access the Camera"
                                            message:@"To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app."
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (authStatus == AVAuthorizationStatusNotDetermined)
        // The user has not yet been presented with the option to grant access to the camera hardware.
        // Ask for it.
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
            // If access was denied, we do not set the setup error message since access was just denied.
            if (granted)
            {
                // Allowed access to camera, go ahead and present the UIImagePickerController.
                [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:nil];
            }
        }];
    else
    {
        // Allowed access to camera, go ahead and present the UIImagePickerController.
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera fromButton:nil];
    }
}

- (void) uploadFile {
    //    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    [self presentViewController:self.imagePicker animated:YES completion:nil];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary fromButton:nil];
}

#pragma mark - NYTPhotosViewControllerDelegate
- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.imagePreview;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kChangeBranchSegue]){
        ChangeBranchViewController* changeBranchVC = segue.destinationViewController;
        changeBranchVC.branchArray = sender;
        changeBranchVC.updateHandler = ^(FirmURLModel* model) {
            _API = model.firmServerURL;
            _firmName.text = model.name;
        };
    }
    
    if ([segue.identifier isEqualToString:kListWithCodeSegue]) {
        
        SuggestedFileName *listCodeVC = segue.destinationViewController;
        listCodeVC.url = sender;
        listCodeVC.updateHanlder = ^(NSDictionary *response) {
            _renameFile.text = [response valueForKeyNotNull:@"strSuggestedFilename"];
            _nameCode = [response valueForKeyNotNull:@"code"];
        };
    }
}

@end
