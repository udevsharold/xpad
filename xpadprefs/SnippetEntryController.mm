#include "SnippetEntryController.h"
#include "../common.h"

static NSMutableDictionary *settings;

@implementation SnippetEntryController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
         PSSpecifier *singleTapGroup = [PSSpecifier preferenceSpecifierNamed:@"Single Tap" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [singleTapGroup setProperty:@"Single Tap" forKey:@"label"];
        [singleTapGroup setProperty:@"Set the shell command to be executed when shortcut tapped." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:singleTapGroup];

        
        PSSpecifier *entryTitle = [PSSpecifier preferenceSpecifierNamed:@"Title" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryTitle setProperty:@YES forKey:@"noAutoCorrect"];
        [entryTitle setProperty:@"title" forKey:@"key"];
        [entryTitle setProperty:kIdentifier forKey:@"defaults"];
        [entryTitle setProperty:@"Title" forKey:@"label"];
        [entryTitle setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryTitle];
        
        /*
         PSSpecifier *entryDescription = [PSSpecifier preferenceSpecifierNamed:@"Description" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSEditTextCell edit:@YES];
         [entryDescription setProperty:@NO forKey:@"noAutoCorrect"];
         [entryDescription setProperty:@"description" forKey:@"key"];
         [entryDescription setProperty:kIdentifier forKey:@"defaults"];
         [entryDescription setProperty:@"Description" forKey:@"label"];
         [entryDescription setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
         [snippetEntrySpecifiers addObject:entryDescription];
         */
        
        PSSpecifier *entryCommand = [PSSpecifier preferenceSpecifierNamed:@"Command" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryCommand setProperty:@YES forKey:@"noAutoCorrect"];
        [entryCommand setProperty:@"command" forKey:@"key"];
        [entryCommand setProperty:kIdentifier forKey:@"defaults"];
        [entryCommand setProperty:@"Command" forKey:@"label"];
        [entryCommand setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryCommand];
        
        /*
        PSSpecifier *entryIconType = [PSSpecifier preferenceSpecifierNamed:@"IconType" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSSegmentCell edit:nil];
        [entryIconType setValues:@[@(0), @(1)] titles:@[@"Icon Path", @"Emoji"]];
        [entryIconType setProperty:@"0" forKey:@"default"];
        [entryIconType setProperty:@"isEmoji" forKey:@"key"];
        [entryIconType setProperty:kIdentifier forKey:@"defaults"];
        [entryIconType setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryIconType];
        
        PSSpecifier *entryIcon = [PSSpecifier preferenceSpecifierNamed:@"Icon" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryIcon setProperty:@YES forKey:@"noAutoCorrect"];
        [entryIcon setProperty:@"icon" forKey:@"key"];
        [entryIcon setProperty:kIdentifier forKey:@"defaults"];
        [entryIcon setProperty:@"Icon Path" forKey:@"label"];
        [entryIcon setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryIcon];
        */
        
        PSSpecifier *longPressGroup = [PSSpecifier preferenceSpecifierNamed:@"Long Press" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [longPressGroup setProperty:@"Long Press" forKey:@"label"];
        [longPressGroup setProperty:@"Set the shell command to be executed when shortcut long pressed.\n\nNOTE: When custom long press gesture is set in previous section, this will be ignored." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:longPressGroup];
        
        PSSpecifier *entryTitleLP = [PSSpecifier preferenceSpecifierNamed:@"Title" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryTitleLP setProperty:@YES forKey:@"noAutoCorrect"];
        [entryTitleLP setProperty:@"titleLP" forKey:@"key"];
        [entryTitleLP setProperty:kIdentifier forKey:@"defaults"];
        [entryTitleLP setProperty:@"Title" forKey:@"label"];
        [entryTitleLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryTitleLP];
        
        PSSpecifier *entryCommandLP = [PSSpecifier preferenceSpecifierNamed:@"Command" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryCommandLP setProperty:@YES forKey:@"noAutoCorrect"];
        [entryCommandLP setProperty:@"commandLP" forKey:@"key"];
        [entryCommandLP setProperty:kIdentifier forKey:@"defaults"];
        [entryCommandLP setProperty:@"Command" forKey:@"label"];
        [entryCommandLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:entryCommandLP];
        
        
        
        _specifiers = snippetEntrySpecifiers;
        
        if (!settings) settings = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
        
    }
    
    return _specifiers;
}

- (id)readValue:(PSSpecifier*)specifier {
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
    
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    
    
    NSArray *arrayWithEntryID = [settings[@"snippets"] valueForKey:@"entryID"];
    HBLogDebug(@"array ID: %@", arrayWithEntryID);
    NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
    HBLogDebug(@"index: %lu", (unsigned long)index);
    NSMutableDictionary *settingsSnippet = index != NSNotFound ? settings[@"snippets"][index] : nil;
    
    return (settingsSnippet[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setValue:(id)value specifier:(PSSpecifier*)specifier {
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
    HBLogDebug(@"settings: %@", settings);
    NSMutableArray *snippets;
    NSMutableDictionary *snippet;
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (settings[@"snippets"] && [settings[@"snippets"] firstObject] != nil){
        snippets = [settings[@"snippets"] mutableCopy];
        NSArray *arrayWithEntryID = [settings[@"snippets"] valueForKey:@"entryID"];
        NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
        HBLogDebug(@"index: %lu", (unsigned long)index);
        snippet = index != NSNotFound ? [[snippets objectAtIndex:index] mutableCopy] : [[NSMutableDictionary alloc] init];
        HBLogDebug(@"value: %@", value);
        
        //[snippet setObject:value forKey:specifier.properties[@"key"]];
        //[snippets replaceObjectAtIndex:index withObject:snippet];
        //[settings setObject:snippets forKey:@"snippets"];
        snippet[specifier.properties[@"key"]] = value;
        snippet[@"entryID"] = self.entryID;
        HBLogDebug(@"XXXXXXXX SNIPPET: %@", snippet);
        if (index != NSNotFound){
            [snippets replaceObjectAtIndex:index withObject:snippet];
        }else{
            [snippets addObject:snippet];
        }
    }else{
        snippets = [[NSMutableArray alloc] init];
        snippet = [[NSMutableDictionary alloc] init];
        snippet[specifier.properties[@"key"]] = value;
        snippet[@"entryID"] = self.entryID;
        [snippets addObject:snippet];
        
    }
    
    settings[@"snippets"] = snippets;
    HBLogDebug(@"settings: %@", settings);
    HBLogDebug(@"snippets: %@", settings[@"snippets"]);
    //[settings setObject:value atIndex:index];
    //[settings writeToFile:path atomically:YES];
    [[PrefsManager sharedInstance] writePrefs:settings];
    
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

@end
