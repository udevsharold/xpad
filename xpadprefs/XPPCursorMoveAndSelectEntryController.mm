#import "XPPCursorMoveAndSelectEntryController.h"
#import "../common.h"

static NSMutableDictionary *settings;


@implementation XPPCursorMoveAndSelectEntryController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        NSArray *selectionArray;
        if ([self.entryID containsString:@"ParagraphAction:"]){
            selectionArray = @[@"Whole Paragraph", @"From Current Position"];
        }else if ([self.entryID containsString:@"LineAction:"]){
            selectionArray = @[@"Whole Line", @"From Current Position"];
        }else if ([self.entryID containsString:@"SentenceAction:"]){
            selectionArray = @[@"Whole Sentence", @"From Current Position"];
        }else{
            selectionArray = @[@"Single Word Only", @"Continuously"];
        }
        
        PSSpecifier *selectionTypeGroup = [PSSpecifier preferenceSpecifierNamed:@"Default Long Press Selection Mode" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [selectionTypeGroup setProperty:@"Default Long Press Behaviour" forKey:@"label"];
        [selectionTypeGroup setProperty:@"Choose the selection behaviour for default long press gesture." forKey:@"footerText"];
        [snippetEntrySpecifiers addObject:selectionTypeGroup];
        
        
        PSSpecifier *selectionType = [PSSpecifier preferenceSpecifierNamed:@"selectionType" target:self set:@selector(setValue:specifier:) get:@selector(readValue:) detail:nil cell:PSSegmentCell edit:nil];
        [selectionType setValues:@[@(0), @(1)] titles:selectionArray];
        [selectionType setProperty:@"0" forKey:@"default"];
        [selectionType setProperty:@"type" forKey:@"key"];
        [selectionType setProperty:kIdentifier forKey:@"defaults"];
        [selectionType setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
        [snippetEntrySpecifiers addObject:selectionType];
        
        
        _specifiers = snippetEntrySpecifiers;
        
        if (!settings) settings = [[[XPPrefsManager sharedInstance] readPrefs] mutableCopy];
        
    }
    
    return _specifiers;
}

- (id)readValue:(PSSpecifier*)specifier {
    
    
    //NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    //NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //settings = [[[XPPrefsManager sharedInstance] readPrefs] mutableCopy];
    
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    
    
    NSArray *arrayWithEntryID = [settings[@"cursormoevandselect"] valueForKey:@"entryID"];
    HBLogDebug(@"array ID: %@", arrayWithEntryID);
    NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
    HBLogDebug(@"index: %lu", (unsigned long)index);
    NSMutableDictionary *settingsSnippet = index != NSNotFound ? settings[@"cursormoevandselect"][index] : nil;
    
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
    //settings = [[[XPPrefsManager sharedInstance] readPrefs] mutableCopy];
    HBLogDebug(@"settings: %@", settings);
    NSMutableArray *snippets;
    NSMutableDictionary *snippet;
    //[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (settings[@"cursormoevandselect"] && [settings[@"cursormoevandselect"] firstObject] != nil){
        snippets = [settings[@"cursormoevandselect"] mutableCopy];
        NSArray *arrayWithEntryID = [settings[@"cursormoevandselect"] valueForKey:@"entryID"];
        NSUInteger index = [arrayWithEntryID indexOfObject:self.entryID];
        HBLogDebug(@"index: %lu", (unsigned long)index);
        snippet = index != NSNotFound ? [[snippets objectAtIndex:index] mutableCopy] : [[NSMutableDictionary alloc] init];
        HBLogDebug(@"value: %@", value);
        
        //[snippet setObject:value forKey:specifier.properties[@"key"]];
        //[snippets replaceObjectAtIndex:index withObject:snippet];
        //[settings setObject:snippets forKey:@"cursormoevandselect"];
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
    
    settings[@"cursormoevandselect"] = snippets;
    HBLogDebug(@"settings: %@", settings);
    HBLogDebug(@"snippets: %@", settings[@"cursormoevandselect"]);
    //[settings setObject:value atIndex:index];
    //[settings writeToFile:path atomically:YES];
    [[XPPrefsManager sharedInstance] writePrefs:settings];
    
    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

@end
