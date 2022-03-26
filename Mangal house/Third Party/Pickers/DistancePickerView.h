
#import <UIKit/UIKit.h>


@interface DistancePickerView : UIPickerView {
    NSMutableDictionary *labels;
}

- (void) addLabel:(NSString *)labeltext forComponent:(NSUInteger)component forLongestString:(NSString *)longestString;
- (void) updateLabel:(NSString *)labeltext forComponent:(NSUInteger)component;
@end
