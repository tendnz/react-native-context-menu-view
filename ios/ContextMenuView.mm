//
//  ContextMenu.m
//  reactnativeuimenu
//
//  Created by Matthew Iannucci on 10/6/19.
//  Copyright © 2019 Matthew Iannucci. All rights reserved.
//

#import "ContextMenuView.h"
#import <React/UIView+React.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <react/renderer/components/view/ViewComponentDescriptor.h>
#import <react/renderer/components/view/ViewEventEmitter.h>
#import <react/renderer/components/view/ViewProps.h>
#import <react/renderer/components/react-native-context-menu-view-specs/ComponentDescriptors.h>
#import <react/renderer/components/react-native-context-menu-view-specs/EventEmitters.h>
#import <react/renderer/components/react-native-context-menu-view-specs/Props.h>
#import <react/renderer/components/react-native-context-menu-view-specs/RCTComponentViewHelpers.h>
#import <React/RCTFabricComponentsPlugins.h>

#import <React/RCTAssert.h>
#import <React/RCTBorderDrawing.h>

#import <React/RCTConversions.h>
#import <React/RCTConvert.h>
#endif

using namespace facebook::react;
@interface ContextMenuView () <RCTContextMenuViewProtocol>

- (UIMenuElement*) createMenuElementForAction:(ContextMenuAction *)action atIndexPath:(NSArray<NSNumber *> *) idx API_AVAILABLE(ios(13.0));

@end

@implementation ContextMenuView {
  BOOL _cancelled;
  UIView *_customView;
}


- (instancetype) init {
  self = [super init];
#ifdef RCT_NEW_ARCH_ENABLED
  static const auto defaultProps = std::make_shared<const ContextMenuProps>();
  _props = defaultProps;
#else
  
  if (@available(iOS 13.0, *)) {
    self.contextMenuInteractionEnabled = true;
  } else {
    // Fallback on earlier versions
  }
  
#endif
  
  return self;
}

#ifdef RCT_NEW_ARCH_ENABLED
+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<ContextMenuComponentDescriptor>();
}

- (void)mountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
  if ([childComponentView.nativeID isEqualToString:@"ContextMenuPreview"]) {
    _customView = childComponentView;
    return;
  }
  [super mountChildComponentView:childComponentView index:index];
  
  if (@available(iOS 13.0, *)) {
    UIContextMenuInteraction* contextInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
    
    [childComponentView addInteraction:contextInteraction];
  }
}

- (void)unmountChildComponentView:(UIView<RCTComponentViewProtocol> *)childComponentView index:(NSInteger)index {
  if ([childComponentView.nativeID isEqualToString:@"ContextMenuPreview"]) {
    _customView = childComponentView;
    return;
  }
  
  [super unmountChildComponentView:childComponentView index:index];
}

- (void) updateProps:(const facebook::react::Props::Shared &)props oldProps:(const facebook::react::Props::Shared &)oldProps {
  const auto &oldViewProps = *std::static_pointer_cast<ContextMenuProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<ContextMenuProps const>(props);
  
  self.disabled = newViewProps.disabled;
  
  if (newViewProps.backgroundColor != oldViewProps.backgroundColor) {
    if (newViewProps.backgroundColor) {
      const ColorComponents components = colorComponentsFromColor(newViewProps.backgroundColor);
      self.backgroundColor = [UIColor colorWithRed:components.red green:components.green blue:components.blue alpha:components.alpha];
    } else {
      self.backgroundColor = nil;
    }
  }
  
    if (newViewProps.actions.size() == 0) {
      self.actions = @[];
    } else {
      NSMutableArray *newActions = [NSMutableArray new];
      for (auto action: newViewProps.actions) {
        ContextMenuAction *newAction = [[ContextMenuAction alloc] init];
        newAction.title = [NSString stringWithUTF8String:action.title.c_str()];
        newAction.subtitle = [NSString stringWithUTF8String:action.subtitle.c_str()];
        newAction.systemIcon = [NSString stringWithUTF8String:action.systemIcon.c_str()];
        newAction.destructive = action.destructive;
        newAction.selected = action.selected;
        newAction.disabled = action.disabled;
        newAction.inlineChildren = action.inlineChildren;
        
        [newActions addObject:newAction];
      }
      self.actions = newActions;
    }
  
  [super updateProps:props oldProps:oldProps];
}
#else

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  if ([subview.nativeID isEqualToString:@"ContextMenuPreview"]) {
    _customView = subview;
    return;
  }
  
  [super insertReactSubview:subview atIndex:atIndex];
  
  if (@available(iOS 13.0, *)) {
    UIContextMenuInteraction* contextInteraction = [[UIContextMenuInteraction alloc] initWithDelegate:self];
    
    [subview addInteraction:contextInteraction];
  }
}

- (void)removeReactSubview:(UIView *)subview
{
  [super removeReactSubview:subview];
}

- (void)didUpdateReactSubviews
{
  [super didUpdateReactSubviews];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
}

#endif

- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(nonnull UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location API_AVAILABLE(ios(13.0)) {
  if (_disabled) {
    return nil;
  }
  
  auto previewProvider = _customView == nil ? static_cast<UIViewController *(^)()>(nil) : ^(){
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.preferredContentSize = self->_customView.frame.size;
    viewController.view = self->_customView;
    return viewController;
  };
  
  auto actionProvider =^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
    NSMutableArray* actions = [[NSMutableArray alloc] init];
    
    [self.actions enumerateObjectsUsingBlock:^(ContextMenuAction* thisAction, NSUInteger idx, BOOL *stop) {
      UIMenuElement *menuElement = [self createMenuElementForAction:thisAction atIndexPath:[NSArray arrayWithObject:@(idx)]];
      [actions addObject:menuElement];
    }];
    
    return [UIMenu menuWithTitle:self.title children:actions];
  };
  
  
  return [UIContextMenuConfiguration
          configurationWithIdentifier:nil
          previewProvider:previewProvider
          actionProvider:actionProvider];

}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willDisplayMenuForConfiguration:(UIContextMenuConfiguration *)configuration animator:(id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(13.0)) {
  _cancelled = true;
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willEndForConfiguration:(UIContextMenuConfiguration *)configuration animator:(id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(13.0)) {
  
#ifdef RCT_NEW_ARCH_ENABLED
  if (_cancelled && _eventEmitter != nullptr) {
    std::dynamic_pointer_cast<const ContextMenuEventEmitter>(_eventEmitter)
    ->onCancel(ContextMenuEventEmitter::OnCancel{});
  }
#else
  if (_cancelled && self.onCancel) {
    self.onCancel(@{});
  }
#endif
}

- (UITargetedPreview *)contextMenuInteraction:(UIContextMenuInteraction *)interaction previewForHighlightingMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(13.0)) {
#ifdef RCT_NEW_ARCH_ENABLED
  UIPreviewTarget* previewTarget = [[UIPreviewTarget alloc] initWithContainer:self.superview center:self.center];
  UIPreviewParameters* previewParams = [[UIPreviewParameters alloc] init];
  
  if (_previewBackgroundColor != nil) {
    previewParams.backgroundColor = _previewBackgroundColor;
  }
  
  return [[UITargetedPreview alloc] initWithView:self
                                      parameters:previewParams
                                          target:previewTarget];
#else
  
  UIPreviewTarget* previewTarget = [[UIPreviewTarget alloc] initWithContainer:self center:self.reactSubviews.firstObject.center];
  UIPreviewParameters* previewParams = [[UIPreviewParameters alloc] init];
  
  if (_previewBackgroundColor != nil) {
    previewParams.backgroundColor = _previewBackgroundColor;
  }
  
  return [[UITargetedPreview alloc] initWithView:self.reactSubviews.firstObject
                                      parameters:previewParams
                                          target:previewTarget];
#endif
}

- (UIMenuElement*) createMenuElementForAction:(ContextMenuAction *)action atIndexPath:(NSArray<NSNumber *> *)indexPath {
  UIMenuElement* menuElement = nil;
  if (action.actions != nil && action.actions.count > 0) {
    NSMutableArray<UIMenuElement*> *children = [[NSMutableArray alloc] init];
    [action.actions enumerateObjectsUsingBlock:^(ContextMenuAction * _Nonnull childAction, NSUInteger childIdx, BOOL * _Nonnull stop) {
      id nextIndexPath = [indexPath arrayByAddingObject:@(childIdx)];
      UIMenuElement *childElement = [self createMenuElementForAction:childAction atIndexPath:nextIndexPath];
      if (childElement != nil) {
        [children addObject:childElement];
      }
    }];
    
    UIMenuOptions actionMenuOptions =
    (action.inlineChildren ? UIMenuOptionsDisplayInline : 0) |
    (action.destructive ? UIMenuOptionsDestructive : 0);
    UIMenu *actionMenu = [UIMenu menuWithTitle:action.title
                                         image:[UIImage systemImageNamed:action.systemIcon]
                                    identifier:nil
                                       options:actionMenuOptions
                                      children:children];
    
    if (@available(iOS 15.0, *)) {
      actionMenu.subtitle = action.subtitle;
    }
    
    menuElement = actionMenu;
  } else {
    UIAction* actionMenuItem =
    [UIAction actionWithTitle:action.title image:[UIImage systemImageNamed:action.systemIcon] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
#ifdef RCT_NEW_ARCH_ENABLED
      if (self->_eventEmitter != nullptr) {
          std::dynamic_pointer_cast<const ContextMenuEventEmitter>(self->_eventEmitter)
        ->onPress(ContextMenuEventEmitter::OnPress{
          .name = [action.title cStringUsingEncoding:NSUTF8StringEncoding],
          .index = [[indexPath lastObject] intValue],
          .indexPath = std::string()
        });
        
      }
#else
      if (self.onPress != nil) {
        self->_cancelled = false;
        self.onPress(@{
          @"index": [indexPath lastObject],
          @"indexPath": indexPath,
          @"name": action.title,
        });
      }
#endif
    }];
    
    if (@available(iOS 15.0, *)) {
      actionMenuItem.subtitle = action.subtitle;
    }
    
    actionMenuItem.attributes =
    (action.destructive ? UIMenuElementAttributesDestructive : 0) |
    (action.disabled ? UIMenuElementAttributesDisabled : 0);
    
    actionMenuItem.state =
    action.selected ? UIMenuElementStateOn : UIMenuElementStateOff;
    
    menuElement = actionMenuItem;
  }
  
  return menuElement;
}
@end

#ifdef RCT_NEW_ARCH_ENABLED
Class<RCTComponentViewProtocol> ContextMenuCls(void)
{
  return  ContextMenuView.class;
}
#endif
