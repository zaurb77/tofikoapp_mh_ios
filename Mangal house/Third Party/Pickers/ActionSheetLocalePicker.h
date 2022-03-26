

#import "AbstractActionSheetPicker.h"

@class ActionSheetLocalePicker;
typedef void(^ActionLocaleDoneBlock)(ActionSheetLocalePicker *picker, NSTimeZone * selectedValue);
typedef void(^ActionLocaleCancelBlock)(ActionSheetLocalePicker *picker);

static const float firstColumnWidth = 100.0f;
static const float secondColumnWidth = 160.0f;

@interface ActionSheetLocalePicker : AbstractActionSheetPicker <UIPickerViewDelegate, UIPickerViewDataSource>

/**
 *  Create and display an action sheet picker.
 *
 *  @param title             Title label for picker
 *  @param data              is an array of strings to use for the picker's available selection choices
 *  @param index             is used to establish the initially selected row;
 *  @param target            must not be empty.  It should respond to "onSuccess" actions.
 *  @param successAction
 *  @param cancelActionOrNil cancelAction
 *  @param origin            must not be empty.  It can be either an originating container view or a UIBarButtonItem to use with a popover arrow.
 *
 *  @return  return instance of picker
 */
+ (instancetype)showPickerWithTitle:(NSString *)title initialSelection:(NSTimeZone *)index target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin;

// Create an action sheet picker, but don't display until a subsequent call to "showActionPicker".  Receiver must release the picker when ready. */
- (instancetype)initWithTitle:(NSString *)title initialSelection:(NSTimeZone *)index target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin;

+ (instancetype)showPickerWithTitle:(NSString *)title initialSelection:(NSTimeZone *)index doneBlock:(ActionLocaleDoneBlock)doneBlock cancelBlock:(ActionLocaleCancelBlock)cancelBlock origin:(id)origin;

- (instancetype)initWithTitle:(NSString *)title initialSelection:(NSTimeZone *)timeZone doneBlock:(ActionLocaleDoneBlock)doneBlock cancelBlock:(ActionLocaleCancelBlock)cancelBlockOrNil origin:(id)origin;

@property (nonatomic, copy) ActionLocaleDoneBlock onActionSheetDone;
@property (nonatomic, copy) ActionLocaleCancelBlock onActionSheetCancel;

@end
