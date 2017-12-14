//
//  DIFileAttachmentIncomingCell.m
//  Denning
//
//  Created by Denning IT on 2017-12-13.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "DIFileAttachmentIncomingCell.h"

@implementation DIFileAttachmentIncomingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 12, 4, 4);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
