#import "MusiomeAPIServer.h"

#define API_ROOT_URL @"http://dev.musiome.com/"
#define API_ENDPOINT_SIGNUP @"signup/"
#define API_ENDPOINT_LOGIN @"login/"
// Format for autocomplete URL data: /getAutoComplete/?query=<search_string>&type=<Artist,Track,Album>&ts=<unix_timestamp>
#define API_ENDPOINT_GET_AUTO_COMPLETE @"getAutoComplete/?query=%@&type=%@&ts=%@"
#define API_ENDPOINT_LIST_CREATE @"lists/create/"
// Pass in NSString of list name with this definition: "lists/myListName/edit"
#define API_ENDPOINT_LIST_EDIT @"lists/%@/edit/"
// Pass in NSString of userID into this list retrieval URL
#define API_ENDPOINT_LIST_RETRIEVE @"users/%@/lists/"

#define STORED_USER_NAME @"storedUserName"
#define STORED_USER_PASSWORD @"storedUserPassword"
#define STORED_USER_ID @"storedUserId"

@interface MusiomeAPIServer ()

@property (nonatomic, weak) NSDictionary *resultDict;
@property BOOL isAccountCreationSuccessful;


@end


@implementation MusiomeAPIServer

+ (MusiomeAPIServer *) sharedAPI {
    static MusiomeAPIServer *sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPI = [[MusiomeAPIServer alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedAPI;
}

- (void) createAccountWithUsername: (NSString *) userName andEmail: (NSString *) email {
    
    NSString *loginString = [NSString stringWithFormat: @"%@%@", API_ROOT_URL, API_ENDPOINT_SIGNUP];
    NSURL *url = [NSURL URLWithString: loginString];
    
    NSString *postBody = [NSString stringWithFormat: @"email=%@&username=%@", email, userName];
    NSData *postData = [postBody dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
    [req setHTTPMethod: @"POST"];
    [req setHTTPBody: postData];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^ {
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
        
        _resultDict = [NSJSONSerialization JSONObjectWithData: resultData options: NSJSONReadingAllowFragments error: nil];
        NSLog(@"result: %@", _resultDict);
        _isAccountCreationSuccessful = [[_resultDict objectForKey: @"success"] boolValue];

        dispatch_sync(dispatch_get_main_queue(), ^{

            if (_isAccountCreationSuccessful) {
                [_apiDelegate accountCreationSuccessful];
            } else {
                [_apiDelegate accountCreationFailed];
            }
        });
    });
}

- (void) doLoginWithUsername: (NSString *) userName andPassword: (NSString *) password {

    NSString *loginString = [NSString stringWithFormat: @"%@%@", API_ROOT_URL, API_ENDPOINT_LOGIN];
    NSURL *url = [NSURL URLWithString: loginString];
    
    NSString *postBody = [NSString stringWithFormat: @"username=%@&password=%@", userName, password];
    
    NSData *postData = [postBody dataUsingEncoding: NSUTF8StringEncoding];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
    [req setHTTPMethod: @"POST"];
    [req setHTTPBody: postData];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^ {
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
        
        _resultDict = [NSJSONSerialization JSONObjectWithData: resultData options: NSJSONReadingAllowFragments error: nil];
        NSLog(@"result: %@", _resultDict);
        _isAccountCreationSuccessful = [[_resultDict objectForKey: @"success"] boolValue];
        
        BOOL isLoginSuccessfull = [[_resultDict objectForKey: @"success"] boolValue];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (isLoginSuccessfull) {
                [[NSUserDefaults standardUserDefaults] setObject: userName forKey: STORED_USER_NAME];
                [[NSUserDefaults standardUserDefaults] setObject: password forKey: STORED_USER_PASSWORD];
                [_apiDelegate loginSuccessful];
            } else {
                [_apiDelegate loginFailed];
            }
        });
    });

    
}

- (void) createListWithJSONPost: (NSString *) jsonPost  {
    
    NSString *loginString = [NSString stringWithFormat: @"%@%@", API_ROOT_URL, API_ENDPOINT_LIST_CREATE];
    NSURL *url = [NSURL URLWithString: loginString];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
    [req setHTTPMethod: @"POST"];
    [req setValue: @"application/json" forHTTPHeaderField: @"content-type"];
    [req setHTTPBody: [jsonPost dataUsingEncoding: NSUTF8StringEncoding]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^ {
        
        NSData *resultData = [NSURLConnection sendSynchronousRequest: req returningResponse: nil error: nil];
        
        _resultDict = [NSJSONSerialization JSONObjectWithData: resultData options: NSJSONReadingAllowFragments error: nil];
        NSLog(@"result: %@", _resultDict);
        _isAccountCreationSuccessful = [[_resultDict objectForKey: @"success"] boolValue];
        
        BOOL isPostSuccessful = [[_resultDict objectForKey: @"success"] boolValue];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (isPostSuccessful) {
                [_apiDelegate listCreationSuccessful];
            } else {
                [_apiDelegate listCreationFailed];
            }
        });
    });
    
}




@end
