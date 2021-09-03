#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface XPPSpongebobOptions : PSListController <UISearchBarDelegate>
@end

@interface PSSpecifier (XPPSpongebobOptions)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
