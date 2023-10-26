#import "ContextMenuManager.h"
#import "ContextMenuView.h"

@implementation ContextMenuManager

RCT_EXPORT_MODULE(ContextMenu)

RCT_EXPORT_VIEW_PROPERTY(title, NSString)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onCancel, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(actions, NSArray<ContextMenuAction>)
RCT_EXPORT_VIEW_PROPERTY(disabled, BOOL)
RCT_CUSTOM_VIEW_PROPERTY(previewBackgroundColor, UIColor, ContextMenuView) {
  view.previewBackgroundColor = json != nil ? [RCTConvert UIColor:json] : nil;
}
RCT_CUSTOM_VIEW_PROPERTY(dropdownMenuMode, BOOL, ContextMenuView) {
#ifndef RCT_NEW_ARCH_ENABLED
    if (@available(iOS 14.0, *)) {
        view.showsMenuAsPrimaryAction = json != nil ? [RCTConvert BOOL:json] : view.showsMenuAsPrimaryAction;
    } else {
        // This is not available on other versions... sorry!
    }
#endif
}

@end
