//
//  SimpleTableCell.h
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic) IBOutlet UITextField *usernameField;
@property (nonatomic) NSString *username;
//@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;

@end
