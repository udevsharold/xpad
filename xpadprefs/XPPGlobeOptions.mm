#import "XPPGlobeOptions.h"
#import "../XPHelper.h"
#import "../common.h"

@implementation XPPGlobeOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier *emojiKeyboardSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"Emoji Keyboard" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [snippetEntrySpecifiers addObject:emojiKeyboardSpecGroup];
        
        
        PSSpecifier *emojiKeyboardSpec = [PSSpecifier preferenceSpecifierNamed:@"Skip Emoji" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [emojiKeyboardSpec setProperty:@"Skip Emoji" forKey:@"label"];
        [emojiKeyboardSpec setProperty:kEnabledSkipEmojikey forKey:@"key"];
        [emojiKeyboardSpec setProperty:@YES forKey:@"default"];
        [emojiKeyboardSpec setProperty:kIdentifier forKey:@"defaults"];
        [emojiKeyboardSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:emojiKeyboardSpec];
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

@end
