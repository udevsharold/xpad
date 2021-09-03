#import "DXPSpongebobOptions.h"
#import "../XPadHelper.h"
#import "../common.h"

@implementation DXPSpongebobOptions

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        PSSpecifier *spongebobTextSpecGroup = [PSSpecifier preferenceSpecifierNamed:@"Randomness of Spongebob Text" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [spongebobTextSpecGroup setProperty:@"Select the entropy for the randomness of generated text." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:spongebobTextSpecGroup];
        
        
        PSSpecifier *spongebobEntropyTypeSpec = [PSSpecifier preferenceSpecifierNamed:@"Spongebob Entropy" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSSegmentCell edit:nil];
        [spongebobEntropyTypeSpec setValues:@[@(DXStudlyCapsTypeRandom), @(DXStudlyCapsTypeAlternate), @(DXStudlyCapsTypeVowel), @(DXStudlyCapsTypeConsonent)] titles:@[@"Random", @"Alternate", @"Vowel", @"Consonent"]];
        [spongebobEntropyTypeSpec setProperty:@(DXStudlyCapsTypeRandom) forKey:@"default"];
        [spongebobEntropyTypeSpec setProperty:kSpongebobEntropyKey forKey:@"key"];
        [spongebobEntropyTypeSpec setProperty:kIdentifier forKey:@"defaults"];
        [spongebobEntropyTypeSpec setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:spongebobEntropyTypeSpec];
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

@end
