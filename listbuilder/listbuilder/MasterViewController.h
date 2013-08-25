//
//  MasterViewController.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "MusiomeAPIServer.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <UIAlertViewDelegate, MusiomeAPIServerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) UIActivityIndicatorView *loader;

@end
