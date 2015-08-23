#import <Cordova/CDVPlugin.h>

@interface IonicKeyboard : CDVPlugin <UIScrollViewDelegate> {
    @protected
    id _keyboardDidShowObserver, _keyboardDidHideObserver,
       _keyboardWillShowObserver, _keyboardWillHideObserver;
}

@property (readwrite, assign) BOOL hideKeyboardAccessoryBar;
@property (readwrite, assign) BOOL disableScroll;

@end

