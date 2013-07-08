//
//  MasterViewController.m
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "List.h"

@interface MasterViewController () <MPMediaPickerControllerDelegate> {
    NSMutableArray *_objects;
}
- (void) grabTopRatedSongsFromLib;
- (void) createNewList;
- (void) addListFromSongList: (NSArray *) array;
@end

@implementation MasterViewController

@synthesize loader;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target:self action:@selector(addNewList:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    List *l = (List *) sender;
    [_objects insertObject: l atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell" forIndexPath: indexPath];
    
    List *_list = _objects[indexPath.row];
    cell.textLabel.text = _list.listName;
    cell.detailTextLabel.text = _list.listDateCreated.description;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma Music methods

- (void) addNewList: (id) sender {
    UIAlertView *a = [[UIAlertView alloc] initWithTitle: @"My Playlists" message: @"Would you like to create a list with your top-rated songs from your iTunes library?" delegate: self cancelButtonTitle: @"Sure!" otherButtonTitles: @"No Thanks.", nil];
    [a show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self grabTopRatedSongsFromLib];
            break;
            
        case 1:
            [self createNewList];
            break;
            
        default:
            break;
    }
}

- (void) grabTopRatedSongsFromLib {
    
    loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    loader.frame = CGRectMake(0, 0, 150, 150);
    loader.center = self.view.center;
    [self.view addSubview: loader];
    [loader startAnimating];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^ {
        
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        NSMutableArray *fiveStarSongsArray = [NSMutableArray array];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            for (MPMediaItem *item in [query items]) {
                NSString *rating = [item valueForProperty: MPMediaItemPropertyRating];
                if ([rating integerValue] == 5) {
                    [fiveStarSongsArray addObject: item];
                }
            }
            [self addListFromSongList: fiveStarSongsArray];
            [loader stopAnimating];
            [loader removeFromSuperview];
        });
    });
    
}

- (void) createNewList {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    mediaPicker.allowsPickingMultipleItems = YES;
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Add Songs To Your List";
    [self presentViewController: mediaPicker animated: YES completion: nil];
}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    [mediaPicker dismissViewControllerAnimated: YES completion: nil];
    
    [self addListFromSongList: mediaItemCollection.items];
    
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [mediaPicker dismissViewControllerAnimated: YES completion: nil];
}

- (void) addListFromSongList: (NSArray *) array {
    NSMutableArray *containerArray = [NSMutableArray array];
    for (MPMediaItem *item in array) {
        Song *newSong = [Song new];
        newSong.songName = [item valueForProperty: MPMediaItemPropertyTitle];
        newSong.artistName = [item valueForProperty: MPMediaItemPropertyAlbumArtist];
        if (newSong.artistName == nil) {
            newSong.artistName = [item valueForProperty: MPMediaItemPropertyArtist];
        }
        MPMediaItemArtwork *art = [item valueForProperty: MPMediaItemPropertyArtwork];
        UIImage *artImg = [art imageWithSize: CGSizeMake(65.0, 65.0)];
        newSong.albumArt = [[UIImageView alloc] initWithImage: artImg];
        [containerArray addObject: newSong];
    }
    List *newList = [List new];
    newList.songList = containerArray;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString *titleString = [NSString stringWithFormat: @"New List: %@", [formatter stringFromDate: [NSDate date]]];
    newList.listName = titleString;
    newList.listDateCreated = [NSDate date];
    [self insertNewObject: newList];
}

@end
