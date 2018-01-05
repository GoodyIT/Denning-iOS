//
//  QMTableViewCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"
#import "QMImageView.h"
#import "QMPlaceholder.h"

@interface QMTableViewCell ()

/**
 *  Outlets
 */
@property (weak, nonatomic) IBOutlet QMImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;

@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@end

@implementation QMTableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView {
    
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    NSParameterAssert(nib);
    
    NSString *cellIdentifier = [self cellIdentifier];
    NSParameterAssert(cellIdentifier);
    
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
}

+ (NSString *)cellIdentifier {
    
    return NSStringFromClass([self class]);
}

+ (CGFloat)height {
    return 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _avatarImage.imageViewType = QMImageViewTypeCircle;
    
    _titleLabel.text = nil;
    _bodyLabel.text = nil;

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    tap.cancelsTouchesInView = NO;
    [self.avatarImage addGestureRecognizer:tap];
}

- (void) handleTap {
    _didTapAvatar(self);
}

//MARK: - Setters

- (void)setTitle:(NSString *)title
       avatarUrl:(NSString *)avatarUrl {
    
    self.titleLabel.text = title;
    
    NSURL *url = [NSURL URLWithString:avatarUrl];
    [self.avatarImage setImageWithURL:url
                                title:title
                       completedBlock:nil];
}

// Custom
- (void) configureCellWithChatDialog:(QBChatDialog*) dialog {
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImage.bounds title:dialog.name ID:[dialog.ID integerValue]];
    
    [self.avatarImage setImageWithURL:[NSURL URLWithString:dialog.photo]
                          placeholder:placeholder
                              options:SDWebImageLowPriority
                             progress:nil
                       completedBlock:nil];
}

- (void) configureCellWithUser: (QBUUser*) user {
    NSString* userName = user.fullName;
    if (user.fullName == nil) {
        userName = NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil);
    }

    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:_avatarImage.frame title:userName ID:user.ID];
    
    [self.avatarImage setImageWithURL:[NSURL URLWithString:user.avatarUrl]
                              placeholder:placeholder
                                  options:SDWebImageLowPriority
                                 progress:nil
                           completedBlock:nil];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setBody:(NSString *)body {
    self.bodyLabel.text = body;
}

- (void) setPosition:(NSString*) position
{
    self.positionLabel.text = position;
}

@end
