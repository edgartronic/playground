//
//  DetailViewController.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@end
