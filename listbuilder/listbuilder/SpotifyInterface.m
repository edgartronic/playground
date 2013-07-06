//
//  SpotifyInterface.m
//  listbuilder
//
//  Created by Edgar Nunez on 7/6/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import "SpotifyInterface.h"
#import "SMXMLDocument.h"

#define SPOTIFY_ROOT_URL @"http://ws.spotify.com/search/1/track?q="
#define SPOTIFY_WEB_URL @"http://open.spotify.com/track/"

@implementation SpotifyInterface

@synthesize delegate;

+ (SpotifyInterface *) sharedInterface {
    static SpotifyInterface *sharedInterface = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInterface = [[SpotifyInterface alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInterface;
}

- (NSString *) getSpotifyURLForQuery: (NSString *) _query {
    
    NSString *spotifyURL;

    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@%@", SPOTIFY_ROOT_URL, _query]];
    NSURLRequest *req = [NSURLRequest requestWithURL: url];
    
    NSError *error;
    NSURLResponse *response;
    
    NSData *result = [NSURLConnection sendSynchronousRequest: req returningResponse: &response error: &error];
    
    SMXMLDocument *doc = [SMXMLDocument documentWithData: result error: &error];
    NSArray *tracks = [doc.root childrenNamed: @"track"];
    
    if (tracks) {
        SMXMLElement *firstTrack = [tracks objectAtIndex: 0];
        NSString *firstTrackID = [[firstTrack attributeNamed: @"href"] stringByReplacingOccurrencesOfString:@"spotify:track:" withString:@""];
        spotifyURL = [NSString stringWithFormat: @"%@%@", SPOTIFY_WEB_URL, firstTrackID];
    }
    return spotifyURL;
}

@end
