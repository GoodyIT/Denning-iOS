//
//  SearchMatterCell.m
//  Denning
//
//  Created by DenningIT on 28/03/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "SearchMatterCell.h"
@interface SearchMatterCell()
{
    NSString* fileNo;
    SearchResultModel* _model;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *paymentRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *fileFolderBtn;
@property (weak, nonatomic) IBOutlet UIButton *fileNoteBtn;

@end

@implementation SearchMatterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.paymentRecordBtn.titleLabel.minimumScaleFactor = 0.5f;
    self.paymentRecordBtn.titleLabel.numberOfLines = 0;   
    self.paymentRecordBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.fileFolderBtn.titleLabel.minimumScaleFactor = 0.5f;
    self.fileFolderBtn.titleLabel.numberOfLines = 0;
    self.fileFolderBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.fileNoteBtn.titleLabel.minimumScaleFactor = 0.5f;
    self.fileNoteBtn.titleLabel.numberOfLines = 0;
    self.fileNoteBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.titleLabel.copyingEnabled = YES;
    self.headerLabel.copyingEnabled = YES;
    self.descriptionLabel.copyingEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithSearchModel: (SearchResultModel*) model
{
    self.titleLabel.text = model.title;
    self.headerLabel.text = model.header;
    self.descriptionLabel.text = model.searchDescription;
    
    fileNo = model.key;
    _model = model;
}

- (IBAction)fileFolderTapped:(id)sender {
    [self.delegate didTapFileFolder:self];
}

- (IBAction)ledgerTapped:(id)sender {
    [self.delegate didTapLedger:self];
}

- (IBAction)tempateTapped:(id)sender {
    [self.delegate didTapTemplate:self withModel:_model];
}

- (IBAction)uploadTapped:(id)sender {
    [self.delegate didTapUpload:self fileNo:_model.title];
}

- (IBAction)paymentRecordTapped:(id)sender {
    [self.delegate didTapPaymentRecord:self fileNo:fileNo];
}

- (IBAction)fileNoteTapped:(id)sender {
    [self.delegate didTapFileNote:self];
}

@end
