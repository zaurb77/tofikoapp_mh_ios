//  SubClass.swift

import Foundation
import UIKit
import KMPlaceholderTextView
import SVProgressHUD
import SDWebImage
import EzPopup

class Main : UIViewController, UITextFieldDelegate {

    let settingModel = SettingsModels.shared
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func getSDWhiteIndicator() -> SDWebImageActivityIndicator {
//        return SDWebImageActivityIndicator.white
//    }
    
    func getSDGrayIndicator() -> SDWebImageActivityIndicator {
        return SDWebImageActivityIndicator.gray
    }
    
    func launchAppUpdatePopup() {
        let appUpdatePopup = AppUpdatePopupVC.instantiate()
        
        let popupVC = PopupViewController(contentController: appUpdatePopup!, popupWidth: self.view.frame.size.width - 50)
        popupVC.cornerRadius = 5
        popupVC.canTapOutsideToDismiss = false
        present(popupVC, animated: true, completion: nil)
    }
    
    func convertStringFrom(date: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        //df.timeZone = TimeZone(identifier: getCurrentTimeZone())
        return df.string(from: date)
    }
}

class CommonFunctions : NSObject {
    static let shared: CommonFunctions = {
        CommonFunctions()
    }()
    
    func showLoader() {
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
    }
    
    func showLoader(_ withPercentage:Float) {
        SVProgressHUD.showProgress(withPercentage)
    }
    
    func hideLoader() {
        UIApplication.shared.endIgnoringInteractionEvents()
        SVProgressHUD.dismiss()
    }
    
}

class KMTextView: KMPlaceholderTextView {
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
}

class CustomButton: UIButton {
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var RightBorder: CGFloat = 0.0 {
        didSet {
            DispatchQueue.main.async {
                let rightBorder = UIView(frame: CGRect(x: self.frame.size.width - self.RightBorder, y: 0, width: self.RightBorder, height: self.frame.size.height))
                rightBorder.backgroundColor = self.RightBorderColor
                self.addSubview(rightBorder)
            }
        }
    }
    
    @IBInspectable var RightBorderColor: UIColor = UIColor.white {
        didSet {
            
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
    @IBInspectable var bottomBorder:CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                let border = CALayer()
                let width = self.bottomBorder
                border.borderColor = UIColor.lightGray.cgColor
                border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
                border.borderWidth = width
                self.layer.addSublayer(border)
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    
}

class CustomStackView: UIStackView {
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
}

class CustomSwitch: UISwitch {
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
}

class CustomUIScrollView: UIScrollView {
    
    @IBInspectable var dropShadow: Bool = false {
        didSet {
            DispatchQueue.main.async {
                let shadowPath = UIBezierPath(rect: self.bounds)
                self.layer.masksToBounds = false
                self.layer.shadowColor = UIColor.lightGray.cgColor
                self.layer.shadowOffset = CGSize(width: -2.0, height: 3.0)
                self.layer.shadowOpacity = 0.5
                self.layer.shadowPath = shadowPath.cgPath
                self.layer.backgroundColor = UIColor.white.cgColor
                self.layoutIfNeeded()
            }
        }
    }
}

class CustomUIView: UIView {
    
    @IBInspectable var dropShadow: Bool = false {
        didSet {
            DispatchQueue.main.async {
                let shadowPath = UIBezierPath(rect: self.bounds)
                self.layer.masksToBounds = false
                self.layer.shadowColor = UIColor.lightGray.cgColor
                self.layer.shadowOffset = CGSize(width: -2.0, height: 3.0)
                self.layer.shadowOpacity = 0.5
                self.layer.shadowPath = shadowPath.cgPath
                //self.layer.backgroundColor = UIColor.white.cgColor
            }
        }
    }
    
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            DispatchQueue.main.async {
                self.layer.cornerRadius = self.Radius
                self.layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable var bottomBorder: CGFloat = 0.0 {
        didSet {
            DispatchQueue.main.async {
                let border = CALayer()
                let width = self.bottomBorder
                border.borderColor = UIColor.darkGray.cgColor
                border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
                border.borderWidth = width
                self.layer.addSublayer(border)
                self.layer.masksToBounds = true
            }
        }
    }

    @IBInspectable var Border: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = Border
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
    @IBInspectable var FourSideShadow: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.FourSideShadow == true {
                    self.layoutSubviews()
                    self.layoutIfNeeded()
                    self.setNeedsDisplay()
                    let shadowSize : CGFloat = 0.3
                    let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                               y: -shadowSize / 2,
                                                               width: self.frame.size.width + shadowSize,
                                                               height: self.frame.size.height + shadowSize))
                    self.layer.masksToBounds = false
                    self.layer.shadowColor = UIColor.lightGray.cgColor
                    self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
                    self.layer.shadowOpacity = 0.3
                    self.layer.shadowPath = shadowPath.cgPath
                    self.layer.shadowRadius = self.Radius
                    self.layer.cornerRadius = self.Radius
                }
            }
        }
    }
}

class CustomTextView: UITextView {
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
}

class CustomLabel: UILabel{
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
}

class CustomUITableView: UITableView {
    @IBInspectable var FooterView: UIView = UIView() {
        didSet {
            self.tableFooterView = FooterView
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
    
}

class CustomTextField: UITextField {
    @IBInspectable var dropShadow: Bool = false {
        didSet {
            DispatchQueue.main.async {
                let shadowPath = UIBezierPath(rect: self.bounds)
                self.layer.masksToBounds = false
                self.layer.shadowColor = UIColor.black.cgColor
                self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
                self.layer.shadowOpacity = 0.5
                self.layer.shadowPath = shadowPath.cgPath
            }
        }
    }
    
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
        }
    }
    
    @IBInspectable var LeftSpace: CGFloat = 0 {
        didSet {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: LeftSpace, height: self.frame.size.height))
            view.backgroundColor = UIColor.clear
            self.leftView = view
            self.leftViewMode = .always
        }
    }
    
    @IBInspectable var LeftImage: UIImage? {
        didSet {
            let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 70, height: self.frame.size.height))
            iv.image = LeftImage
            iv.contentMode = .scaleAspectFit
            self.leftView = iv
            self.leftViewMode = .always
        }
    }
    
    @IBInspectable var RightSpace: CGFloat = 0 {
        didSet {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: RightSpace, height: self.frame.size.height))
            view.backgroundColor = UIColor.clear
            self.rightView = view
            self.rightViewMode = .always
        }
    }
    
    @IBInspectable var RightImage: UIImage? {
        didSet {
            let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
            iv.image = RightImage
            iv.contentMode = .scaleAspectFit
            self.rightView = iv
            self.rightViewMode = .always
        }
    }
    
    @IBInspectable var bottomBorder:CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                let border = CALayer()
                let width = self.bottomBorder
                border.borderColor = UIColor.black.cgColor
                border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
                border.borderWidth = width
                self.layer.addSublayer(border)
                self.layer.masksToBounds = true
            }
        }
    }
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
}

class CustomImageView : UIImageView{
    @IBInspectable var Radius: CGFloat = 0.0 {
        didSet {
//            DispatchQueue.main.async {
            self.layer.cornerRadius = Radius
            self.layer.masksToBounds = true
//                self.layoutIfNeeded()
//            }
            
        }
    }
    
    @IBInspectable var FourSideShadow: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.FourSideShadow == true {
                    self.layoutSubviews()
                    self.layoutIfNeeded()
                    self.setNeedsDisplay()
                    let shadowSize : CGFloat = 5.0
                    let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                               y: -shadowSize / 2,
                                                               width: self.frame.size.width + shadowSize,
                                                               height: self.frame.size.height + shadowSize))
                    self.layer.masksToBounds = false
                    self.layer.shadowColor = UIColor.gray.cgColor
                    self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
                    self.layer.shadowOpacity = 0.5
                    self.layer.shadowPath = shadowPath.cgPath
                    self.layer.shadowRadius = self.Radius
                    self.layer.cornerRadius = self.Radius
                }
            }
        }
    }
    
    @IBInspectable var BorderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = BorderWidth
        }
    }
    
    @IBInspectable var BorderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = BorderColor.cgColor
        }
    }
}
public class CustomUIViewWhiteShadow: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        setShadow()
        backgroundColor      = UIColor.white
        layer.cornerRadius   = 10
        
    }
    
    private func setShadow() {
        layer.shadowColor   = UIColor.gray.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 3.0)
        layer.shadowRadius  = 5
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
    
}
