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
#import "QMImagePicker.h"

@interface CustomFileUpload ()< UIImagePickerControllerDelegate, UINavigationControllerDelegate,
NYTPhotosViewControllerDelegate,
QMImagePickerResultHandler>

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
    imagePickerController.allowsEditing = NO;
    imagePickerController.modalPresentationStyle =
    (sourceType == UIImagePickerControllerSourceTypeCamera) ? UIModalPresentationFullScreen : UIModalPresentationPopover;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    // iOS is going to calculate a size which constrains the 4:3 aspect ratio
    // to the screen size. We're basically mimicking that here to determine
    // what size the system will likely display the image at on screen.
    // NOTE: screenSize.width may seem odd in this calculation - but, remember,
    // the devices only take 4:3 images when they are oriented *sideways*.
    float cameraAspectRatio = 4.0 / 3.0;
    float imageWidth = floorf(screenSize.width * cameraAspectRatio);
    float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
    
    imagePickerController.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
    
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
        [QMAlert showAlertWithMessage:NSLocalizedString(@"STR_ACCESS_DENIED_REGISTER", nil) withTitle:@"Access Restricted" actionSuccess:NO inViewController:self withCallback:^{
            [self performSegueWithIdentifier:kAuthSegue sender:nil];
        }];
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
    [QMImagePicker takePhotoOrVideoInViewController:self
                                        maxDuration:kQMMaxAttachmentDuration
                                            quality:UIImagePickerControllerQualityTypeMedium
                                      resultHandler:self
                                      allowsEditing:NO];
}

- (void) uploadFile {
    [QMImagePicker chooseFromGaleryInViewController:self
                                        maxDuration:kQMMaxAttachmentDuration
                                      resultHandler:self
                                      allowsEditing:NO
                                          mediaType:@[(NSString *)kUTTypeImage]];
}

- (void) displayPhoto:(UIImage*) photo {
    self.uploadedFile.placeholder = [@"IMG_" stringByAppendingString:[[[DIHelpers todayWithTime] stringByReplacingOccurrencesOfString:@":" withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    self.renameFile.text = self.uploadedFile.placeholder;
    self.imagePreview.image =photo;
}

- (void)imagePicker:(QMImagePicker *)__unused imagePicker
didFinishPickingPhoto:(UIImage *)photo {
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        if (imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImage *newImage = [photo fixOrientation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayPhoto: newImage];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayPhoto: photo];
            });
        }
    });
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
