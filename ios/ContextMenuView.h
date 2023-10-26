//
//  ContextMenu.h
//  reactnativeuimenu
//
//  Created by Matthew Iannucci on 10/6/19.
//  Copyright © 2019 Matthew Iannucci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <React/RCTViewComponentView.h>
#import <react/renderer/components/react-native-context-menu-view-specs/Props.h>
#endif

#import "ContextMenuAction.h"

@interface ContextMenuView :
#ifdef RCT_NEW_ARCH_ENABLED
RCTViewComponentView<UIContextMenuInteractionDelegate> { }
#else
UIControl<UIContextMenuInteractionDelegate>
#endif

@property (nonnull, nonatomic, copy) NSString* title;
#ifndef RCT_NEW_ARCH_ENABLED
@property (nullable, nonatomic, copy) RCTBubblingEventBlock onPress;
@property (nullable, nonatomic, copy) RCTBubblingEventBlock onCancel;
#endif
@property (nullable, nonatomic, copy) NSArray<ContextMenuAction*>* actions;
@property (nullable, nonatomic, copy) UIColor* previewBackgroundColor;
@property (nonatomic, assign) BOOL disabled;

@end
