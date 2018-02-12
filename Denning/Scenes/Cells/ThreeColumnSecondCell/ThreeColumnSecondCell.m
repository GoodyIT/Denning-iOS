//
//  ThreeColumnSecondCell.m
//  Denning
//
//  Created by Ho Thong Mee on 28/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import "ThreeColumnSecondCell.h"

@implementation ThreeColumnSecondCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) configureCellWithModel:(FeeUntransferModel*) model
{
    _fileNo.text = model.fileNo;
    _fileName.text = model.fileName;
    _invoiceNo.text = model.invoiceNo;
    _amount.text = [DIHelpers addThousandsSeparatorWithDecimal:model.fee];
}

- (void) sconfigureCellWithContactFolderItem:(ContactFolderItem*) model {
    _fileNo.text = model.strContactName;
    _fileName.text = model.strContactID;
    _invoiceNo.text = [DIHelpers getDateInShortForm:model.dtLastModified];
    _amount.text = model.strItemCount;
}


- (void) configureCellWithDict:(NSDictionary*) dict
{
    _fileNo.text = [dict valueForKeyNotNull:@"fileNo"];
    _fileName.text = [dict valueForKeyNotNull:@"fileName"];
    _invoiceNo.text = [dict valueForKeyNotNull:@"invoiceNo"];
    _amount.text = [DIHelpers addThousandsSeparatorWithDecimal:[dict valueForKeyNotNull:@"fee"]];
}

@end
