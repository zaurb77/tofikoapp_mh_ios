

#import "AbstractActionSheetPicker.h"
#import "DistancePickerView.h"
@interface ActionSheetDistancePicker : AbstractActionSheetPicker <UIPickerViewDelegate, UIPickerViewDataSource>

+ (id)showPickerWithTitle:(NSString *)title bigUnitString:(NSString *)bigUnitString bigUnitMax:(NSInteger)bigUnitMax selectedBigUnit:(NSInteger)selectedBigUnit smallUnitString:(NSString*)smallUnitString smallUnitMax:(NSInteger)smallUnitMax selectedSmallUnit:(NSInteger)selectedSmallUnit target:(id)target action:(SEL)action origin:(id)origin;

- (id)initWithTitle:(NSString *)title bigUnitString:(NSString *)bigUnitString bigUnitMax:(NSInteger)bigUnitMax selectedBigUnit:(NSInteger)selectedBigUnit smallUnitString:(NSString*)smallUnitString smallUnitMax:(NSInteger)smallUnitMax selectedSmallUnit:(NSInteger)selectedSmallUnit target:(id)target action:(SEL)action origin:(id)origin;
@end
