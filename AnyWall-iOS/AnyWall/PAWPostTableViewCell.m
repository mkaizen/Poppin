//
//  PAWPostTableViewCell.m
//  Anywall
//
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import "PAWPostTableViewCell.h"

#import "PAWPost.h"

CGFloat const PAWPostTableViewCellLabelsFontSize = 12.0f;

static CGFloat const PAWPostTableViewCellBackgroundImageLeadingSideInset = 0.0f;

static UIEdgeInsets const PAWPostTableViewCellContentInset = {.top = 0.0f, .left = 0.0f, .bottom = 0.0f, .right = 0.0f};
static UIEdgeInsets const PAWPostTableViewCellTextContentInset = {.top = 6.0f, .left = 20.0f, .bottom = 5.0f, .right = 45.5f};
static UIEdgeInsets const PAWPostPictureText = {.top = 206.0f, .left = 35.0f, .bottom = 5.0f, .right = 10.5f};
PAWPost *thePost;
UIImage *likeImage;



BOOL isTherePic = NO;
static CGFloat const PAWPostTableViewCellDetailTextLabelTopInset = 3.0f;

@interface PAWPostTableViewCell ()
{
    UIImageView *_backgroundImageView;
}

@property (nonatomic, assign, readwrite) PAWPostTableViewCellStyle postTableViewCellStyle;

@end

@implementation PAWPostTableViewCell

#pragma mark -
#pragma mark Class


+ (CGSize)sizeThatFits:(CGSize)boundingSize forPost:(PAWPost *)post {
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, boundingSize.width, boundingSize.height);
    bounds = UIEdgeInsetsInsetRect(bounds, PAWPostTableViewCellContentInset);
  
        bounds = UIEdgeInsetsInsetRect(bounds, PAWPostTableViewCellTextContentInset);
  
   // bounds = UIEdgeInsetsInsetRect(bounds, PAWPostTableViewCellTextContentInset);
    boundingSize = bounds.size;
    NSString *text = post.title;
   
    NSString *username = post.subtitle;
    UIImageView *picture;
    UIImageView *like;
    
        NSDictionary *textAttributes = @{ NSFontAttributeName : [self postTableViewCellStyleLabelsFont] };
        
        // Calculate what the frame to fit the post text and the username
        CGRect textRect = [text boundingRectWithSize:boundingSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:textAttributes
                                             context:nil];
    
    //post.object[@"postSize"] = @(CGRectGetHeight(textRect));
    //[post.object saveInBackground];
   // NSLog(@"@%@",post.object[@"postSize"]);
        CGRect nameRect = [username boundingRectWithSize:boundingSize
                                                 options:NSStringDrawingTruncatesLastVisibleLine
                                              attributes:textAttributes
                                                 context:nil];
    
    
        CGSize size = CGSizeZero;
        size.width = ceilf(boundingSize.width +
                           PAWPostTableViewCellContentInset.left +
                           PAWPostTableViewCellContentInset.right +
                           PAWPostTableViewCellTextContentInset.left +
                           PAWPostTableViewCellTextContentInset.right);
        size.height = ceilf(CGRectGetHeight(textRect)+13.0 +
                            CGRectGetHeight(nameRect)*2 +
                            PAWPostTableViewCellContentInset.top +
                            PAWPostTableViewCellContentInset.bottom +
                            PAWPostTableViewCellDetailTextLabelTopInset +
                            PAWPostTableViewCellTextContentInset.top +
                            PAWPostTableViewCellTextContentInset.bottom);
        return size;
        isTherePic = NO;
    
    
 
}

#pragma mark Private

+ (UIFont *)postTableViewCellStyleLabelsFont {
    return [UIFont systemFontOfSize:PAWPostTableViewCellLabelsFontSize];
}

+ (UIImage *)backgroundImageForPostTableViewCellStyle:(PAWPostTableViewCellStyle)style {
    switch (style) {
        case PAWPostTableViewCellStyleLeft:
            return [UIImage imageNamed:@"bubble_grey"];
            break;
        case PAWPostTableViewCellStyleRight:
            return [UIImage imageNamed:@"bubble_green"];
            break;
    }
    return nil;
}

+ (UIColor *)textLabelColorForPostTableViewCellStyle:(PAWPostTableViewCellStyle)style {
    switch (style) {
        case PAWPostTableViewCellStyleLeft:
           // return [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];
            return [UIColor darkTextColor];
           // return [UIColor whiteColor];
            break;
        case PAWPostTableViewCellStyleRight:
           // return [UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f];

            return [UIColor darkTextColor];
            //return [UIColor whiteColor];
            break;
    }

    return nil;
}

+ (UIColor *)detailTextLabelColorForPostTableViewCellStyle:(PAWPostTableViewCellStyle)style {
    switch (style) {
        case PAWPostTableViewCellStyleLeft:
           // return [UIColor colorWithRed:43.0f/255.0f green:181.0f/255.0f blue:46.0f/255.0f alpha:1.0f];
            return [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
            break;
        case PAWPostTableViewCellStyleRight:
            return [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
            break;
    }

    return nil;
}

#pragma mark -
#pragma mark Init

- (instancetype)initWithPostTableViewCellStyle:(PAWPostTableViewCellStyle)style
                               reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        _postTableViewCellStyle = style;

        _backgroundImageView = [[UIImageView alloc] initWithImage:[[self class] backgroundImageForPostTableViewCellStyle:style]];
        [self.contentView addSubview:_backgroundImageView];

        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [[self class] postTableViewCellStyleLabelsFont];
        self.textLabel.textColor = [[self class] textLabelColorForPostTableViewCellStyle:style];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;

        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.font = [[self class] postTableViewCellStyleLabelsFont];
        self.detailTextLabel.textColor = [[self class] detailTextLabelColorForPostTableViewCellStyle:style];
        self.detailTextLabel.numberOfLines = 0;
           }
    UIImage *likeImage = [UIImage imageNamed: @"like@2x.png"];
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.frame = CGRectMake(self.contentView.frame.size.width*0.83, self.detailTextLabel.frame.origin.y+28, 22, 22);
    NSLog(@"image frame: %@", NSStringFromCGRect(self.likeButton.frame));
    [self.likeButton setImage:likeImage forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(buttonTappedAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.likeButton];
    
    UILabel *numLikes =  [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width*0.90, self.detailTextLabel.frame.origin.y+28, 20, 20)];
    [numLikes setFont:[UIFont systemFontOfSize:18]];
    numLikes.backgroundColor = [UIColor clearColor];
    numLikes.textAlignment = NSTextAlignmentCenter;
    // numLikes.textColor = [UIColor colorWithRed:220.0f/255.0f green:220.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    numLikes.numberOfLines = 0;
    NSLog(@"THE LOG SCORE : %f", self.contentView.frame.size
          .width);
    NSLog(@"100M SCORE : %f", self.detailTextLabel.frame.origin.y);
    
    NSLog(@"THEE : %f", self.likeButton.frame.size.width);
    
    // NSLog(@"image frame: %@", NSStringFromCGRect(cell.likeButton.frame));
    [self.contentView addSubview:numLikes];
    self.numberOfLikes = numLikes;

    return self;
}


#pragma mark -
#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
  
    CGRect textBounds;
    const CGRect bounds = UIEdgeInsetsInsetRect(self.contentView.bounds, PAWPostTableViewCellContentInset);

    for (UIView*subview in self.contentView.subviews)
    {
        [subview layoutIfNeeded];
    
    }

  
    textBounds = UIEdgeInsetsInsetRect(bounds, PAWPostTableViewCellTextContentInset);

    if(self.tag == 1)
    {
        self.profilePic.frame = CGRectMake(22, self.detailTextLabel.frame.origin.y+36, 24, 24);
    }
    else
    {
        self.profilePic.frame = CGRectMake(22, self.textLabel.frame.origin.y+self.textLabel.frame.size.height+6, 24, 24);

    }

    NSDictionary *textAttributes = @{ NSFontAttributeName : self.textLabel.font };

    // Set the cell element content sizes
    CGRect textLabelFrame = [self.textLabel.text boundingRectWithSize:textBounds.size
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:textAttributes
                                                              context:nil];
    textLabelFrame.origin.x += textBounds.origin.x;
    
    textLabelFrame.origin.y +=textBounds.origin.y;
    //textLabelFrame.origin.y = 0;
    
    self.textLabel.frame = CGRectIntegral(textLabelFrame);

    CGRect detailTextLabelFrame = [self.detailTextLabel.text boundingRectWithSize:textBounds.size
                                                                          options:NSStringDrawingUsesLineFragmentOrigin                                                                       attributes:textAttributes
                                                                          context:nil];
    detailTextLabelFrame.origin.x += textBounds.origin.x+35;
    detailTextLabelFrame.origin.y += CGRectGetMaxY(textLabelFrame) + PAWPostTableViewCellDetailTextLabelTopInset;
    self.detailTextLabel.frame = CGRectIntegral(detailTextLabelFrame);

    CGRect backgroundImageViewFrame = bounds;
    backgroundImageViewFrame.origin.x += (self.postTableViewCellStyle == PAWPostTableViewCellStyleLeft ?
                                          0.0f :
                                          PAWPostTableViewCellBackgroundImageLeadingSideInset);
	backgroundImageViewFrame.size.width -= PAWPostTableViewCellBackgroundImageLeadingSideInset;
    _backgroundImageView.frame = backgroundImageViewFrame;
    
}

- (IBAction)buttonTappedAction:(id)sender
{
 //   CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView]; // maintable --> replace your tableview name
  //  NSIndexPath *clickedButtonIndexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
//    PFObject *touchedObject = [self.objects objectAtIndex:clickedButtonIndexPath.row];
//    PAWPostTableViewCell *cell = [self.tableView cellForRowAtIndexPath:clickedButtonIndexPath];
    UIButton *button = (UIButton *)sender;
    PFObject *postObject = [thePost object];
    button.selected = ![button isSelected]; // Important line
    if (button.selected)
    {
        NSLog(@"Selected");
        [button setImage: [UIImage imageNamed:@"liked@2x.png"] forState:UIControlStateNormal];
        
        
        
        PFRelation *relation = [postObject relationForKey:@"likers"];
        PFQuery *query = [[postObject relationForKey:@"likers"] query];
        [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // [objects count] > 0 if the wine is already a favorite
            if([objects count] > 0)
            {
                
                
            }else{
                [relation addObject:[PFUser currentUser]];
                
                self.numberOfLikes.hidden = NO;
                [[thePost object]  incrementKey:@"likes" byAmount:[NSNumber numberWithInt:1]];
                self.numberOfLikes.text =  [[thePost object] [@"likes"] stringValue];
                
                [postObject saveInBackground];
            }
        }];
        
        //    [touchedObject incrementKey:@"likes" byAmount:[NSNumber numberWithInt:1]];
        
    //    NSLog(@"%i",button.tag);
    }
    else
    {
        NSLog(@"Un Selected");
        if([postObject [@"likes"]  isEqual: @1])
        {
            self.numberOfLikes.hidden = YES;
        }
        [button setImage: [UIImage imageNamed:@"like@2x.png"] forState:UIControlStateNormal];
        PFRelation *relation = [postObject  relationForKey:@"likers"];
        [relation removeObject:[PFUser currentUser]];
        PFQuery *query = [[postObject  relationForKey:@"likers"] query];
        [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            // [objects count] > 0 if the wine is already a favorite
            if([objects count] > 0)
            {
                [relation removeObject:[PFUser currentUser]];
                
                self.numberOfLikes.hidden = YES;
                [postObject  incrementKey:@"likes" byAmount:[NSNumber numberWithInt:-1]];
                self.numberOfLikes.text =  [postObject [@"likes"] stringValue];
                
                [postObject saveInBackground];
                
            }else{
                
            }
        }];
        
        // [touchedObject incrementKey:@"likes" byAmount:[NSNumber numberWithInt:-1]];
        //  cell.numberOfLikes.text =  [touchedObject[@"likes"] stringValue];
        //  [touchedObject saveInBackground];
        
    //    NSLog(@"%i",button.tag);
    }
    
}

#pragma mark -
#pragma mark Update
- (void)updateFromPost:(PAWPost *)post {
    thePost = post;
    for (UIImageView *subview in self.contentView.subviews)
    {
        if (subview.tag == 99)
        {
            [subview removeFromSuperview];
        }
        if(subview.tag == 69)
        {
            [subview removeFromSuperview];
        }
    }
    self.textLabel.text = post.title;
    UIImageView *imageView;
    //UIImageView *likeView;
    
    PFRelation *relation = [thePost.object relationForKey:@"likers"];
    PFQuery *relationQuery = [relation query];
    [relationQuery findObjectsInBackgroundWithBlock:^(NSArray *likers, NSError *error) {
        if (error) {
        }
        else {
            self.numberOfLikes.text =  [NSString stringWithFormat:@"%@",  @([likers count])];

            if([likers count] > 0)
            {
                self.numberOfLikes.hidden = NO;

                for (PFUser *friend in likers) {
                    if([friend.objectId isEqual:[PFUser currentUser].objectId])
                    {
                        UIImage *likeImage = [UIImage imageNamed: @"liked@2x.png"];
        
                        [self.likeButton setImage:likeImage forState:UIControlStateNormal];
                        // [self.likeButton setTag:69];
                       
                       
                    }
                    else{
                        self.numberOfLikes.hidden = YES;

                    }
                 
                
            }
              
            }
            else
            {
                
                UIImage *likeImage = [UIImage imageNamed: @"like@2x.png"];
                self.numberOfLikes.hidden = YES;
                [self.likeButton setImage:likeImage forState:UIControlStateNormal];
         
              //  [self.likeButton setTag:69];
              
            }
        }
    }];
    
  

  //  [self.numberOfLikes setTag:69];
 //   self.numberOfLikes.text =  [thePost.object[@"likes"] stringValue];

    
    self.numberOfLikes.font = [UIFont systemFontOfSize:14.0];

  
    
   /**
    likeView = [[UIImageView alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width*0.75, self.detailTextLabel.frame.origin.y+5, 30, 30)];
    
    likeView.image = likeImage;
    likeView.backgroundColor = [UIColor clearColor];
    [likeView.layer setMasksToBounds:YES];
    likeView.clipsToBounds = YES;
    
    [likeView setTag:69];
    [self.contentView addSubview:likeView];
    **/
    if(self.tag == 1)
    {
        self.profilePic= [[UIImageView alloc]initWithFrame:CGRectMake(22, self.detailTextLabel.frame.origin.y+34, 24, 24)];
    }
    else
    {
        self.profilePic = [[UIImageView alloc]initWithFrame:CGRectMake(22, self.textLabel.frame.origin.y+self.textLabel.frame.size.height+6, 24, 24)];
    }
    
   /**
    UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Speech Bubble@2x.png"]];
    messageIcon.frame = CGRectMake( 20,self.detailTextLabel.frame.origin.y+40, 18.0f, 18.0f);
    [messageIcon setTag:99];
    [self.contentView addSubview:messageIcon];
    **/
    self.profilePic.backgroundColor = [UIColor clearColor];
    [self.profilePic.layer setCornerRadius:12.0f];
    [self.profilePic.layer setMasksToBounds:YES];
    self.profilePic.clipsToBounds = YES;
  
   self.profilePic.layer.borderColor = [[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0f] CGColor];
   self.profilePic.layer.borderWidth = 0.5f;
    [self.profilePic setTag:99];
    [self.contentView addSubview:self.profilePic];
    
    if(post.image != nil){
    UIImageView *pictureImage;
    UIImage *image = [UIImage imageNamed: @"picture.png"];
    

    pictureImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width*0.72, self.detailTextLabel.frame.origin.y+5, 25, 25)];
    
    pictureImage.image = image;
    pictureImage.backgroundColor = [UIColor clearColor];
    [pictureImage.layer setMasksToBounds:YES];
    pictureImage.clipsToBounds = YES;
    
    [pictureImage setTag:69];
    [self.contentView addSubview:pictureImage];
    }
    PFFile *imageFile = [post.user objectForKey:@"profileImageThumb"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
        if (!error) {
            UIImage *image = [UIImage imageWithData:result];
            [self.profilePic setImage:image];

        }
    }];

   // self.detailTextLabel.text = post.subtitle;
    
    long seconds = lroundf(post.object.createdAt.timeIntervalSinceNow); // Since modulo operator (%) below needs int or long
    
    int hour = -(seconds / 3600);
    int mins = -((seconds % 3600) / 60);
    if(post.object[@"commentCount"] == nil){
        NSString *commentString = @"no comments";

        
       
        if (mins < 1) {
            
            NSString *intervalString = [NSString stringWithFormat:@"posted %ld seconds ago", -seconds];
            NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentString];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentString length],[commentString length])];
            [self.detailTextLabel setAttributedText: string];
         
        }
        
        else if (hour < 1) {
            NSString *intervalString = [NSString stringWithFormat:@"posted %d minutes ago", mins];
             NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentString];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentString length],[commentString length])];
            [self.detailTextLabel setAttributedText: string];
        }
        else if (hour == 1) {
            NSString *intervalString = [NSString stringWithFormat:@"posted %d hour ago", hour];
            NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentString];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentString length],[commentString length])];
            [self.detailTextLabel setAttributedText: string];
   }
        else{
            NSString *intervalString = [NSString stringWithFormat:@"posted %d hours ago", hour];
            NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentString];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentString length],[commentString length])];
            [self.detailTextLabel setAttributedText: string];

        }

    }
    else{
        NSString *commentstring;
        if([post.object[@"commentCount"]  isEqual: @1]){
          commentstring = [NSString stringWithFormat:@"%@ comment", post.object[@"commentCount"]];
        }
        else{
          commentstring = [NSString stringWithFormat:@"%@ comments", post.object[@"commentCount"]];
        }
        if (mins < 1) {
            
            NSString *intervalString = [NSString stringWithFormat:@"posted %ld seconds ago", -seconds];
             NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentstring];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentstring length],[commentstring length])];
            [self.detailTextLabel setAttributedText: string];
        }
        
        else if (hour < 1) {
            NSString *intervalString = [NSString stringWithFormat:@"posted %d minutes ago", mins];
             NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentstring];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentstring length],[commentstring length])];
            [self.detailTextLabel setAttributedText: string];
            
        }
        else if (hour == 1) {
            NSString *intervalString = [NSString stringWithFormat:@"posted %d hour ago", hour];
             NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentstring];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentstring length],[commentstring length])];
            [self.detailTextLabel setAttributedText: string];
        }
        else{
            NSString *intervalString = [NSString stringWithFormat:@"posted %d hours ago", hour];
             NSString *detailString = [NSString stringWithFormat:@"%@ \r%@\r%@",post.subtitle,intervalString,commentstring];
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:detailString];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:0.5f] range:NSMakeRange([detailString length]-[commentstring length],[commentstring length])];
            [self.detailTextLabel setAttributedText: string];
            
        }
    
    }
    [self setNeedsLayout];
   [self.detailTextLabel sizeToFit];
}
@end
