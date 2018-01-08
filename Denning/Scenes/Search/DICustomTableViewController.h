//
//  DICustomTableViewController.h
//  Denning
//
//  Created by DenningIT on 21/04/2017.
//  Copyright © 2017 DenningIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICustomTableViewController : UITableViewController

- (void) configureMenuRightBtnWithImagename:(NSString*) imageName withSelector:(SEL) action;

- (void) setupFloatingButton;

@end
