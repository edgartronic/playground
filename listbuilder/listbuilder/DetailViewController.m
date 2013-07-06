//
//  DetailViewController.m
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import "DetailViewController.h"
#import "Song.h"
#import "List.h"
#import "SpotifyInterface.h"

@interface DetailViewController () {
    int selectedSongIndex;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame: self.view.frame];
    self.view = scroll;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Update the user interface for the detail item.
  
    if (self.detailItem) {
        List *l = (List *) self.detailItem;
        self.title = l.listName;
        int verticalOrigin = 0;
        int tag = 0;
        for (Song *s in l.songList) {
            
            s.albumArt.frame = CGRectMake(0, verticalOrigin, s.albumArt.frame.size.width, s.albumArt.frame.size.height);
            [scroll addSubview: s.albumArt];
            NSString *st = [NSString stringWithFormat: @"%@\n%@", s.artistName, s.songName];
            NSString *spotifyQuery = [st stringByReplacingOccurrencesOfString: @"&" withString: @""];
            spotifyQuery = [spotifyQuery stringByReplacingOccurrencesOfString: @" " withString: @"+"];
            spotifyQuery = [spotifyQuery stringByReplacingOccurrencesOfString: @"\n" withString: @"+"];
            s.spotifyURL =  [[SpotifyInterface sharedInterface] getSpotifyURLForQuery: spotifyQuery];

            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(s.albumArt.frame.size.width + 5, verticalOrigin + 15, 150, 50)];
            lbl.numberOfLines = 2;
            lbl.font = [UIFont systemFontOfSize: 13];
            lbl.text = st;
            [scroll addSubview: lbl];
            if (s.spotifyURL) {
                UIButton *btn = [UIButton buttonWithType: UIButtonTypeSystem];
                btn.frame = CGRectMake(lbl.frame.size.width + lbl.frame.origin.x + 5, lbl.frame.origin.y, 65, lbl.frame.size.height);
                btn.tag = tag;
                [btn setTitle: @"Share" forState: UIControlStateNormal];
                [btn addTarget: self action: @selector(shareSong:) forControlEvents: UIControlEventTouchUpInside];
                [scroll addSubview: btn];
            }
            verticalOrigin = verticalOrigin + s.albumArt.frame.size.height;
            tag++;
        }
        scroll.contentSize = CGSizeMake(self.view.frame.size.width, verticalOrigin);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"My Playlists", @"My Playlists");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void) shareSong: (id) sender {
    UIButton *btn = (UIButton *) sender;
    List *l = (List *) self.detailItem;
    Song *selectedSong = [l.songList objectAtIndex: btn.tag];
    selectedSongIndex = btn.tag;
    NSString *sheetTitle = [NSString stringWithFormat: @"Share \"%@\"", selectedSong.songName];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle: sheetTitle delegate: self cancelButtonTitle: @"Cancel" destructiveButtonTitle: Nil otherButtonTitles: @"Facebook", @"Twitter", @"Text Message", @"Email", nil];
    [sheet showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

    List *l = (List *) self.detailItem;
    Song *selectedSong = [l.songList objectAtIndex: selectedSongIndex];
    NSString *textBody = [NSString stringWithFormat: @"Check out this song on Musiome: %@ - %@: %@", selectedSong.artistName, selectedSong.songName, selectedSong.spotifyURL];
    
    switch (buttonIndex) {
        case 0:{
            SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeFacebook];
            [fbController setInitialText: textBody];
            [self presentViewController: fbController animated: YES completion: ^ {
                NSLog(@"Facebook presented");
            }];
            break;
        }
            
        case 1: {
            SLComposeViewController *twController = [SLComposeViewController composeViewControllerForServiceType: SLServiceTypeTwitter];
            [twController setInitialText: textBody];
            [self presentViewController: twController animated: YES completion: ^ {
                NSLog(@"Twitter presented");
            }];
            break;
        }
            
        case 2: {
            if ([MFMessageComposeViewController canSendText]) {
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.body = textBody;
                [self presentViewController: messageController animated: YES completion: ^ {
                    NSLog(@"Text presented");
                }];
            }
            break;
        }
            
        case 3: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
                [mailController setSubject: textBody];
                [mailController setMessageBody: textBody isHTML: YES];
                [self presentViewController: mailController animated: YES completion: ^ {
                    NSLog(@"Mail presented");
                }];
            }
            break;
        }
            
        default:
            break;
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated: YES completion: nil];
    
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated: YES completion: nil];
    
}

@end
