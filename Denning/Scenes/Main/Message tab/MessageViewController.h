//
//  MessageViewController.h
//  Denning
//
//  Created by DenningIT on 04/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DICustomViewController.h"

@interface MessageViewController : DICustomViewController

@property (weak, nonatomic) IBOutlet UIView *companySelectionView;
@property (weak, nonatomic) IBOutlet UIStackView *chatOptionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageViewerTopConstraint;

- (void) updateBadge;

@end
