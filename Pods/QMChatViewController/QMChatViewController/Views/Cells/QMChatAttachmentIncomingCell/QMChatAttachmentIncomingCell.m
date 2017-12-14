//
//  QMChatAttachmentIncomingCell.m
//  QMChatViewController
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatAttachmentIncomingCell.h"
//#import "QMProgressView.h"

@interface QMChatAttachmentIncomingCell()

//@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation QMChatAttachmentIncomingCell
//@synthesize attachmentID = _attachmentID;
//
//+ (QMChatCellLayoutModel)layoutModel {
//
//    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
//    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
//    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(4, 4, 4, 15),
//    defaultLayoutModel.topLabelHeight = 0;
//    defaultLayoutModel.bottomLabelHeight = 14;
//
//    return defaultLayoutModel;
//}
//
//
//- (void)awakeFromNib {
//
//    [super awakeFromNib];
//
//    _progressView.layer.masksToBounds = YES;
//    self.layer.masksToBounds = YES;
//}
//
//- (void)prepareForReuse {
//
//    [super prepareForReuse];
//
//    [self.progressView setProgress:0
//                          animated:NO];
//}
//
//
//- (void)layoutSubviews {
//
//    [super layoutSubviews];
//
//    UIImage *stretchableImage = self.containerView.backgroundImage;
//
//    _progressView.layer.mask = [self maskLayerFromImage:stretchableImage
//                                              withFrame:_progressView.bounds];
//}
//
//- (void)setCurrentTime:(NSTimeInterval)currentTime {
//
//    [super setCurrentTime:currentTime];
//
//    NSInteger duration = self.duration;
//
//    NSString *timeStamp = [self timestampString:currentTime
//                                    forDuration:duration];
//
//    self.durationLabel.text = timeStamp;
//
//    if (duration > 0) {
//        BOOL animated = self.viewState == QMMediaViewStateActive && currentTime > 0;
//        [self.progressView setProgress:currentTime/duration
//                              animated:animated];
//    }
//}


@end
