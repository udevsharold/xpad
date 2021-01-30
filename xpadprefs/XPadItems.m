#include "XPadItems.h"
#include "CustomActionViewController.h"
#include "KeyboardTypeOptions.h"
#include "SnippetEntryController.h"
#include "InsertTextEntryController.h"
#include "CursorMoveAndSelectEntryController.h"
#include "../ShortcutsGenerator.h"
#include "../XPadHelper.h"
#include "GesturePickerController.h"
#include "DeleteOptions.h"
#include "GlobeOptions.h"
#include "PasteOptions.h"

static BOOL translomaticInstalled = NO;

@implementation XPadItems

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Enabled Shortcuts";
        case 1:
            return @"Disabled Shortcuts";
        default:
            return @"Extras";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [self.currentOrder[0] count];
        case 1:
            return [self.currentOrder[1] count];
        case 2:
            return [self.extrasOptions count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *footerTextForSectionOne = @"";
    switch (section) {
        case 0:
            
            return @"Add as many shortcuts as you wish, but in limited space those extra shortcuts will be collapsed into a menu. Tap any shortcut to customize its gestures actions.\n\nNOTE: If you experiencing any issue or shortcuts not showing correctly, please reset.";
        case 1:
            return @"";
        case 2:
            footerTextForSectionOne = @"Tap item to customize.\n\n";
            footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:@"Default long press gesture for:\n"
                                       "Select - select all words\n"
                                       "Select All - select last word\n"
                                       "Copy - select all and copy\n"
                                       "Paste - select all and paste\n"
                                       "Cut - delete last word\n"
                                       "Undo - go to beginning of document\n"
                                       "Redo - go to ending of document\n"
                                       "Beginning of Document - undo\n"
                                       "Ending of Document - redo\n"
                                       "Capitalize Last Word - uppercase last word\n"
                                       "lowercase - uppercase last word\n"
                                       "UPPERCASE - lowercase last word\n"
                                       "Delete - select all and delete\n"
                                       "Bold - select last word and toggle bold face\n"
                                       "Italic - select last word and toggle italic\n"
                                       "Underline - select last word and toggle underline\n"
                                       "Cursor Left - move cursor backward exponentionally\n"
                                       "Cursor Right - move cursor forward exponentionally\n"
                                       "Cursor Up - move cursor upward exponentionally\n"
                                       "Cursor Down - move cursor downward exponentionally\n"
                                       "Keyboard Input - revert back to original input type\n"
                                       "Previous & Next Word - select word\n"
                                       "Line Start & End - select line\n"
                                       "Start & End of Paragraph - select paragraph\n"
                                       "Start & End of Sentence  - select sentence\n"
                                       "Globe - activate dictation"];
            if (translomaticInstalled){
                footerTextForSectionOne = [footerTextForSectionOne stringByAppendingString:@"\nTranslomatic - select paragraph and translate"];
            }
            return footerTextForSectionOne;
        default:
            return @"";
            
    }
}

-(void)setCompatibiltyWarning{
    CGRect frame = CGRectMake(0,0,self.tableView.bounds.size.width,50);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:frame];
    [headerLabel setText:@"Due to compatibility issue, please \"Reset\".\nInteraction with table below is temporary disabled."];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor redColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerLabel setNumberOfLines:0];
    [headerLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [headerView addSubview:headerLabel];
    self.tableView.tableHeaderView = headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XPadItemCell" forIndexPath:indexPath];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"XPadItemCell"];
    
    UIImage *image;
    NSString *label;
    
    switch(indexPath.section) {
        case 0: {
            if (self.currentOrder[0] == nil || [self.currentOrder[0] count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.currentOrder[0] count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = @"Incompatible, please reset";
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [XPadHelper labelFromArray:self.currentOrder[0] atIndex:indexPath.row];
            image = [XPadHelper imageFromArray:self.currentOrder[0] atIndex:indexPath.row withSystemColor:YES completion:nil];
            break;
        }
        case 1: {
            if (self.currentOrder[1] == nil || [self.currentOrder[1] count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.currentOrder[1] count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = @"Incompatible, please reset";
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [XPadHelper labelFromArray:self.currentOrder[1] atIndex:indexPath.row];
            image = [XPadHelper imageFromArray:self.currentOrder[1] atIndex:indexPath.row withSystemColor:YES completion:nil];
            
            break;
        }case 2: {
            if (self.extrasOptions == nil || [self.extrasOptions count] <= indexPath.row)
                return nil;
            if (indexPath.row >= [self.currentOrder[1] count]){
                [self setCompatibiltyWarning];
                cell.textLabel.text = @"Incompatible, please reset";
                cell.imageView.image = nil;
                self.tableView.userInteractionEnabled = NO;
                return cell;
            }
            label = [XPadHelper labelFromArray:self.extrasOptions atIndex:indexPath.row];
            image = [XPadHelper imageFromArray:self.extrasOptions atIndex:indexPath.row withSystemColor:YES completion:nil];
            
            break;
        }
    }
    cell.textLabel.text = label;
    cell.imageView.image = image;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section < 2){
        GesturePickerController *gesturePickerController = [[GesturePickerController alloc] init];
        
        gesturePickerController.fullOrder = @[self.firstOrder, self.fullOrder];
        gesturePickerController.identifier = self.currentOrder[indexPath.section][indexPath.row][@"selector"];
        gesturePickerController.title = self.currentOrder[indexPath.section][indexPath.row][@"label"];
        
        [gesturePickerController setRootController: [self rootController]];
        [gesturePickerController setParentController: [self parentController]];
        [self pushController:gesturePickerController];
    }else{
        if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"keyboardType"]){
            KeyboardTypeOptions *kbTypeOptions = [[KeyboardTypeOptions alloc] init];
            [kbTypeOptions setRootController: [self rootController]];
            [kbTypeOptions setParentController: [self parentController]];
            [self pushController:kbTypeOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"shellCommand"]){
            SnippetEntryController *snippetEntryController = [[SnippetEntryController alloc] init];
            snippetEntryController.entryID = @"runCommandAction:";
            [snippetEntryController setRootController: [self rootController]];
            [snippetEntryController setParentController: [self parentController]];
            [self pushController:snippetEntryController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"insertText"]){
            InsertTextEntryController *insertTextController = [[InsertTextEntryController alloc] init];
            insertTextController.entryID = @"insertTextAction:";
            [insertTextController setRootController: [self rootController]];
            [insertTextController setParentController: [self parentController]];
            [self pushController:insertTextController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"prevWord"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorPreviousWordAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"nextWord"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorNextWordAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"lineStart"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfLineAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"lineEnd"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfLineAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"startOfParagraph"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfParagraphAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"endOfParagraph"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfParagraphAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"startOfSentence"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorStartOfSentenceAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"endOfSentence"]){
            CursorMoveAndSelectEntryController *cursorMoveAndSelectController = [[CursorMoveAndSelectEntryController alloc] init];
            cursorMoveAndSelectController.entryID = @"moveCursorEndOfSentenceAction:";
            [cursorMoveAndSelectController setRootController: [self rootController]];
            [cursorMoveAndSelectController setParentController: [self parentController]];
            [self pushController:cursorMoveAndSelectController];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"delete"]){
            DeleteOptions *deleteOptions = [[DeleteOptions alloc] init];
            deleteOptions.entryID = @"deleteAction::";
            [deleteOptions setRootController: [self rootController]];
            [deleteOptions setParentController: [self parentController]];
            [self pushController:deleteOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"deleteForward"]){
            DeleteOptions *deleteOptions = [[DeleteOptions alloc] init];
            deleteOptions.entryID = @"deleteForwardAction::";
            [deleteOptions setRootController: [self rootController]];
            [deleteOptions setParentController: [self parentController]];
            [self pushController:deleteOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"globe"]){
            GlobeOptions *globeOptions = [[GlobeOptions alloc] init];
            [globeOptions setRootController: [self rootController]];
            [globeOptions setParentController: [self parentController]];
            [self pushController:globeOptions];
        }else if ([self.extrasOptions[indexPath.row][@"identifier"] isEqualToString:@"paste"]){
            PasteOptions *pasteOptions = [[PasteOptions alloc] init];
            [pasteOptions setRootController: [self rootController]];
            [pasteOptions setParentController: [self parentController]];
            [self pushController:pasteOptions];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.tableView == nil)
        return;
    
    if (self.currentOrder[0] == nil)
        [self updateOrder:NO];
    
    NSString *objectToMove = [self.currentOrder[0] objectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] removeObjectAtIndex:sourceIndexPath.row];
    [self.currentOrder[0] insertObject:objectToMove atIndex:destinationIndexPath.row];
    [self.tableView reloadData];
    [self writeToFile];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self.currentOrder[0] count] == 1?NO:YES;
        case 1:
            return NO;
        default:
            return NO;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            return YES;
            break;
        }
        case 1: {
            return YES;
            break;
        }
        default:
            return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                // Delete the row from the data source
                [tableView beginUpdates];
                [self.currentOrder[1] addObject:self.currentOrder[0][indexPath.row]];
                [self.currentOrder[0] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                //[tableView endUpdates];
                
                //[tableView beginUpdates];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[1] count] - 1 inSection:1];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
            }
        }
            break;
        case 1: {
            if (editingStyle == UITableViewCellEditingStyleInsert) {
                [tableView beginUpdates];
                [self.currentOrder[0] addObject:self.currentOrder[1][indexPath.row]];
                [self.currentOrder[1] removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.currentOrder[0] count] - 1  inSection:0];
                [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [tableView endUpdates];
                [self writeToFile];
                
                
            }
            
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [self.currentOrder[0] count] == 1?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
        case 1:
            return [self.currentOrder[0] count] == 1?UITableViewCellEditingStyleInsert:UITableViewCellEditingStyleInsert;
            //return [self.currentOrder[0] count] == maxShortcuts?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleInsert;
        default:
            return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)writeToFile {
    
    PSSpecifier *defaultOrderSpecifier = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:nil cell:PSLinkListCell edit:nil];
    [defaultOrderSpecifier setProperty:self.currentOrder forKey:@"default"];
    [defaultOrderSpecifier setProperty:kIdentifier forKey:@"defaults"];
    [defaultOrderSpecifier setProperty:@"shortcuts" forKey:@"key"];
    [defaultOrderSpecifier setProperty:@"" forKey:@"label"];
    [defaultOrderSpecifier setProperty:kPrefsChangedIdentifier forKey:@"PostNotification"];
    [self setPreferenceValue:self.currentOrder specifier:defaultOrderSpecifier];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPrefsChangedIdentifier, NULL, NULL, YES);
    
}
/*
-(void)updatedFromOldVersion:(BOOL)fromOldVersion{
    if (fromOldVersion){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XPad" message:@"You just updated to a major version, shortcuts settings will be reset for compatibility." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}
*/
- (void)updateOrder:(BOOL)reset {
    NSMutableDictionary *prefs = [[[PrefsManager sharedInstance] readPrefs] mutableCopy] ?: [NSMutableDictionary dictionary];
    
    /*
    BOOL updatedFromOldVersion = ![prefs[@"updatedFromV1"] boolValue];
    if (updatedFromOldVersion){
        reset = YES;
        [[PrefsManager sharedInstance] setValue:@YES forKey:@"updatedFromV1"];
        [self updatedFromOldVersion:updatedFromOldVersion];
    }
     */
    //BOOL newShortcutsAvailable = ([tweakVersion compare:prefs[@"version"] options:NSNumericSearch] == NSOrderedDescending);
    /*
     if (forceDefault){
     [prefs removeObjectForKey:@"shortcuts"];
     prefs[@"version"] = tweakVersion;
     [prefs writeToFile:kPrefsPath atomically:NO];
     }
     */
    //NSMutableDictionary *currentOrderDefault = [[NSMutableDictionary alloc] init];
    
    ShortcutsGenerator *shortcutsGenerator = [ShortcutsGenerator sharedInstance];
    NSMutableArray *defaultOrderLabel = [[shortcutsGenerator labelName] mutableCopy];
    NSMutableArray *defaultOrderSelector = [[shortcutsGenerator selectorNameForLongPress:NO] mutableCopy];
    NSMutableArray *defaultOrderSelectorLP = [[shortcutsGenerator selectorNameForLongPress:YES] mutableCopy];
    NSMutableArray *defaultOrderImages = [[shortcutsGenerator imageNameArrayForiOS:1] mutableCopy];
    
    translomaticInstalled = shortcutsGenerator.translomaticDylibExist;
    
    
    
    NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
    NSMutableArray *firstOrderDict = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [defaultOrderLabel count]; i++){
        if ( i == 0 || i == 6 || i == 35 | i == 36 || i == 37){
            [firstOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images" : defaultOrderImages[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
            }];
        }
        [fullOrderDict addObject: @{
            @"label" : defaultOrderLabel[i],
            @"images" : defaultOrderImages[i],
            @"selector" : defaultOrderSelector[i],
            @"selectorlp" : defaultOrderSelectorLP[i]
        }];
    }
    
    self.firstOrder = firstOrderDict;
    self.fullOrder = fullOrderDict;
    
    
    //reset custom long press actions
    if (reset){
        prefs[kCustomActionskey] = @[];
        prefs[kCustomActionsDTkey] = @[];
        [prefs removeObjectForKey:@"cache"];
        //[prefs removeObjectForKey:kCustomActionskey];
        [[PrefsManager sharedInstance] writePrefs:prefs];
    }
    
    //NSArray *defaultOrder = @[@"Select All", @"Copy", @"Paste", @"Cut", @"Undo", @"Redo"];
    BOOL newShortcutsAvailable = NO;
    if (prefs[@"shortcuts"] && ([prefs[@"shortcuts"] firstObject] != nil)){
        newShortcutsAvailable = defaultOrderLabel.count > ((NSArray *)prefs[@"shortcuts"][0]).count + ((NSArray *)prefs[@"shortcuts"][1]).count;
    }
    self.currentOrder = [NSMutableArray array];
    self.currentOrder[0] = [NSMutableArray array];
    self.currentOrder[1] = [NSMutableArray array];
    if (prefs[@"shortcuts"][0]  && ([prefs[@"shortcuts"][0] firstObject] != nil)  && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"shortcuts"][0] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [self.currentOrder[0] addObject:[currentOrderDefault objectAtIndex:i]];
        }
    }else{
        self.currentOrder[0] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = 0 ; i < maxdefaultshortcuts ; i++) {
            if ([defaultOrderSelector[i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images" : defaultOrderImages[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
            }];
        }
        self.currentOrder[0] = defaultOrderDict;
    }
    if (prefs[@"shortcuts"][1]  && ([prefs[@"shortcuts"][1] firstObject] != nil) && !reset){
        NSMutableArray *currentOrderDefault = [prefs[@"shortcuts"][1] mutableCopy];
        for (NSInteger i = 0; i < [currentOrderDefault count]; i++){
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([[currentOrderDefault objectAtIndex:i][@"selector"] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [self.currentOrder[1] addObject:[currentOrderDefault objectAtIndex:i]];
        }
        if (newShortcutsAvailable){
            NSMutableArray *fullOrderDict = [[NSMutableArray alloc] init];
            for (int i = 0 ; i < [defaultOrderLabel count] ; i++) {
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
                if ([[defaultOrderSelector objectAtIndex:i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
                [fullOrderDict addObject: @{
                    @"label" : defaultOrderLabel[i],
                    @"images" : defaultOrderImages[i],
                    @"selector" : defaultOrderSelector[i],
                    @"selectorlp" : defaultOrderSelectorLP[i]
                }];
            }
            NSMutableArray *newShortcuts = [NSMutableArray arrayWithArray:fullOrderDict];
            [newShortcuts removeObjectsInArray:self.currentOrder[0]];
            [newShortcuts removeObjectsInArray:self.currentOrder[1]];
            for (NSInteger i = 0; i < [newShortcuts count]; i++){
                [self.currentOrder[1] addObject:[newShortcuts objectAtIndex:i]];
            }
            [[PrefsManager sharedInstance] writePrefs:prefs];
        }
    }else if ([prefs[@"shortcuts"][0] count] != defaultOrderLabel.count || reset){
        self.currentOrder[1] = [NSMutableArray array];
        NSMutableArray *defaultOrderDict = [[NSMutableArray alloc] init];
        
        for (int i = maxdefaultshortcuts ; i < [defaultOrderLabel count] ; i++) {
            if ([defaultOrderSelector[i] isEqualToString:@"copyLogAction:"] && !shortcutsGenerator.copyLogDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"translomaticAction:"] && !shortcutsGenerator.translomaticDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"wasabiAction:"] && !shortcutsGenerator.wasabiDylibExist) continue;
            if ([defaultOrderSelector[i] isEqualToString:@"pasitheaAction:"] && !shortcutsGenerator.pasitheaDylibExist) continue;
            [defaultOrderDict addObject: @{
                @"label" : defaultOrderLabel[i],
                @"images" : defaultOrderImages[i],
                @"selector" : defaultOrderSelector[i],
                @"selectorlp" : defaultOrderSelectorLP[i]
            }];
        }
        self.currentOrder[1] = defaultOrderDict;
    }
    
    NSArray *extrasOptionsLabel = @[@"Keyboard Input Behaviour", @"Shell Commands", @"Insert Text Content", @"Previous Word Behaviour", @"Next Word Behaviour", @"Line Start Behaviour", @"Line End Behaviour", @"Start of Paragraph Behaviour", @"End of Paragraph Behaviour", @"Start of Sentence Behaviour", @"End of Sentence Behaviour", @"Delete Behaviour", @"Delete Forward Behaviour", @"Globe Behaviour", @"Paste Behaviour"];
    NSArray *extrasOptionsID = @[@"keyboardType", @"shellCommand", @"insertText", @"prevWord", @"nextWord", @"lineStart", @"lineEnd", @"startOfParagraph", @"endOfParagraph", @"startOfSentence", @"endOfSentence", @"delete", @"deleteForward", @"globe", @"paste"];
    NSArray *extrasOptions13 = @[@"number.circle.fill", @"command", @"text.bubble", @"arrow.left.circle.fill", @"arrow.right.circle.fill", @"arrow.left.to.line", @"arrow.right.to.line", @"text.insert", @"text.append", @"decrease.quotelevel", @"increase.quotelevel", @"delete.left", @"delete.right", @"globe", @"doc.on.clipboard"];
    
    NSMutableArray *extrasOptionsDict = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [extrasOptionsLabel count]; i++){
        [extrasOptionsDict addObject: @{
            @"label" : extrasOptionsLabel[i],
            @"images" : extrasOptions13[i],
            @"identifier" : extrasOptionsID[i],
        }];
    }
    
    self.extrasOptions = extrasOptionsDict;
    
}

-(void)reset{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XPad" message:@"Reset all shortcuts included customized long press and double tap actions to default?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self updateOrder:YES];
        [self.tableView.tableHeaderView removeFromSuperview];
        self.tableView.tableHeaderView = nil;
        self.tableView.userInteractionEnabled = YES;
        [self.tableView reloadData];
        [self writeToFile];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:resetAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if( sourceIndexPath.section != proposedDestinationIndexPath.section )
    {
        return sourceIndexPath;
    }
    else
    {
        return proposedDestinationIndexPath;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[self writeToFile];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateOrder:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"XPadItemCell"];
    [self.tableView setEditing:YES];
    [self.tableView setAllowsSelection:NO];
    self.tableView.allowsSelectionDuringEditing=YES;
    
    ((UIViewController *)self).title = @"Shortcuts";
    self.view = self.tableView;
    self.resetBtn = [[UIBarButtonItem alloc] initWithTitle: @"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(reset)];
    //self.addSnippetBtn.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = self.resetBtn;
}

@end


