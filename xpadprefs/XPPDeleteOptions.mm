#import "XPPDeleteOptions.h"
#import "../XPHelper.h"
#import "../common.h"

@implementation XPPDeleteOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];

        PSSpecifier *smartDeleteSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"Smart Delete" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [smartDeleteSpecGroup setProperty:@"Smart delete will insert a space after deletion.\n\nNOTE: If no word is selected, closest word/punctuation will be selected for delete." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:smartDeleteSpecGroup];
        
        NSString *deleteDirectionKey = kEnabledSmartDeletekey;
        if ([self.entryID containsString:@"deleteForwardAction:"]){
            deleteDirectionKey = kEnabledSmartDeleteForwardkey;
        }

        PSSpecifier *smartDeleteSpec = [PSSpecifier preferenceSpecifierNamed:@"Smart Delete" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSwitchCell edit:nil];
        [smartDeleteSpec setProperty:@"Smart Delete" forKey:@"label"];
        [smartDeleteSpec setProperty:deleteDirectionKey forKey:@"key"];
        [smartDeleteSpec setProperty:@NO forKey:@"default"];
        [smartDeleteSpec setProperty:kIdentifier forKey:@"defaults"];
        [smartDeleteSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:smartDeleteSpec];
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

@end
