#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface XPPSnippetEntryController : PSListController
@property (nonatomic,readwrite) NSString *entryID;

@end

@interface PSSpecifier (XPPSnippetEntryController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
