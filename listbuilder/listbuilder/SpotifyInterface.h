//
//  SpotifyInterface.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/6/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpotifyInterfaceDelegate;

@interface SpotifyInterface : NSObject

+ (SpotifyInterface *) sharedInterface;

@property (nonatomic, assign) NSObject<SpotifyInterfaceDelegate> *delegate;

- (NSString *) getSpotifyURLForQuery: (NSString *) _query;

@end

@protocol SpotifyInterfaceDelegate <NSObject>
@optional


@end
