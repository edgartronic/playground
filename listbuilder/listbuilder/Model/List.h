//
//  List.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface List : NSObject

@property (nonatomic, strong) NSString *listName;
@property (nonatomic, strong) NSDate *listDateCreated;
@property (nonatomic, strong) NSMutableArray *songList;

@end
