#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface XPPPasteOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (XPPPasteOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
