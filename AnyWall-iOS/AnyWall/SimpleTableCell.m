//
//  SimpleTableCell.m
//  SimpleTable
//
//  Created by Simon Ng on 28/4/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell
@synthesize nameLabel = _nameLabel;
@synthesize usernameField = _usernameField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
//    [inputTexts replaceObjectAtIndex:textField.tag withObject:textField.text];
    if([self.usernameField.text length] == 0 && !self.usernameField.hidden){
        [self.usernameField setEnabled:false];
        [self.usernameField setHidden:true];
        [self.accessoryView setHidden:false];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    [inputTexts replaceObjectAtIndex:textField.tag withObject:textField.text];
    // SimpleTableCell *cell = [socialPickTable cellForRowAtIndexPath:path];
    
    if([self.usernameField.text length] == 0 && !self.usernameField.hidden){
        [self.usernameField setEnabled:false];
        [self.usernameField setHidden:true];
        [self.accessoryView setHidden:false];
    }
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
        return NO;
    }
    return YES;
}

@end
