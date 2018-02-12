//
//  OfficeDiaryViewController.h
//  Denning
//
//  Created by Ho Thong Mee on 22/05/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfficeDiaryViewController : BaseTableViewController

@property(strong, nonatomic) OfficeDiaryModel* officeDiary;

- (void) saveDiary;
@end
