#import "XPPGesturePickerController.h"
#import "XPPCustomActionViewController.h"
#import "../common.h"

@implementation XPPGesturePickerController

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *snippetEntrySpecifiers = [[NSMutableArray alloc] init];
        
        PSSpecifier *gestureTypeGroup = [PSSpecifier preferenceSpecifierNamed:@"Gestures" target:nil set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
        [snippetEntrySpecifiers addObject:gestureTypeGroup];

        PSSpecifier *longPressSpec = [PSSpecifier preferenceSpecifierNamed:@"Long Press" target:nil set:nil get:nil detail:NSClassFromString(@"XPPGesturePickerController") cell:PSLinkListCell edit:nil];
        [longPressSpec setProperty:@"Long Press" forKey:@"label"];
        [snippetEntrySpecifiers addObject:longPressSpec];
        
        PSSpecifier *doubleTapSpec = [PSSpecifier preferenceSpecifierNamed:@"Double Tap" target:nil set:nil get:nil detail:NSClassFromString(@"XPPGesturePickerController") cell:PSLinkListCell edit:nil];
        [doubleTapSpec setProperty:@"Double Tap" forKey:@"label"];
        [snippetEntrySpecifiers addObject:doubleTapSpec];
        
    
        
        _specifiers = snippetEntrySpecifiers;
        
    }
    
    return _specifiers;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    XPPCustomActionViewController *actionViewController = [[XPPCustomActionViewController alloc] init];

    actionViewController.fullOrder = self.fullOrder;
    actionViewController.identifier = self.identifier;
    
    switch (indexPath.row) {
        case 0:
            actionViewController.keyID = kCustomActionskey;
            break;
        case 1:
            actionViewController.keyID = kCustomActionsDTkey;
            break;
        case 2:
            actionViewController.keyID = kCustomActionsSTkey;
            break;
        default:
            actionViewController.keyID = kCustomActionskey;
            break;
    }
    
    actionViewController.title = cell.textLabel.text;
    
    [actionViewController setRootController: [self rootController]];
    [actionViewController setParentController: [self parentController]];
    [self pushController:actionViewController];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

}

@end
