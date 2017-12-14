//
//  DIFileAttachmentOutgoingCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-13.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DIFileAttachmentOutgoingCell.h"

@implementation DIFileAttachmentOutgoingCell
#pragma mark - Default layout

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 12);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
