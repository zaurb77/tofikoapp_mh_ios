//
//  RegisterVC.swift
//  Mangal house
//
//  Created by Mahajan on 19/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import ADCountryPicker

class RegisterVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var ivProfile: CustomImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfPassword: UITextField!
    @IBOutlet weak var tfReferralCode: UITextField!
    
    @IBOutlet weak var ivCountryCode: UIImageView!
    @IBOutlet weak var lblCountryCode: UILabel!
    
    @IBOutlet weak var vwFirstName: CustomUIView!
    @IBOutlet weak var vwLastName: CustomUIView!
    @IBOutlet weak var vwMobile: CustomUIView!
    @IBOutlet weak var vwEmail: CustomUIView!
    @IBOutlet weak var vwPassword: CustomUIView!
    @IBOutlet weak var vwConfPassword: CustomUIView!
    @IBOutlet weak var vwReferralCode: CustomUIView!
    @IBOutlet weak var vwCountryCode: CustomUIView!
    
    @IBOutlet weak var btnNext: CustomButton!
    @IBOutlet weak var btnAlreadyAcc: CustomButton!
    
    @IBOutlet weak var btnAcceptTerms: CustomButton!
    @IBOutlet weak var lblTermsCondition: UILabel!
    
    //MARK:- Global Variables
    var imagePicker = UIImagePickerController()
    var countryCode = "+91"
    var code = "IN"
    let picker = ADCountryPicker()
    var isChecked = false
        
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tfFirstName.placeholder = Language.FNAME
        tfLastName.placeholder = Language.LNAME
        tfMobile.placeholder = Language.PHONE_NUMBER
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        tfPassword.placeholder = Language.PASSWORD
        tfConfPassword.placeholder = Language.CONFIRM_PASS
        tfReferralCode.placeholder = Language.REFERRAL_CODE
        lblTermsCondition.text = Language.I_AGREE
        
        btnNext.setTitle(Language.NEXT, for: .normal)
        btnAlreadyAcc.setTitle(Language.ALREADY_LOGIN, for: .normal)
        
        code = Locale.current.regionCode!
        let bundle = "assets.bundle/"
        self.ivCountryCode.image = UIImage(named: bundle + "\(code).png",
                       in: Bundle(for: ADCountryPicker.self), compatibleWith: nil)

        let resourceBundle = Bundle(for: ADCountryPicker.classForCoder())
        let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist")
        let arrCodes = NSArray(contentsOfFile: path!) as! [[String: String]]
        self.countryCode = (arrCodes.filter{$0["code"] == code}[0]["dial_code"])!
        self.lblCountryCode.text = self.countryCode
                
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handle_ImageUpload(_:)))
        self.ivProfile.addGestureRecognizer(tap)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.handle_StaticText(_:)))
        self.lblTermsCondition.addGestureRecognizer(tap1)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCountryCode_Action(_ sender: Any) {
        self.vwCountryCode.layer.borderWidth = 2
        self.vwCountryCode.layer.borderColor = AppColors.yellow.cgColor
        
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        picker.showCallingCodes = true
        picker.showFlags = true
        picker.pickerTitle = Language.SELECT_COUNTRY
        picker.defaultCountryCode = code
        picker.forceDefaultCountryCode = false
        picker.alphabetScrollBarTintColor = UIColor.black
        picker.alphabetScrollBarBackgroundColor = UIColor.clear
        picker.closeButtonTintColor = UIColor.black
        picker.font = UIFont(name: "Raleway-Regular", size: 15)
        picker.flagHeight = 40
        picker.hidesNavigationBarWhenPresentingSearch = true
        picker.searchBarBackgroundColor = UIColor.white
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            self.countryCode = dialCode
            self.lblCountryCode.text = dialCode
            self.ivCountryCode.image =  self.picker.getFlag(countryCode: code)
            self.picker.dismiss(animated: true, completion: nil)
        }
        self.present(pickerNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func btnNext_Action(_ sender: Any) {
        self.view.endEditing(true)
        if checkValidation() {
            callUserExistsService()
        }
    }
    
    @IBAction func btnLogin_Action(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAcceptTerms_Action(_ sender: Any) {
        isChecked = !isChecked
        if isChecked {
            btnAcceptTerms.setImage(UIImage(named:"checkboxFill"), for: .normal)
        }else {
            btnAcceptTerms.setImage(UIImage(named:"checkboxEmpty"), for: .normal)
        }
    }
    
    //MARK:- Selector Methods
    @objc func handle_ImageUpload(_ recognizer: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        let action1 = UIAlertAction(title: Language.GALLERY, style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action2 = UIAlertAction(title: Language.CAMERA, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
            } else {
                imagePicker.sourceType = .photoLibrary
            }
            self.present(imagePicker, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(title: Language.CANCEL, style: .cancel, handler: nil)
        actionSheet.addAction(action1)
        actionSheet.addAction(action2)
        actionSheet.addAction(action3)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func handle_StaticText(_ recognizer: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageLandingVC") as! StaticPageLandingVC
        vc.staticType = "terms"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Other Methods
    func checkValidation()->Bool{
        if ivProfile.image == nil{
            self.showError(Language.PROVIDE_PROFILE_IMG)
            return false
            
        }else if tfFirstName.text == ""{
            self.showError(Language.PROVIDE_FNAME)
            tfFirstName.becomeFirstResponder()
            return false
            
        }else if tfLastName.text == ""{
            self.showError(Language.LNAME)
            tfLastName.becomeFirstResponder()
            return false
            
        }else if tfMobile.text == ""{
            self.showError(Language.PROVIDE_PH_NO)
            tfMobile.becomeFirstResponder()
            return false
            
        }else if tfMobile.text?.count != 10{
            self.showError(Language.PROVIDE_PH_NO)
            tfMobile.becomeFirstResponder()
            return false
            
        }else if tfEmail.text == ""{
            self.showError(Language.PROVIDE_EMAIL)
            tfEmail.becomeFirstResponder()
            return false
            
        }else if tfPassword.text == ""{
            self.showError(Language.PROVIDE_PASS)
            tfPassword.becomeFirstResponder()
            return false
            
        }else if tfConfPassword.text == ""{
            self.showError(Language.CONFIRM_PASS)
            tfConfPassword.becomeFirstResponder()
            return false
            
        }else if tfPassword.text! != tfConfPassword.text!{
            self.showError(Language.CONFIRM_PASS_NOT_MATCHED)
            tfConfPassword.becomeFirstResponder()
            return false
            
        }else if !isChecked {
            self.showWarning(Language.PROVIDE_TERMS_CONDITION)
            return false
            
        }else {
            return true
        }
    }
    
    //MARK:- Webservices
    func callUserExistsService() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHECK_USER_EXISTS
        let parameters = ["mobile_no": self.tfMobile.text!,
                          "email": self.tfEmail.text!,
                          "referral_code": self.tfReferralCode.text!,
                          "lang_id": UserModel.sharedInstance().app_language!,
                          "company_id": "\(company_id)"
                         ]
        
        APIManager.shared.requestPostURL(serviceURL, param: parameters, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let strStatus = jsonObject["status"] as? String {
                    if strStatus == "1" {
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        self.countryCode.removeFirst()
                        self.callSignUpService()
                        
                    }else {
                        self.showError(jsonObject["message"] as! String)
                    }
                }else {
                    self.showError(Language.WENT_WRONG)
                }
            }else {
                self.showError(Language.WENT_WRONG)
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callSignUpService() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let imageData = self.ivProfile.image!.jpegData(compressionQuality: 1.0)
        let image = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        var referralCode = ""
        if self.tfReferralCode.text != ""{
            referralCode = self.tfReferralCode.text!
        }else{
            referralCode = ""
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.REGISTER
        let parameters = ["fname": self.tfFirstName.text!,
                          "lname": self.tfLastName.text!,
                          "country_code": self.countryCode,
                          "mobile_no": self.tfMobile.text!,
                          "email": self.tfEmail.text!,
                          "password": self.tfPassword.text!,
                          "accept_terms": "1",
                          "referral_code": referralCode,
                          "device_token": UserModel.sharedInstance().deviceToken!,
                          "image": image,
                          "lang_id": UserModel.sharedInstance().app_language!,
                          "company_id": "\(company_id)"
        ]
        
        APIManager.shared.requestPostURL(serviceURL, param: parameters, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let strStatus = jsonObject["status"] as? String {
                    if strStatus == "1" {
                        
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
                            
                            if let id = responseData["cust_id"] as? String{
                                UserModel.sharedInstance().stripeCustId = id
                            }
                            
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
                        }
                    }else {
                        self.showError(jsonObject["message"] as! String)
                    }
                }else {
                    self.showError(Language.WENT_WRONG)
                }
            }else {
                self.showError(Language.WENT_WRONG)
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension RegisterVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 2
            self.vwEmail.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfFirstName{
            self.vwFirstName.layer.borderWidth = 2
            self.vwFirstName.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfLastName{
            self.vwLastName.layer.borderWidth = 2
            self.vwLastName.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfConfPassword{
            self.vwConfPassword.layer.borderWidth = 2
            self.vwConfPassword.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfPassword{
            self.vwPassword.layer.borderWidth = 2
            self.vwPassword.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfMobile{
            self.vwMobile.layer.borderWidth = 2
            self.vwMobile.layer.borderColor = AppColors.yellow.cgColor
        }else if textField == tfReferralCode{
            self.vwReferralCode.layer.borderWidth = 2
            self.vwReferralCode.layer.borderColor = AppColors.yellow.cgColor
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 1
            self.vwEmail.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfFirstName{
            self.vwFirstName.layer.borderWidth = 1
            self.vwFirstName.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfLastName{
            self.vwLastName.layer.borderWidth = 1
            self.vwLastName.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfConfPassword{
            self.vwConfPassword.layer.borderWidth = 1
            self.vwConfPassword.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfPassword{
            self.vwPassword.layer.borderWidth = 1
            self.vwPassword.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfMobile{
            self.vwMobile.layer.borderWidth = 1
            self.vwMobile.layer.borderColor = AppColors.golden.cgColor
        }else if textField == tfReferralCode{
            self.vwReferralCode.layer.borderWidth = 1
            self.vwReferralCode.layer.borderColor = AppColors.golden.cgColor
        }
    }
}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            self.ivProfile.image = selectedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
