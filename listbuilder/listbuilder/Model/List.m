//
//  List.m
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import "List.h"

@implementation List

@synthesize listName, listDateCreated, songList, listId;

- (id) init {
    if (self == [super init]) {
        songList = [NSMutableArray array];
    }
    return self;
}

@end
