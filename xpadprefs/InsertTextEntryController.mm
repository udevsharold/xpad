#include "InsertTextEntryController.h"
#include "../common.h"

static NSMutableDictionary *settings;


@implementation InsertTextEntryController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        PSSpecifier *singleTapGroup = [PSSpecifier preferenceSpecifierNamed:@"Single Tap" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [singleTapGroup setProperty:@"Single Tap" forKey:@"label"];
        [singleTapGroup setProperty:@"Set the text to be inserted when shortcut tapped." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:singleTapGroup];
        
        
        PSSpecifier *insertType = [PSSpecifier preferenceSpecifierNamed:@"insertType" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSSegmentCell edit:nil];
        [insertType setValues:@[@(0), @(1), @(2), @(3), @(4) , @(5)] titles:@[@"Text", @"S. Date", @"M. Date", @"S. Time", @"M. Time", @"F. Date"]];
        [insertType setProperty:@"0" forKey:@"default"];
        [insertType setProperty:@"type" forKey:@"key"];
        [insertType setProperty:kIdentifier forKey:@"defaults"];
        [insertType setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:insertType];
        
        PSSpecifier *entryTitle = [PSSpecifier preferenceSpecifierNamed:@"Text" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryTitle setProperty:@NO forKey:@"noAutoCorrect"];
        [entryTitle setProperty:@"text" forKey:@"key"];
        [entryTitle setProperty:kIdentifier forKey:@"defaults"];
        [entryTitle setProperty:@"Text" forKey:@"label"];
        [entryTitle setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        self.textSpecifier = entryTitle;
        [snippetEntrySpecifiers addObject:entryTitle];
        
        
        
        //Long Press
        PSSpecifier *longPressGroup = [PSSpecifier preferenceSpecifierNamed:@"Long Press" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [longPressGroup setProperty:@"Long Press" forKey:@"label"];
        [longPressGroup setProperty:@"Set the text to be inserted when shortcut is long pressed.\n\nNOTE: When custom long press gesture is set in previous section, this will be ignored." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:longPressGroup];
        
        PSSpecifier *insertTypeLP = [PSSpecifier preferenceSpecifierNamed:@"insertType" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSSegmentCell edit:nil];
        [insertTypeLP setValues:@[@(0), @(1), @(2), @(3), @(4) , @(5)] titles:@[@"Text", @"S. Date", @"M. Date", @"S. Time", @"M. Time", @"F. Date"]];
        [insertTypeLP setProperty:@"0" forKey:@"default"];
        [insertTypeLP setProperty:@"typeLP" forKey:@"key"];
        [insertTypeLP setProperty:kIdentifier forKey:@"defaults"];
        [insertTypeLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:insertTypeLP];
        
        PSSpecifier *entryTitleLP = [PSSpecifier preferenceSpecifierNamed:@"Text" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSEditTextCell edit:@YES];
        [entryTitleLP setProperty:@NO forKey:@"noAutoCorrect"];
        [entryTitleLP setProperty:@"textLP" forKey:@"key"];
        [entryTitleLP setProperty:kIdentifier forKey:@"defaults"];
        [entryTitleLP setProperty:@"Text" forKey:@"label"];
        [entryTitleLP setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        self.textSpecifierLP = entryTitleLP;
        [snippetEntrySpecifiers addObject:entryTitleLP];
        
        
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
    
    
    NSArray *arrayWithEntryID = [settings[@"inserts"] valueForKey:@"entryID"];
    HBLogDebug(@"array ID: %@", arrayWithEntryID);
    NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
    HBLogDebug(@"index: %lu", (unsigned long)index);
    NSMutableDictionary *settingsSnippet = index != NSNotFound ? settings[@"inserts"][index] : nil;
    
    id value = (settingsSnippet[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
    
    NSString *key = [specifier propertyForKey:@"key"];
    if ([key isEqualToString:@"type"]){
        if ([value intValue] > 0){
            [self.textSpecifier setProperty:@NO forKey:@"enabled"];
        }else{
            [self.textSpecifier setProperty:@YES forKey:@"enabled"];
        }
        [self reloadSpecifier:self.textSpecifier animated:YES];
    }else if ([key isEqualToString:@"typeLP"]){
        if ([value intValue] > 0){
            [self.textSpecifierLP setProperty:@NO forKey:@"enabled"];
        }else{
            [self.textSpecifierLP setProperty:@YES forKey:@"enabled"];
        }
        [self reloadSpecifier:self.textSpecifierLP animated:YES];
    }
    
    
    return value;
}

- (void)setValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    if ([key isEqualToString:@"type"]){
        if ([value intValue] > 0){
            [self.textSpecifier setProperty:@NO forKey:@"enabled"];
        }else{
            [self.textSpecifier setProperty:@YES forKey:@"enabled"];
        }
        [self reloadSpecifier:self.textSpecifier animated:YES];
    }else if ([key isEqualToString:@"typeLP"]){
        if ([value intValue] > 0){
            [self.textSpecifierLP setProperty:@NO forKey:@"enabled"];
        }else{
            [self.textSpecifierLP setProperty:@YES forKey:@"enabled"];
        }
        [self reloadSpecifier:self.textSpecifierLP animated:YES];
    }
    
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[PrefsManager sharedInstance] readPrefs] mutableCopy];
    HBLogDebug(@"settings: %@", settings);
    NSMutableArray *snippets;
    NSMutableDictionary *snippet;
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (settings[@"inserts"] && [settings[@"inserts"] firstObject] != nil){
        snippets = [settings[@"inserts"] mutableCopy];
        NSArray *arrayWithEntryID = [settings[@"inserts"] valueForKey:@"entryID"];
        NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
        HBLogDebug(@"index: %lu", (unsigned long)index);
        snippet = index != NSNotFound ? [[snippets objectAtIndex:index] mutableCopy] : [[NSMutableDictionary alloc] init];
        HBLogDebug(@"value: %@", value);
        
        //[snippet setObject:value forKey:specifier.properties[@"key"]];
        //[snippets replaceObjectAtIndex:index withObject:snippet];
        //[settings setObject:snippets forKey:@"inserts"];
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
    
    settings[@"inserts"] = snippets;
    HBLogDebug(@"settings: %@", settings);
    HBLogDebug(@"snippets: %@", settings[@"inserts"]);
    //[settings setObject:value atIndex:index];
    //[settings writeToFile:path atomically:YES];
    [[PrefsManager sharedInstance] writePrefs:settings];
    
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

@end
