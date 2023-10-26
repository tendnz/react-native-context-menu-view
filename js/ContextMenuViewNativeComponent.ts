import type {ColorValue, HostComponent} from 'react-native';
import type {ViewProps} from 'react-native/Libraries/Components/View/ViewPropTypes';
import {BubblingEventHandler, Int32, WithDefault} from 'react-native/Libraries/Types/CodegenTypes';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';

export interface ContextMenuAction {
  /**
   * The title of the action
   */
  title: string;
  /**
   * The subtitle of the action. iOS 15+.
   */
  subtitle?: WithDefault<string, ''>;
  /**
   * The icon to use on ios. This is the name of the SFSymbols icon to use. On Android nothing will happen if you set this option.
   */
  systemIcon?: WithDefault<string, ''>;
  /**
   * Destructive items are rendered in red on iOS, and unchanged on Android. (default: false)
   */
  destructive?: WithDefault<boolean, false>;
  /**
   * Selected items have a checkmark next to them on iOS, and unchanged on Android. (default: false)
   */
  selected?: WithDefault<boolean, false>;
  /**
   * Whether the action is disabled or not (default: false)
   */
  disabled?: WithDefault<boolean, false>;
  /**
   * Whether its children (if any) should be rendered inline instead of in their own child menu (default: false, iOS only)
   */
  inlineChildren?: WithDefault<boolean, false>;
  //   /**
  //    * Child actions. When child actions are supplied, the childs callback will contain its name but the same index as the topmost parent menu/action index. (iOS Only)
  //    */
  //   //actions?: Array<ContextMenuAction>;
}

export interface ContextMenuOnPressNativeEvent {
  index: Int32;
  indexPath: string;
  name: string;
}

export interface NativeProps extends ViewProps {
  /**
   * The title of the menu
   */
  title?: string;
  /**
   * The actions to show the user when the menu is activated
   */
  actions?: Array<ContextMenuAction>;
  /**
   * Handle when an action is triggered and the menu is closed. The name of the selected action will be passed in the event.
   */
  onPress?: BubblingEventHandler<ContextMenuOnPressNativeEvent>;
  /**
   * Handle when the menu is cancelled and closed
   */
  onCancel?: BubblingEventHandler<{}>;
  /**
   * The background color of the preview. This is displayed underneath your view. Set this to transparent (or another color) if the default causes issues.
   */
  previewBackgroundColor?: ColorValue;
  /**
   * Custom preview component.
   */
  //preview?: React.ReactNode;
  /**
   * When enabled, uses iOS 14 menu mode, and shows the context menu on a single tap with no zoomed preview.
   */
  dropdownMenuMode?: WithDefault<boolean, false>;
  /**
   * Currently iOS only. Disable menu interaction
   */
  disabled?: WithDefault<boolean, false>;
}

export default codegenNativeComponent<NativeProps>('ContextMenu') as HostComponent<NativeProps>;
