//
//  EventCell.m
//  Denning
//
//  Created by DenningIT on 01/02/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "EventCell.h"

@interface EventCell()
@property (weak, nonatomic) IBOutlet UILabel *counsel;
@property (weak, nonatomic) IBOutlet UIView *sideBar;

@property (weak, nonatomic) IBOutlet UILabel *caseNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventStartDatelabel;
@property (weak, nonatomic) IBOutlet UILabel *eventStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@end

@implementation EventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithEvent:(EventModel*) event
{
    self.subjectLabel.text = event.caseName.uppercaseString;
    self.caseNoLabel.text = event.caseNo;
    self.locationLabel.text = event.location;
    self.eventStartDatelabel.text = [DIHelpers getOnlyDateFromDateTime:event.eventStart];
    self.dayLabel.text = [DIHelpers getDayFromDate:event.eventStart];
    self.eventStartTimeLabel.text = [DIHelpers getTimeFromDate:event.eventStart];
    self.counsel.text = event.counsel;
    
    if ([event.eventType isEqualToString:@"1court"]) {
        _eventStartDatelabel.textColor = [UIColor babyRed];
        _dayLabel.textColor = [UIColor babyRed];
        _eventStartTimeLabel.textColor = [UIColor babyRed];
        _sideBar.backgroundColor = [UIColor babyRed];
    } else if ([event.eventType isEqualToString:@"2office"]) {
        _eventStartDatelabel.textColor = [UIColor babyBlue];
        _dayLabel.textColor = [UIColor babyBlue];
        _eventStartTimeLabel.textColor = [UIColor babyBlue];
        _sideBar.backgroundColor = [UIColor babyBlue];
    } else if ([event.eventType isEqualToString:@"3personal"]) {
        _eventStartDatelabel.textColor = [UIColor orangeColor];
        _dayLabel.textColor = [UIColor orangeColor];
        _eventStartTimeLabel.textColor = [UIColor orangeColor];
        _sideBar.backgroundColor = [UIColor orangeColor];
    }
}

@end
