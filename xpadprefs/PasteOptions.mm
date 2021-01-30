#include "PasteOptions.h"
#include "../XPadHelper.h"
#include "../common.h"

@implementation PasteOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier *safariSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"Safari" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [safariSpecGroup setProperty:@"Select content type to be pasted as \"Paste and Go\" in Safari's navigation bar." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:safariSpecGroup];
        
        
        PSSpecifier *pasteAndGoTypeSpec = [PSSpecifier preferenceSpecifierNamed:@"Paste and Go" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSegmentCell edit:nil];
        [pasteAndGoTypeSpec setValues:@[@(0), @(1), @(2)] titles:@[@"Disable", @"URL Only", @"Everything"]];
        [pasteAndGoTypeSpec setProperty:@2 forKey:@"default"];
        [pasteAndGoTypeSpec setProperty:@"pasteandgo" forKey:@"key"];
        [pasteAndGoTypeSpec setProperty:kIdentifier forKey:@"defaults"];
        [pasteAndGoTypeSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:pasteAndGoTypeSpec];

        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

@end
