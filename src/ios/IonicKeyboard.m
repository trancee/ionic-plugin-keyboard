#import "IonicKeyboard.h"
#import "UIWebViewExtension.h"
#import <Cordova/CDVAvailability.h>

@implementation IonicKeyboard

@synthesize hideKeyboardAccessoryBar = _hideKeyboardAccessoryBar;
@synthesize disableScroll = _disableScroll;

- (void)pluginInitialize {
  
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    __weak IonicKeyboard* weakSelf = self;

    NSString* setting = nil;

    setting = @"HideKeyboardAccessoryBar";
    if ([self settingForKey:setting]) {
        self.hideKeyboardAccessoryBar = [(NSNumber*)[self settingForKey:setting] boolValue];
    }
    setting = @"DisableScroll";
    if ([self settingForKey:setting]) {
        self.disableScroll = [(NSNumber*)[self settingForKey:setting] boolValue];
    }
    
    _keyboardDidShowObserver = [nc addObserverForName:UIKeyboardDidShowNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                   
                                   CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                                   keyboardFrame = [self.viewController.view convertRect:keyboardFrame fromView:nil];
                                   
                                   [weakSelf.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.plugins.Keyboard.isVisible = true; cordova.fireWindowEvent('native.keyboardshow', { 'keyboardHeight': %@ }); ", [@(keyboardFrame.size.height) stringValue]]];
                               }];
    _keyboardDidHideObserver = [nc addObserverForName:UIKeyboardDidHideNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                               }];

    _keyboardWillShowObserver = [nc addObserverForName:UIKeyboardWillShowNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                               }];
    _keyboardWillHideObserver = [nc addObserverForName:UIKeyboardWillHideNotification
                               object:nil
                               queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification* notification) {
                                   [weakSelf.commandDelegate evalJs:@"cordova.plugins.Keyboard.isVisible = false; cordova.fireWindowEvent('native.keyboardhide'); "];
                               }];
}
- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}
- (BOOL)disableScroll {
    return _disableScroll;
}

- (void)setDisableScroll:(BOOL)disableScroll {
    if (disableScroll == _disableScroll) {
        return;
    }
    if (disableScroll) {
        self.webView.scrollView.scrollEnabled = NO;
        self.webView.scrollView.delegate = self;
    }
    else {
        self.webView.scrollView.scrollEnabled = YES;
        self.webView.scrollView.delegate = nil;
    }

    _disableScroll = disableScroll;
}


- (BOOL)hideKeyboardAccessoryBar {
    return _hideKeyboardAccessoryBar;
}

- (void)setHideKeyboardAccessoryBar:(BOOL)hideKeyboardAccessoryBar {
    if (hideKeyboardAccessoryBar == _hideKeyboardAccessoryBar) {
        return;
    }
    if (hideKeyboardAccessoryBar) {
        self.webView.hackishlyHidesInputAccessoryView = YES;
    }
    else {
        self.webView.hackishlyHidesInputAccessoryView = NO;
    }

    _hideKeyboardAccessoryBar = hideKeyboardAccessoryBar;
}


/* ------------------------------------------------------------- */

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView setContentOffset: CGPointZero];
}

/* ------------------------------------------------------------- */

- (void)dealloc {
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [nc removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

/* ------------------------------------------------------------- */

- (void) disableScroll:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    
    self.disableScroll = [value boolValue];
}

- (void) hideKeyboardAccessoryBar:(CDVInvokedUrlCommand*)command {
    if (!command.arguments || ![command.arguments count]){
      return;
    }
    id value = [command.arguments objectAtIndex:0];
    
    self.hideKeyboardAccessoryBar = [value boolValue];
}

- (void) close:(CDVInvokedUrlCommand*)command {
    [self.webView endEditing:YES];
}

- (void) show:(CDVInvokedUrlCommand*)command {
    NSLog(@"Showing keyboard not supported in iOS due to platform limitations.");
}

@end

