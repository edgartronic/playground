//
//  MusiomeAPIServer.h
//  listbuilder
//
//  Created by Edgar Nunez on 8/21/13.
//  Copyright (c) 2013 Edgar Nunez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MusiomeAPIServerDelegate;

@interface MusiomeAPIServer : NSObject

+ (MusiomeAPIServer *) sharedAPI;

@property (nonatomic, assign) NSObject<MusiomeAPIServerDelegate> *apiDelegate;

- (void) createAccountWithUsername: (NSString *) userName andEmail: (NSString *) email;
- (void) doLoginWithUsername: (NSString *) userName andPassword: (NSString *) password;
- (void) createListWithJSONPost: (NSString *) jsonPost;

@end

@protocol MusiomeAPIServerDelegate <NSObject>
@optional
- (void) accountCreationSuccessful;
- (void) accountCreationFailed;
- (void) loginSuccessful;
- (void) loginFailed;
- (void) listCreationSuccessful;
- (void) listCreationFailed;
@end
