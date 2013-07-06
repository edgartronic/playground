//
//  User.h
//  listbuilder
//
//  Created by Edgar Nunez on 7/4/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSMutableArray *userLists;

@end
