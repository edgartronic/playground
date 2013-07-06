//
//  Song.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, strong) NSDate *dateAddedToList;
@property (nonatomic, strong) UIImageView *albumArt;
@property (nonatomic, strong) NSString *spotifyURL;

@end
