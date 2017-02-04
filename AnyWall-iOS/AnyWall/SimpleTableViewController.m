//
//  SimpleTableViewController.m
//  SimpleTable
//
//  Created by Simon Ng on 16/4/12.
//  Copyright (c) 2012 AppCoda. All rights reserved.
//

#import "SimpleTableViewController.h"
#import "SimpleTableCell.h"

@interface SimpleTableViewController ()<UINavigationControllerDelegate>

@end

@implementation SimpleTableViewController
{
    NSMutableArray *tableData;
    NSMutableArray *inputTexts;
    NSMutableArray *usernames;
    UITableView *socialPickTable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Initialize table data
    inputTexts = [[NSMutableArray alloc] initWithObjects:@"",@"",@"",@"", nil];
   self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    socialPickTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    socialPickTable.dataSource = self;
    socialPickTable.delegate = self;
    socialPickTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    socialPickTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    
       

    [self.view addSubview:socialPickTable];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{

    PFQuery *query = [PFQuery queryWithClassName:@"socialMedia"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            
            tableData = [[NSMutableArray alloc] init];
            if(!object){
                PFObject *socialMedia = [PFObject objectWithClassName:@"socialMedia"];
                socialMedia[@"Snapchat"] = @"none";
                socialMedia[@"Instagram"] = @"none";
                socialMedia[@"Twitter"] = @"none";
                socialMedia[@"Facebook"] = @"none";
                socialMedia[@"user"] = [PFUser currentUser];
                [socialMedia saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        // The object has been saved.
                    } else {
                        // There was a problem, check error.description
                    }
                }];
                
                [tableData addObject:@"Snapchat"];
                [tableData addObject:@"Instagram"];
                [tableData addObject:@"Twitter"];
                [tableData addObject:@"Facebook"];
               
            }
            else{
                [usernames initWithCapacity:4];

                if([object[@"Snapchat"]  isEqualToString: @"none"]){
                    [tableData addObject:@"Snapchat"];
                    NSLog(@"SO MANY ROCKZoooo");

                }
                else{
                [tableData addObject:[NSString stringWithFormat:@"%@%@",@"Snapchat:", object[@"Snapchat"]]];
                    NSLog(@"%@",[usernames objectAtIndex:0]);
                    
                }
                if([object[@"Instagram"]  isEqualToString: @"none"]){
                    [tableData addObject:@"Instagram"];
                    
                }
                else{
                    [tableData addObject:[NSString stringWithFormat:@"%@%@",@"Instagram:", object[@"Instagram"]]];

                }
                
                if([object[@"Twitter"]  isEqualToString: @"none"]){
                    [tableData addObject:@"Twitter"];
                
                }
                else{
                    [tableData addObject:[NSString stringWithFormat:@"%@%@",@"Twitter:", object[@"Twitter"]]];
                    
                    
                }
                
                if([object[@"Facebook"]  isEqualToString: @"none"]){
                    [tableData addObject:@"Facebook"];
               
                }
                else{
                    [tableData addObject:[NSString stringWithFormat:@"%@%@",@"Facebook:", object[@"Facebook"]]];
                    
                    
                }
                

                
            
            }
           
            [socialPickTable reloadData];
            
            // NSLog(@"HELL NAW");
            
            
            
        } else {
            PFObject *socialMedia = [PFObject objectWithClassName:@"socialMedia"];
            socialMedia[@"Snapchat"] = @"none";
            socialMedia[@"Instagram"] = @"none";
            socialMedia[@"Twitter"] = @"none";
            socialMedia[@"Facebook"] = @"none";
            socialMedia[@"user"] = [PFUser currentUser];
            [socialMedia saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }];
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
            [tableData addObject:@"Snapchat"];
            [tableData addObject:@"Instagram"];
            [tableData addObject:@"Twitter"];
            [tableData addObject:@"Facebook"];
        }
    }];
    
    
//[socialPickTable reloadData];







}

-(void)saveButton{
    PFQuery *query = [PFQuery queryWithClassName:@"socialMedia"];
    NSMutableArray *newUsernames = [[NSMutableArray alloc] init];
     __block PFObject *socialMedia;
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
              } else {
            // The find succeeded.
            NSLog(@"Successfully retrieved the object.");
                  NSLog(@"The getFirstObject request failed.");
                  socialMedia = object;
                  
                  for (int i=0; i < [tableData count]; i++){ //nbPlayers is the number of rows in the UITableView
                      
                      SimpleTableCell *theCell = (id)[socialPickTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                      
                      NSString *playerName = theCell.usernameField.text;
                      if([[theCell.usernameField text] length]== 0){
                          NSLog(@"%@",@"fucki t");
                          [newUsernames addObject:playerName];
                          
                      }
                      
                      else{
                          NSLog(@"hot%@",playerName);
                          [newUsernames addObject:playerName];
                      }
                      
                      
                  }
                  
                  NSLog(@"%@", [newUsernames firstObject]);
                  NSString *snapName = [newUsernames objectAtIndex:0];
                  NSString *instaName = [newUsernames objectAtIndex:1];
                  NSLog(@"%@",snapName);
                  NSLog(@"FUDGE");
                  
                  if(snapName != nil){
                      NSLog(@"%@killyhrgdgrdrggrdgr",newUsernames[0]);
                      socialMedia[@"Snapchat"] = newUsernames[0];
                      
                  }
                  else{
                      NSLog(@"fudruckrers");
                      socialMedia[@"Snapchat"] = @"none";
                      
                  }
                  if([newUsernames[1] length] != 0){
                      NSLog(@"%@",newUsernames[1]);
                      
                      socialMedia[@"Instagram"] = newUsernames[1];
                  }
                  else{
                      socialMedia[@"Instagram"] = @"none";
                      
                  }
                  if([newUsernames[2] length] != 0){
                      socialMedia[@"Twitter"] = newUsernames[2];
                      
                  }
                  else{
                      socialMedia[@"Twitter"] = @"none";
                      
                  }
                  if([newUsernames[3] length] != 0){
                      socialMedia[@"Facebook"] = newUsernames[3];
                  }
                  else{
                      socialMedia[@"Facebook"] = @"none";
                      
                  }
                  [socialMedia saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                      if (succeeded) {
                          [self.navigationController popViewControllerAnimated:true];
                      } else {
                          // There was a problem, check error.description
                      }
                  }];
                  

        }
    }];

   
            
    
            
            
            
        
            // NSLog(@"HELL NAW");
            
            
            
      

 
    
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    SimpleTableCell *cell = (SimpleTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[SimpleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.usernameField.tag = indexPath.row;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];

   
    if(cell.usernameField == nil){
        cell.usernameField =[[UITextField alloc]initWithFrame:CGRectMake(cell.contentView.frame.size.width*0.74,
                                                                        cell.contentView.frame.size.height/4, 80, 30)];
        cell.usernameField.autoresizingMask=UIViewAutoresizingFlexibleHeight;
        cell.usernameField.autoresizesSubviews=YES;
        cell.usernameField.font = [UIFont systemFontOfSize:12.0f];
        [cell.usernameField setBorderStyle:UITextBorderStyleNone];
        if([[tableData objectAtIndex:indexPath.row] containsString:@":"])
        {
            NSArray* foo = [[tableData objectAtIndex:indexPath.row] componentsSeparatedByString: @":"];
            NSString* firstBit = [foo objectAtIndex: 0];
            NSString* secondBit = [foo objectAtIndex: 1];
            if([firstBit isEqualToString:@"empty"]){
                cell.usernameField.text = secondBit;
            }
            else if([firstBit isEqualToString:@"Snapchat"]){
                cell.textLabel.text = firstBit;
                cell.usernameField.text = secondBit;
                           }
            else if([firstBit isEqualToString:@"Instagram"]){
                cell.textLabel.text = firstBit;
                cell.usernameField.text = secondBit;
            }
            else if([firstBit isEqualToString:@"Twitter"]){
                cell.textLabel.text = firstBit;
                cell.usernameField.text = secondBit;
                
                            }
            else if([firstBit isEqualToString:@"Facebook"]){
                cell.textLabel.text = firstBit;
                cell.usernameField.text = secondBit;
              
            }
            [cell.usernameField setEnabled:true];
            [cell.usernameField setHidden:false];
            UIImageView *plusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Plus@3x.png"]];
            [cell setAccessoryView:plusImage];
            [cell.accessoryView setHidden:true];

        }
        
        else{
        
            cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
            UIImageView *plusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Plus@3x.png"]];
            [cell setAccessoryView:plusImage];
            [cell.usernameField setEnabled:false];
            [cell.usernameField setHidden:true];


        }
        [cell.usernameField setPlaceholder:@"Username"];
        cell.usernameField.delegate = self;
        
        [cell.contentView addSubview:cell.usernameField];
      
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    [tableData removeObjectAtIndex:indexPath.row];
    
    // Request table view to reload
    [tableView reloadData];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    SimpleTableCell *cell = [socialPickTable cellForRowAtIndexPath:indexPath];
    if([cell.usernameField.text length] == 0 && !cell.usernameField.hidden){
    [cell.usernameField setEnabled:false];
      [cell.usernameField setHidden:true];
      [cell.accessoryView setHidden:false];
    }
    
    
    
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        SimpleTableCell *cell = [socialPickTable cellForRowAtIndexPath:indexPath];
 

       [cell.usernameField setEnabled:true];
        [cell.usernameField setHidden:false];
        [cell.accessoryView setHidden:true];

    
    
    }
/**

       - (BOOL)textFieldShouldReturn:(UITextField *)textField
    {
        [textField resignFirstResponder];
        [inputTexts replaceObjectAtIndex:textField.tag withObject:textField.text];
        NSIndexPath *path = [NSIndexPath indexPathForRow:textField.tag inSection:0];
        SimpleTableCell *cell = [socialPickTable cellForRowAtIndexPath:path];
        if([cell.usernameField.text length] == 0 && !cell.usernameField.hidden){
            [cell.usernameField setEnabled:false];
           [cell.usernameField setHidden:true];
           [cell.accessoryView setHidden:false];
        }

        return YES;
    }

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [inputTexts replaceObjectAtIndex:textField.tag withObject:textField.text];
    NSIndexPath *path = [NSIndexPath indexPathForRow:textField.tag inSection:0];
   // SimpleTableCell *cell = [socialPickTable cellForRowAtIndexPath:path];
    SimpleTableCell *cell = (SimpleTableCell *)[socialPickTable cellForRowAtIndexPath:path];

    if([cell.usernameField.text length] == 0 && !cell.usernameField.hidden){
        [cell.usernameField setEnabled:false];
        [cell.usernameField setHidden:true];
        [cell.accessoryView setHidden:false];
    }
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
        return NO;
    }
    return YES;
}
**/
@end

