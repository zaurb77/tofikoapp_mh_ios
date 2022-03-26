//
//  LoginVC.swift
//  Mangal house
//
//  Created by Mahajan on 19/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class LoginVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var btnLogin: CustomButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnRegister: CustomButton!
    @IBOutlet weak var btnSkip: CustomButton!
    
    @IBOutlet weak var btnForget: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnPrivacy: UIButton!
    @IBOutlet weak var lblAnd: UILabel!
    @IBOutlet weak var btnTerms: UIButton!
    
    @IBOutlet weak var vwEmail: CustomUIView!
    @IBOutlet weak var vwPassword: CustomUIView!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting previoud email and password of last login.
        if UserModel.sharedInstance().email != nil {
            tfEmail.text = UserModel.sharedInstance().email!
        }
        
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        tfPassword.placeholder = Language.PASSWORD
        btnForget.setTitle(Language.FORGOT_PASS, for: .normal)
        btnLogin.setTitle(Language.LOGIN, for: .normal)
        lblOr.text = Language.OR
        btnRegister.setTitle(Language.REGISTER, for: .normal)
        btnSkip.setTitle(Language.WITHOUT_LOGIN, for: .normal)
        lblMessage.text = Language.SIGN_AGREEMENT
        btnTerms.setTitle(Language.TERMS_AND_CONDITIONS, for: .normal)
        lblAnd.text = Language.AND
        btnPrivacy.setTitle(Language.PRIVACY_POLICY, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserModel.sharedInstance().app_version != nil && UserModel.sharedInstance().app_version != "" {
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            if Double(UserModel.sharedInstance().app_version!)! > Double(appVersion)!{
                launchAppUpdatePopup()
            }
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnForgotPassword_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toForgot", sender: nil)
    }
    
    @IBAction func btnLogin_Action(_ sender: Any) {
        if checkValidation() {
            callLoginAPI()
        }
    }
    
    @IBAction func btnRegister_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    @IBAction func btnContinueWithoutLogging_Action(_ sender: Any) {
        UserModel.sharedInstance().isGuestLogin = "1"
        UserModel.sharedInstance().synchroniseData()
        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
    }
    
    @IBAction func btnTerms_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "segueStatic", sender: "terms")
    }
    
    @IBAction func btnPrivacy_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "segueStatic", sender: "policy")
    }
    
    //MARK:- Other Functions
    //Checking validation for login screen.
    func checkValidation()->Bool {
        if tfEmail.text == ""{
            tfEmail.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else if tfPassword.text == ""{
            tfPassword.becomeFirstResponder()
            self.showError(Language.PROVIDE_PASS)
            return false
        }else if !(tfEmail.text?.isEmail)! {
            tfEmail.becomeFirstResponder()
            self.showError(Language.VAILD_EMAIL)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Web Service Calling
    func callLoginAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.LOGIN
        let params = "?email=\(tfEmail.text!)&password=\(tfPassword.text!)&device_token=\(UserModel.sharedInstance().deviceToken!)&lang_id=\(UserModel.sharedInstance().app_language!)&company_id=\(company_id)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            UserModel.sharedInstance().user_id = responseData["user_id"] as? String
                            UserModel.sharedInstance().authToken = responseData["token"] as? String
                            
                            UserModel.sharedInstance().firstname = responseData["fname"] as? String
                            UserModel.sharedInstance().lastname = responseData["lname"] as? String
                            UserModel.sharedInstance().birthdate = responseData["dob"] as? String
                            UserModel.sharedInstance().country_code = responseData["country_code"] as? String
                            UserModel.sharedInstance().mobileNo = responseData["mobile_no"] as? String
                            UserModel.sharedInstance().email = responseData["email"] as? String
                            UserModel.sharedInstance().password = responseData["password"] as? String
                            UserModel.sharedInstance().gender = responseData["gender"] as? String
                            UserModel.sharedInstance().profile_image = responseData["image"] as? String
                                                        
                            self.settingModel.cart_id = responseData["cart_id"] as? String
                            
                            UserModel.sharedInstance().stripeCustId = responseData["cust_id"] as? String
                            UserModel.sharedInstance().refer_Code = responseData["referral_code"] as? String
                            UserModel.sharedInstance().app_language = responseData["app_language"] as? String
                            
                            if responseData["type"] as! String == "0" {
                                UserModel.sharedInstance().isCompany = 1
                            }else {
                                UserModel.sharedInstance().isCompany = 0
                            }
                            UserModel.sharedInstance().companyId = responseData["company_id"] as? String
                            UserModel.sharedInstance().companyName = responseData["company_name"] as? String
                            UserModel.sharedInstance().companyLegalEmail = responseData["company_legal_email"] as? String
                            UserModel.sharedInstance().uniqueInvoiceCode = responseData["unique_invoicing_code"] as? String
                            UserModel.sharedInstance().vatId = responseData["vat_id"] as? String
                            
                            UserModel.sharedInstance().newsEmailNotification = Int(responseData["news_email_notification"] as! String)!
                            UserModel.sharedInstance().newsPushNotification = Int(responseData["news_push_notification"] as! String)!
                            UserModel.sharedInstance().orderEmailNotification = Int(responseData["order_email_notification"] as! String)!
                            UserModel.sharedInstance().orderPushNotification = Int(responseData["order_push_notification"] as! String)!
                            
                            UserModel.sharedInstance().isGuestLogin = "0"
                            
                            UserModel.sharedInstance().synchroniseData()
                            
                            self.showSuccess(jsonObject["message"] as! String)
                            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
                            
                        } else {
                            self.showWarning("Someting went wrong")
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueStatic" {
            let destVC = segue.destination as! StaticPageLandingVC
            destVC.staticType = sender as! String
        }
    }

}

extension LoginVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 2
            self.vwEmail.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfPassword{
            self.vwPassword.layer.borderWidth = 2
            self.vwPassword.layer.borderColor = AppColors.yellow.cgColor
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 1
            self.vwEmail.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfPassword{
            self.vwPassword.layer.borderWidth = 1
            self.vwPassword.layer.borderColor = AppColors.golden.cgColor
        }
    }
}
