//
//  CustomFileUpload.h
//  Denning
//
//  Created by Ho Thong Mee on 26/07/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMPhoto.h"

@interface CustomFileUpload : UITableViewController

@property (strong, nonatomic) NSString* url;
 @property (strong, nonatomic) NSString* API;
@property (strong, nonatomic)  NSString* nameCode;
    
@property (weak, nonatomic) IBOutlet UITextField *firmName;
@property (weak, nonatomic) IBOutlet UITextField *uploadedFile;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UITextField *renameFile;
@property (weak, nonatomic) IBOutlet UITextView *remarks;
@property (nonatomic) UIImagePickerController *imagePickerController;

- (void)changeBranch;

- (void) takePhoto;

- (void) uploadFile;

@end
