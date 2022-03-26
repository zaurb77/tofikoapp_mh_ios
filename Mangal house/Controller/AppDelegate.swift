//
//  AppDelegate.swift
//  Mangal house
//
//  Created by Mahajan on 19/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import IQKeyboardManager
import GooglePlaces
import Stripe
import Firebase
import FirebaseInstanceID
import FirebaseMessaging

var company_id = 1

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
    var deviceToken: String?
    var navigationController : UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        company_id = 1
        
        IQKeyboardManager.shared().isEnabled = true
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        registerRemoteNotifications(application)
                
        GMSPlacesClient.provideAPIKey("AIzaSyDnwVsJT81wVvk3ER1kbjebezFzBTzu4i4")
        Stripe.setDefaultPublishableKey("pk_live_hqbv05KP6UzG5lg7fZL3Cjrb00tWU1AXfd")
//        Stripe.setDefaultPublishableKey("pk_test_cOH61omzxr1KOycuCHvtZ8Jw00KO8hLqBW")
        
        call_CheckAppVersion()
        
        LocationManager.sharedInstance.beginLocationUpdating()
        LocationManager.sharedInstance.checkLocationManagerAuthorizationStatus()
        LocationManager.sharedInstance.startLocationUpdating()
        
//        let locationManager = LocationManager.sharedInstance
//        locationManager.beginLocationUpdating{ (latitude, longitude, status, verboseMessage, error) -> () in
//
//            if error != nil {
//                let alert=UIAlertController(title: status, message: verboseMessage, preferredStyle: UIAlertController.Style.alert);
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil));
//                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) in
//                    let settingsURL = NSURL(string: UIApplication.openSettingsURLString)
//                    UIApplication.shared.openURL(settingsURL! as URL)
//                }));
//            } else {
//                print(locationManager.latitude)
//                print(locationManager.longitude)
//            }
//        }
        
        call_Get_Language()
        
//        if UserModel.sharedInstance().user_id != nil && UserModel.sharedInstance().user_id! != "" {
////            callCartIDAPI()
//            resetPushCounter()
//            
//            self.ChangeRoot_Home()
//        }else if UserModel.sharedInstance().isGuestLogin != nil && UserModel.sharedInstance().isGuestLogin! != ""  && UserModel.sharedInstance().isGuestLogin! == "1"{
//            self.ChangeRoot_Home()
//        }
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    
    func ChangeRoot_Home() {
        let homeSB = UIStoryboard(name: "Main", bundle: nil)
        let desiredViewController = homeSB.instantiateViewController(withIdentifier: "toHome") as! UINavigationController
        let appdel = UIApplication.shared.delegate as! AppDelegate
        let snapshot:UIView = (appdel.window?.snapshotView(afterScreenUpdates: true))!
        desiredViewController.view.addSubview(snapshot);
        
        appdel.window?.rootViewController = desiredViewController;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
    
    func ChangeRoot_Login() {
        let homeSB = UIStoryboard(name: "Main", bundle: nil)
        let desiredViewController = homeSB.instantiateViewController(withIdentifier: "toLogin") as! UINavigationController
        let appdel = UIApplication.shared.delegate as! AppDelegate
        let snapshot:UIView = (appdel.window?.snapshotView(afterScreenUpdates: true))!
        desiredViewController.view.addSubview(snapshot);
        
        appdel.window?.rootViewController = desiredViewController;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }

    //MARK:- Push Notification Methods
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        InstanceID.instanceID().instanceID { (result, error) in
          if let error = error {
            print("Error fetching remote instance ID: \(error)")
          } else if let result = result {
            self.deviceToken = result.token
            if self.deviceToken != "" {
                UserModel.sharedInstance().deviceToken = self.deviceToken
                UserModel.sharedInstance().synchroniseData()
            }
            print("Remote instance ID token: \(result.token)")
          }
        }
    }
        
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        let message = (aps["alert"] as! [String:AnyObject])["body"] as! String

        if (application.applicationState == .active) {
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            
            let alertController = UIAlertController(title: Constant.PROJECT_NAME as String, message: message, preferredStyle: .alert)
            let btnCancelAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }
            alertController.addAction(btnCancelAction)
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            
        }else{
            
            //order_accept, order_decline, order_delivery, order_complete, order_rating_reply
            if UserModel.sharedInstance().user_id != nil{
                
                if let type = userInfo["type"] as? String {
                
                    if type == "order_accept" || type == "order_delivery"{
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                        viewController2.isNotification = true
                        viewController2.selectedTab = "in_prepare"
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                    }else if type == "order_time_change" {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                        viewController2.isNotification = true
                        viewController2.selectedTab = "pending"
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                    }else if type == "order_complete" || type == "order_rating_reply" || type == "rate_order" || type == "order_decline" {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                        viewController2.isNotification = true
                        viewController2.selectedTab = "completed"
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                        
                    }else if type == "booking" {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController2 = mainStoryboard.instantiateViewController(withIdentifier: "ReservationHistoryVC") as! ReservationHistoryVC
                        viewController2.isNotification = true
                        self.navigationController = UINavigationController .init(rootViewController: viewController2)
                        self.window?.rootViewController = self.navigationController
                        
                    }else{
                        ChangeRoot_Home()
                    }
                }
                
            }
        }
    }
    
    func registerRemoteNotifications(_ application:UIApplication) {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
    }
    
    //MARK:- DEEP-LINKING Code
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            
            if UserModel.sharedInstance().user_id != nil && UserModel.sharedInstance().user_id! != "" {
                if url.absoluteString == "https://mangal.page.link/paypal" {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "OrderAckVC") as! OrderAckVC
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }else if url.absoluteString == "https://mangal.page.link/paypal_fail" {
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    self.window?.rootViewController = vc
                    self.window?.makeKeyAndVisible()
                }
            }
            
            return true
        }

        return false
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) != nil {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...

            return true
        }
        return false
    }
    
    //MARK:- Webservices
    func resetPushCounter() {
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.UPDATE_PUSH_CNT
        let params = "user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&device_token=\(UserModel.sharedInstance().deviceToken!)"
        
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            print(response)
            
        }) { (error) in
            print(error)
        }
        
    }
    
    func call_Get_Language() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        //UserModel.sharedInstance().app_language!
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_LANGUAGE
        
        if UserModel.sharedInstance().app_language == nil {
            UserModel.sharedInstance().app_language = "2"
            UserModel.sharedInstance().synchroniseData()
        }
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                                                        
                            Language.LOGIN = responseData["LOGIN"] as! String
                            Language.EMAIL_ADDRESS = responseData["EMAIL_ADDRESS"] as! String
                            Language.PASSWORD = responseData["PASSWORD"] as! String
                            Language.FORGOT_PASS = responseData["FORGOT_PASS"] as! String
                            Language.OR = responseData["OR"] as! String
                            Language.REGISTER = responseData["REGISTER"] as! String
                            Language.WITHOUT_LOGIN = responseData["WITHOUT_LOGIN"] as! String
                            Language.SIGN_AGREEMENT = responseData["SIGN_AGREEMENT"] as! String
                            Language.TERMS_AND_CONDITIONS = responseData["TERMS_AND_CONDITIONS"] as! String
                            Language.AND = responseData["AND"] as! String
                            Language.PRIVACY_POLICY = responseData["PRIVACY_POLICY"] as! String
                            Language.SUBMIT = responseData["SUBMIT"] as! String
                            Language.SECURITY_CODE = responseData["SECURITY_CODE"] as! String
                            Language.SECURITY_CODE_MSG = responseData["SECURITY_CODE_MSG"] as! String
                            Language.NEXT = responseData["NEXT"] as! String
                            Language.SET_PASSWORD = responseData["SET_PASSWORD"] as! String
                            Language.NEW_PASS = responseData["NEW_PASS"] as! String
                            Language.CONFIRM_PASS = responseData["CONFIRM_PASS"] as! String
                            Language.SAVE = responseData["SAVE"] as! String
                            Language.FNAME = responseData["FNAME"] as! String
                            Language.LNAME = responseData["LNAME"] as! String
                            Language.PHONE_NUMBER = responseData["PHONE_NUMBER"] as! String
                            Language.REFERRAL_CODE = responseData["REFERRAL_CODE"] as! String
                            Language.ALREADY_LOGIN = responseData["ALREADY_LOGIN"] as! String
                            Language.SELECT_COUNTRY = responseData["SELECT_COUNTRY"] as! String
                            Language.GALLERY = responseData["GALLERY"] as! String
                            Language.CAMERA = responseData["CAMERA"] as! String
                            Language.CANCEL = responseData["CANCEL"] as! String
                            Language.PROVIDE_PROFILE_IMG = responseData["PROVIDE_PROFILE_IMG"] as! String
                            Language.ACCEPT_TERMS_CONDITIONS = responseData["ACCEPT_TERMS_CONDITIONS"] as! String
                            Language.I_AGREE = responseData["I_AGREE"] as! String
                            Language.ADD = responseData["ADD"] as! String
                            Language.ORDER_FROM_MENU = responseData["ORDER_FROM_MENU"] as! String
                            Language.INVITE_FRIENDS_LABEL = responseData["INVITE_FRIENDS_LABEL"] as! String
                            Language.MY_ORDER_HISTORY = responseData["MY_ORDER_HISTORY"] as! String
                            Language.SPECIAL_OFFERS = responseData["SPECIAL_OFFERS"] as! String
                            Language.WHERE_WE_ARE = responseData["WHERE_WE_ARE"] as! String
                            Language.ABOUT_US = responseData["ABOUT_US"] as! String
                            Language.MY_ACCOUNT = responseData["MY_ACCOUNT"] as! String
                            Language.REPLACE_CART_ITEM = responseData["REPLACE_CART_ITEM"] as! String
                            Language.CART_CONTAINS_FROM = responseData["CART_CONTAINS_FROM"] as! String
                            Language.DISCARD_SELECTION = responseData["DISCARD_SELECTION"] as! String
                            Language.YES_LABEL = responseData["YES_LABEL"] as! String
                            Language.NO_LABEL = responseData["NO_LABEL"] as! String
                            Language.HOME = responseData["HOME"] as! String
                            Language.MY_CART = responseData["MY_CART"] as! String
                            Language.ORDER_HISTORY = responseData["ORDER_HISTORY"] as! String
                            Language.CUSTOMER_SERVICE = responseData["CUSTOMER_SERVICE"] as! String
                            Language.SETTING = responseData["SETTING"] as! String
                            Language.SHARE_AND_EARN = responseData["SHARE_AND_EARN"] as! String
                            Language.LOGOUT = responseData["LOGOUT"] as! String
                            Language.LOGOUT_CONFIRM = responseData["LOGOUT_CONFIRM"] as! String
                            Language.MY_MANGALS = responseData["MY_MANGALS"] as! String
                            Language.MY_MANGAL_POINT = responseData["MY_MANGAL_POINT"] as! String
                            Language.AVAILABLE_OFFERS = responseData["AVAILABLE_OFFERS"] as! String
                            Language.FROM = responseData["FROM"] as! String
                            Language.VERSION = responseData["VERSION"] as! String
                            Language.CONTINUE = responseData["CONTINUE"] as! String
                            Language.SELECT_LANGUAGE = responseData["SELECT_LANGUAGE"] as! String
                            Language.EDIT_PROFILE = responseData["EDIT_PROFILE"] as! String
                            Language.PUSH_NOTIFICATION = responseData["PUSH_NOTIFICATION"] as! String
                            Language.LANGUAGE = responseData["LANGUAGE"] as! String
                            Language.COOKIES = responseData["COOKIES"] as! String
                            Language.ORDER_NOTIFICATION = responseData["ORDER_NOTIFICATION"] as! String
                            Language.NEWS_AND_OFFERS = responseData["NEWS_AND_OFFERS"] as! String
                            Language.EMAIL_NOTIFICATION = responseData["EMAIL_NOTIFICATION"] as! String
                            Language.COOKIE_POLICY = responseData["COOKIE_POLICY"] as! String
                            Language.CONTACT_SUPPORT = responseData["CONTACT_SUPPORT"] as! String
                            Language.STILL_QUESTIONS = responseData["STILL_QUESTIONS"] as! String
                            Language.NAME = responseData["NAME"] as! String
                            Language.MOBILE_NUMBER = responseData["MOBILE_NUMBER"] as! String
                            Language.MESSAGE = responseData["MESSAGE"] as! String
                            Language.LIKE_MANGAL = responseData["LIKE_MANGAL"] as! String
                            Language.SHARE_WITH_FRIENDS = responseData["SHARE_WITH_FRIENDS"] as! String
                            Language.INVITE_DESCRIPTION = responseData["INVITE_DESCRIPTION"] as! String
                            Language.SHARE_CODE = responseData["SHARE_CODE"] as! String
                            Language.FACEBOOK_INSTALL = responseData["FACEBOOK_INSTALL"] as! String
                            Language.INSTALL_INSTA_APP = responseData["INSTALL_INSTA_APP"] as! String
                            Language.DOB = responseData["DOB"] as! String
                            Language.GENDER = responseData["GENDER"] as! String
                            Language.MALE = responseData["MALE"] as! String
                            Language.FEMALE = responseData["FEMALE"] as! String
                            Language.UPDATE = responseData["UPDATE"] as! String
                            Language.COMPANY_NAME = responseData["COMPANY_NAME"] as! String
                            Language.VAT_ID = responseData["VAT_ID"] as! String
                            Language.LEGAL_EMAIL = responseData["LEGAL_EMAIL"] as! String
                            Language.UNIQUE_INVOICE_CODE = responseData["UNIQUE_INVOICE_CODE"] as! String
                            Language.DELIVERY = responseData["DELIVERY"] as! String
                            Language.TAKEAWAY_FROM_STORE = responseData["TAKEAWAY_FROM_STORE"] as! String
                            Language.WOOPS = responseData["WOOPS"] as! String
                            Language.SELECT_ANOTHER_ADDRESS = responseData["SELECT_ANOTHER_ADDRESS"] as! String
                            Language.ADDRESS = responseData["ADDRESS"] as! String
                            Language.ADDRESS_LINE_2 = responseData["ADDRESS_LINE_2"] as! String
                            Language.DELIVERY_ADDRESS = responseData["DELIVERY_ADDRESS"] as! String
                            Language.ADDRESS_ERROR = responseData["ADDRESS_ERROR"] as! String
                            Language.WORK = responseData["WORK"] as! String
                            Language.OTHER = responseData["OTHER"] as! String
                            Language.DOOR_NO = responseData["DOOR_NO"] as! String
                            Language.CITY = responseData["CITY"] as! String
                            Language.ZIPCODE = responseData["ZIPCODE"] as! String
                            Language.COUNTRY = responseData["COUNTRY"] as! String
                            Language.SEARCH_PRODUCT = responseData["SEARCH_PRODUCT"] as! String
                            Language.NO_ITEM_ERROR = responseData["NO_ITEM_ERROR"] as! String
                            Language.CUSTOMIZABLE = responseData["CUSTOMIZABLE"] as! String
                            Language.TOTAL = responseData["TOTAL"] as! String
                            Language.CATEGORY_NOT_FOUND = responseData["CATEGORY_NOT_FOUND"] as! String
                            Language.RES_CATEGORY_NOT_AVAILABLE = responseData["RES_CATEGORY_NOT_AVAILABLE"] as! String
                            Language.INGREDIENTS = responseData["INGREDIENTS"] as! String
                            Language.ALLERGENS = responseData["ALLERGENS"] as! String
                            Language.DESCRIPTION = responseData["DESCRIPTION"] as! String
                            Language.ITEM_CUSTOMIZATION = responseData["ITEM_CUSTOMIZATION"] as! String
                            Language.APPLY_CHANGES = responseData["APPLY_CHANGES"] as! String
                            Language.CHOOSE_TEST = responseData["CHOOSE_TEST"] as! String
                            Language.ADD_EXTRA = responseData["ADD_EXTRA"] as! String
                            Language.WANT_TO_REMOVE = responseData["WANT_TO_REMOVE"] as! String
                            Language.PAY_WITH_MANGAL = responseData["PAY_WITH_MANGAL"] as! String
                            Language.ITEM_TOTAL = responseData["ITEM_TOTAL"] as! String
                            Language.DELIVERY_CHARGE = responseData["DELIVERY_CHARGE"] as! String
                            Language.TOTAL_PAYABLE_AMT = responseData["TOTAL_PAYABLE_AMT"] as! String
                            Language.ORDER_TYPE = responseData["ORDER_TYPE"] as! String
                            Language.TAKEAWAY = responseData["TAKEAWAY"] as! String
                            Language.CHANGE_ADDRESS = responseData["CHANGE_ADDRESS"] as! String
                            Language.ADD_CUTLERY = responseData["ADD_CUTLERY"] as! String
                            Language.SPECIAL_REQUEST = responseData["SPECIAL_REQUEST"] as! String
                            Language.MINIMUM_ORDER_AMOUNT = responseData["MINIMUM_ORDER_AMOUNT"] as! String
                            Language.CHECKOUT = responseData["CHECKOUT"] as! String
                            Language.CART_EMPTY = responseData["CART_EMPTY"] as! String
                            Language.BACK_MAIN_MENU = responseData["BACK_MAIN_MENU"] as! String
                            Language.SELECT_ADDRESS = responseData["SELECT_ADDRESS"] as! String
                            Language.RES_NAME = responseData["RES_NAME"] as! String
                            Language.RES_NUMBER = responseData["RES_NUMBER"] as! String
                            Language.CHOOSE_DELIVERY_TIME = responseData["CHOOSE_DELIVERY_TIME"] as! String
                            Language.NOW = responseData["NOW"] as! String
                            Language.LATER = responseData["LATER"] as! String
                            Language.CREDIT_DEBIT_CARD = responseData["CREDIT_DEBIT_CARD"] as! String
                            Language.ADD_NEW_CARD = responseData["ADD_NEW_CARD"] as! String
                            Language.CASH = responseData["CASH"] as! String
                            Language.CASH_ON_DELIVERY = responseData["CASH_ON_DELIVERY"] as! String
                            Language.KEEP_CASH_ON_HAND = responseData["KEEP_CASH_ON_HAND"] as! String
                            Language.PAY_ON_DELIVERY = responseData["PAY_ON_DELIVERY"] as! String
                            Language.PAYPAL = responseData["PAYPAL"] as! String
                            Language.ADD_INVOICE = responseData["ADD_INVOICE"] as! String
                            Language.CHANGE = responseData["CHANGE"] as! String
                            Language.ORDER = responseData["ORDER"] as! String
                            Language.SELECT_TIME = responseData["SELECT_TIME"] as! String
                            Language.ENTER_COMPANY_INFO = responseData["ENTER_COMPANY_INFO"] as! String
                            Language.PROVIDE_PAYMENT_TYPE = responseData["PROVIDE_PAYMENT_TYPE"] as! String
                            Language.SELECT_TIME_ERROR = responseData["SELECT_TIME_ERROR"] as! String
                            Language.CARD_NUMBER = responseData["CARD_NUMBER"] as! String
                            Language.EXPIRY_DATE = responseData["EXPIRY_DATE"] as! String
                            Language.CVV_CODE = responseData["CVV_CODE"] as! String
                            Language.MONTH = responseData["MONTH"] as! String
                            Language.YEAR = responseData["YEAR"] as! String
                            Language.PROVIDE_CARD_NO = responseData["PROVIDE_CARD_NO"] as! String
                            Language.SELECT_EXP_MONTH = responseData["SELECT_EXP_MONTH"] as! String
                            Language.SELECT_EXP_YEAR = responseData["SELECT_EXP_YEAR"] as! String
                            Language.PROVIDE_CVV_CODE = responseData["PROVIDE_CVV_CODE"] as! String
                            Language.SELECT_MONTH = responseData["SELECT_MONTH"] as! String
                            Language.SELECT_YEAR = responseData["SELECT_YEAR"] as! String
                            Language.ORDER_SUCCESS = responseData["ORDER_SUCCESS"] as! String
                            Language.ORDER_SUCCESS_DESC = responseData["ORDER_SUCCESS_DESC"] as! String
                            Language.CONTINUE_SHOPPING = responseData["CONTINUE_SHOPPING"] as! String
                            Language.PENDING = responseData["PENDING"] as! String
                            Language.IN_PREPARE = responseData["IN_PREPARE"] as! String
                            Language.COMPLETED = responseData["COMPLETED"] as! String
                            Language.TOTAL_AMOUNT = responseData["TOTAL_AMOUNT"] as! String
                            Language.TRANSACTION_ID = responseData["TRANSACTION_ID"] as! String
                            Language.ORDER_DATE = responseData["ORDER_DATE"] as! String
                            Language.RATE_NOW = responseData["RATE_NOW"] as! String
                            Language.REPEAT_ORDER = responseData["REPEAT_ORDER"] as! String
                            Language.WANT_TO_REORDER1 = responseData["WANT_TO_REORDER1"] as! String
                            Language.WANT_TO_REORDER2 = responseData["WANT_TO_REORDER2"] as! String
                            Language.OLD_CART_FROM = responseData["OLD_CART_FROM"] as! String
                            Language.MOBILE_NO = responseData["MOBILE_NO"] as! String
                            Language.RES_ADDRESS = responseData["RES_ADDRESS"] as! String
                            Language.TYPE_OF_PAYMENT = responseData["TYPE_OF_PAYMENT"] as! String
                            Language.ADD_ON = responseData["ADD_ON"] as! String
                            Language.REMOVE = responseData["REMOVE"] as! String
                            Language.QTY = responseData["QTY"] as! String
                            Language.ENTER_COMMENT = responseData["ENTER_COMMENT"] as! String
                            Language.ENTER_COMMENT = responseData["ENTER_COMMENT"] as! String
                            Language.WARNING = responseData["WARNING"] as! String
                            Language.ERROR = responseData["ERROR"] as! String
                            Language.SUCCESS = responseData["SUCCESS"] as! String
                            Language.WENT_WRONG = responseData["WENT_WRONG"] as! String
                            Language.VAILD_EMAIL = responseData["VAILD_EMAIL"] as! String
                            Language.PROVIDE_PASS = responseData["PROVIDE_PASS"] as! String
                            Language.PROVIDE_EMAIL = responseData["PROVIDE_EMAIL"] as! String
                            Language.CHECK_INTERNET = responseData["CHECK_INTERNET"] as! String
                            Language.PASSWORD_LENGTH_ERROR = responseData["PASSWORD_LENGTH_ERROR"] as! String
                            Language.PROVIDE_FNAME = responseData["PROVIDE_FNAME"] as! String
                            Language.PROVIDE_LNAME = responseData["PROVIDE_LNAME"] as! String
                            Language.PROVIDE_PH_NO = responseData["PROVIDE_PH_NO"] as! String
                            Language.PROVIDE_CONFIRM_PASS = responseData["PROVIDE_CONFIRM_PASS"] as! String
                            Language.CONFIRM_PASS_NOT_MATCHED = responseData["CONFIRM_PASS_NOT_MATCHED"] as! String
                            Language.PROVIDE_NAME = responseData["PROVIDE_NAME"] as! String
                            Language.PROVIDE_MSG = responseData["PROVIDE_MSG"] as! String
                            Language.PROVIDE_BIRTHDATE = responseData["PROVIDE_BIRTHDATE"] as! String
                            Language.PROVIDE_DOOR_NO = responseData["PROVIDE_DOOR_NO"] as! String
                            Language.PROVIDE_ADDRESS = responseData["PROVIDE_ADDRESS"] as! String
                            Language.PROVIDE_CITY_NAME = responseData["PROVIDE_CITY_NAME"] as! String
                            Language.PROVIDE_ZIP_CODE = responseData["PROVIDE_ZIP_CODE"] as! String
                            Language.SELECT_COUNTRY_NAME = responseData["SELECT_COUNTRY_NAME"] as! String
                            Language.PROVIDE_PROPER_CITY = responseData["PROVIDE_PROPER_CITY"] as! String
                            Language.PROVIDE_PROPER_ZIP = responseData["PROVIDE_PROPER_ZIP"] as! String
                            Language.UNABLE_TO_FIND_ADD = responseData["UNABLE_TO_FIND_ADD"] as! String
                            Language.ADDRESS_NOT_FOUNDED = responseData["ADDRESS_NOT_FOUNDED"] as! String
                            Language.PROVIDE_COM_NAME = responseData["PROVIDE_COM_NAME"] as! String
                            Language.PROVIDE_VAT_ID = responseData["PROVIDE_VAT_ID"] as! String
                            Language.PROVIDE_INVOICE = responseData["PROVIDE_INVOICE"] as! String
                            Language.PROVIDE_OTP = responseData["PROVIDE_OTP"] as! String
                            Language.PROVIDE_TERMS_CONDITION = responseData["PROVIDE_TERMS_CONDITION"] as! String
                            Language.CANCELLED = responseData["CANCELLED"] as! String
                            Language.HOW_WOULD_LIKE = responseData["HOW_WOULD_LIKE"] as! String
                            Language.RECEIVE_ORDER = responseData["RECEIVE_ORDER"] as! String

                            Language.CATEGORY_ITEM_NOT_AVAILABLE = responseData["CATEGORY_ITEM_NOT_AVAILABLE"] as! String
                            Language.ITEM_NOT_AVAILABLE = responseData["ITEM_NOT_AVAILABLE"] as! String
                            Language.FAQ = responseData["FAQ"] as! String
                            Language.SEE_MORE = responseData["SEE_MORE"] as! String
                            
                            Language.TASTE = responseData["TASTE"] as! String
                            Language.COOKING_LEVEL = responseData["COOKING_LEVEL"] as! String
                            
                            Language.UPGRADE_APP = responseData["UPGRADE_APP"] as! String
                            Language.UPGRADE_MESSAGE = responseData["UPGRADE_MESSAGE"] as! String
                            Language.GUEST_ERROR = responseData["GUEST_ERROR"] as! String
                            Language.DELIVERY_TIME = responseData["DELIVERY_TIME"] as! String
                            
                            Language.NOTIFICATION = responseData["NOTIFICATION"] as! String
                            Language.NOTIFICATION_DETAIL = responseData["NOTIFICATION_DETAIL"] as! String
                            
                            Language.MONDAY = responseData["MONDAY"] as! String
                            Language.SUNDAY = responseData["SUNDAY"] as! String
                            Language.COLLECT_HERE = responseData["COLLECT_HERE"] as! String
                            
                            
                            Language.BOOK_A_TABLE = responseData["BOOK_A_TABLE"] as! String
                            Language.ADD_A_NEW_RESERVATION = responseData["ADD_A_NEW_RESERVATION"] as! String
                            Language.APPROVED = responseData["APPROVED"] as! String
                            Language.REJECT = responseData["REJECT"] as! String
                            Language.CANCEL_BOOKING = responseData["CANCEL_BOOKING"] as! String
                            Language.SEARCH = responseData["SEARCH"] as! String
                            Language.ABOUT = responseData["ABOUT"] as! String
                            Language.CHOOSE_YOUR_TIME = responseData["CHOOSE_YOUR_TIME"] as! String
                            Language.NUMBER_OF_GUEST = responseData["NUMBER_OF_GUEST"] as! String
                            Language.BOOK_TABLE = responseData["BOOK_TABLE"] as! String
                            Language.TABLE_BOOKING = responseData["TABLE_BOOKING"] as! String
                            Language.SPACE_AVAILABLE = responseData["SPACE_AVAILABLE"] as! String
                            Language.REJECT_TABLE_RESERVATION = responseData["REJECT_TABLE_RESERVATION"] as! String
                            Language.PLEASE_WRITE_REJECTION_MESSAGE = responseData["PLEASE_WRITE_REJECTION_MESSAGE"] as! String
                            Language.WRITE_YOUR_QUERY_HERE = responseData["WRITE_YOUR_QUERY_HERE"] as! String
                            Language.SET_BOOKING = responseData["SET_BOOKING"] as! String
                            
                            Language.DINNER = responseData["DINNER"] as! String
                            Language.LUNCH = responseData["LUNCH"] as! String
                            Language.SPECIAL_REQ = responseData["SPECIAL_REQ"] as! String
                            Language.WRITE_SPECIAL_REQ = responseData["WRITE_SPECIAL_REQ"] as! String
                            Language.SEATS_LEFT = responseData["SEATS_LEFT"] as! String
                            Language.BOOKINGS_NOT_FOUND = responseData["BOOKINGS_NOT_FOUND"] as! String
                            Language.REPLY = responseData["REPLY"] as! String
                            
                            
                            NotificationCenter.default.post(name: Notification.Name("Language_Localization"), object: nil)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

    func call_CheckAppVersion(){
        
        let url = "http://itunes.apple.com/lookup?id=\(Constant.APP_ID)"
        var appLiveVersion = ""
        APIManager.shared.requestGETURLNoLoader(url, success: { (response) in
            print(response)
            
            if let jsonObject = response.result.value as? [String:AnyObject] {
                let configData = jsonObject["results"] as? [AnyHashable]

                for config in configData ?? [] {
                    appLiveVersion = (config as NSObject).value(forKey: "version") as? String ?? ""
                    break
                }

                UserModel.sharedInstance().app_version = appLiveVersion
                UserModel.sharedInstance().synchroniseData()
            }
            
            
        }) { (error) in
        }
    }
}

