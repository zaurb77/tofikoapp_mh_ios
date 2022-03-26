//
//  EditProfileVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import ADCountryPicker
class SettingCell : UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
}


class EditProfileVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var ivProfile: CustomImageView!
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfConfPassword: UITextField!
    @IBOutlet weak var tfReferralCode: UITextField!
    @IBOutlet weak var tfDOB: UITextField!
    
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
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
    @IBOutlet weak var btnUpdate: CustomButton!
    
    //MARK:- Global Variables
    var imagePicker = UIImagePickerController()
    var countryCode = "+91"
    let picker = ADCountryPicker()
    var isMale = true
    var isSelected = false
    
    fileprivate lazy var CallingCodes = { () -> [[String: String]] in
        let resourceBundle = Bundle(for: ADCountryPicker.classForCoder())
        guard let path = resourceBundle.path(forResource: "CallingCodes", ofType: "plist") else { return [] }
        return NSArray(contentsOfFile: path) as! [[String: String]]
    }()
        
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.ivCountryCode.image =  self.picker.getFlag(countryCode: "IN")
        
        tfFirstName.placeholder = Language.FNAME
        tfLastName.placeholder = Language.LNAME
        tfDOB.placeholder = Language.DOB
        tfMobile.placeholder = Language.PHONE_NUMBER
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        lblGender.text = Language.GENDER
        btnMale.setTitle(Language.MALE, for: .normal)
        btnFemale.setTitle(Language.FEMALE, for: .normal)
        tfPassword.placeholder = Language.PASSWORD
        tfConfPassword.placeholder = Language.CONFIRM_PASS
        btnUpdate.setTitle(Language.UPDATE, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handle_ImageUpload(_:)))
        self.ivProfile.addGestureRecognizer(tap)
        
        //Registering datepickerview on date textfield.
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date()
        tfDOB.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        //Setting first name in the first name field
        if UserModel.sharedInstance().firstname != nil && UserModel.sharedInstance().firstname! != "" {
            tfFirstName.text = UserModel.sharedInstance().firstname!
        }
        
        //Setting last name in the last name field
        if UserModel.sharedInstance().lastname != nil && UserModel.sharedInstance().lastname! != "" {
            tfLastName.text = UserModel.sharedInstance().lastname!
        }
        
        //Setting gender according to the its value
        if UserModel.sharedInstance().gender != nil && UserModel.sharedInstance().gender! != "" {
            if UserModel.sharedInstance().gender! == "1" {
                self.btnMale.setImage(UIImage(named:"radioOn"), for: .normal)
                self.btnFemale.setImage(UIImage(named:"radioOff"), for: .normal)
            }else {
                self.btnMale.setImage(UIImage(named:"radioOff"), for: .normal)
                self.btnFemale.setImage(UIImage(named:"radioOn"), for: .normal)
            }
        }
        
        //Setting profile image that have been set by user.
        if UserModel.sharedInstance().profile_image != nil && UserModel.sharedInstance().profile_image! != "" {
            isSelected = true
            ivProfile.kf.setImage(with: URL(string: (UserModel.sharedInstance().profile_image!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!)!)
        }
        
        //Setting birthdate in birthdate text field
        if UserModel.sharedInstance().birthdate != nil && UserModel.sharedInstance().birthdate! != "" {
            let strDate = UserModel.sharedInstance().birthdate!
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            if let date = df.date(from: strDate) {
                df.dateFormat = "dd-MM-yyyy"
                let strDOB = df.string(from: date)
                tfDOB.text = strDOB
            }else {
                tfDOB.text = strDate
            }
        }
        
        //Setting country code and its flag.
        if UserModel.sharedInstance().country_code != nil && UserModel.sharedInstance().country_code! != "" {
            //            txtCountryCode.text = UserModel.sharedInstance().country_code!
            countryCode = "+\(UserModel.sharedInstance().country_code!)"
           
            let arrCodes = CallingCodes.filter{$0["dial_code"] == countryCode}
            if arrCodes.count > 0 {
                let codeData = arrCodes[0]
                self.ivCountryCode.image =  self.picker.getFlag(countryCode: codeData["code"]!)
            }
            self.lblCountryCode.text = countryCode
            
        }
        
        //Setting email into the email field.
        if UserModel.sharedInstance().email != nil && UserModel.sharedInstance().email! != "" {
            tfEmail.text = UserModel.sharedInstance().email!
        }
        
        //Setting password into the password field.
        if UserModel.sharedInstance().password != nil && UserModel.sharedInstance().password! != "" {
            tfPassword.text = UserModel.sharedInstance().password!
            tfConfPassword.text = UserModel.sharedInstance().password!
        }
        
        //Setting mobile number into the mobile number field.
        if UserModel.sharedInstance().mobileNo != nil && UserModel.sharedInstance().mobileNo! != "" {
            tfMobile.text = UserModel.sharedInstance().mobileNo!
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCountryCode_Action(_ sender: Any) {
        
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        picker.showCallingCodes = true
        picker.showFlags = true
        picker.pickerTitle = Language.SELECT_COUNTRY
        picker.defaultCountryCode = "US"
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
    
    @IBAction func btnMale_Action(_ sender: UIButton) {
        //Setting isMale flag to true.
        self.isMale = true
        
        //Changing button images as per selection.
        self.btnMale.setImage(UIImage(named:"radioOn"), for: .normal)
        self.btnFemale.setImage(UIImage(named:"radioOff"), for: .normal)
        
        //Changing picture as per user selected gender. Only if user not selected any image from camera roll or gallery.
        if !isSelected {
            self.ivProfile.image = UIImage(named: "boy")
        }
    }
    
    @IBAction func btnFemale_Action(_ sender: UIButton) {
        //Setting isMale flag to false.
        self.isMale = false
        
        //Changing button images as per selection.
        self.btnMale.setImage(UIImage(named:"radioOff"), for: .normal)
        self.btnFemale.setImage(UIImage(named:"radioOn"), for: .normal)
        
        //Changing picture as per user selected gender. Only if user not selected any image from camera roll or gallery.
        if !isSelected {
            self.ivProfile.image = UIImage(named: "girl")
        }
    }
    
    @IBAction func btnNext_Action(_ sender: Any) {
        self.view.endEditing(true)
        
        if checkValidation() {
            callEditprofileService()
        }
    }

    @IBAction func btnChangeCompanyInfo_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toCompany", sender: nil)
    }
    
    
    //MARK:- Selector Methods
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        tfDOB.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func handle_ImageUpload(_ recognizer: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
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
            self.showError(Language.PROVIDE_LNAME)
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
            
        }else if tfDOB.text == ""{
            self.showError(Language.PROVIDE_BIRTHDATE)
            tfDOB.becomeFirstResponder()
            return false
            
        }else if tfEmail.text == ""{
            self.showError(Language.EMAIL_ADDRESS)
            tfEmail.becomeFirstResponder()
            return false
            
        }else if tfPassword.text == ""{
            self.showError(Language.PASSWORD)
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
            
        }else {
            return true
        }
    }
    
    //MARK:- Webservices
    func callEditprofileService() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var gender = "0"
        if isMale {
            gender = "1"
        }else {
            gender = "0"
        }
        
        self.countryCode.removeFirst()
        
        let imageData = ivProfile.image!.jpegData(compressionQuality: 1.0)
        let image = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_PROFILE
        let parameters = ["user_id": UserModel.sharedInstance().user_id!,
                          "auth_token": UserModel.sharedInstance().authToken!,
                          "fname": tfFirstName.text!,
                          "lname": tfLastName.text!,
                          "dob": tfDOB.text!,
                          "country_code": self.countryCode,
                          "mobile_no": tfMobile.text!,
                          "email": tfEmail.text!,
                          "password": tfPassword.text!,
                          "gender": gender,
                          "image": image]
        
        //Starting process to fetch the data and store data.
        APIManager.shared.requestPostURL(serviceURL, param: parameters, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let strStatus = jsonObject["status"] as? String {
                    if strStatus == "1" {
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            print(responseData)
                            UserModel.sharedInstance().user_id = responseData["user_id"] as? String
                            UserModel.sharedInstance().firstname = responseData["fname"] as? String
                            UserModel.sharedInstance().lastname = responseData["lname"] as? String
                            UserModel.sharedInstance().email = responseData["email"] as? String
                            UserModel.sharedInstance().password = responseData["password"] as? String
                            UserModel.sharedInstance().profile_image = responseData["image"] as? String
                            UserModel.sharedInstance().birthdate = responseData["dob"] as? String
                            UserModel.sharedInstance().gender = responseData["gender"] as? String
                            UserModel.sharedInstance().mobileNo = responseData["mobile_no"] as? String
                            UserModel.sharedInstance().country_code = responseData["country_code"] as? String
                            
                            UserModel.sharedInstance().synchroniseData()
                            
                            //Redirecting to back screen where user came in this screen.
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else {
                        self.showWarning(jsonObject["message"] as! String)
                    }
                }else {
                    self.showWarning(Language.WENT_WRONG)
                }
            }else {
                self.showWarning(Language.WENT_WRONG)
            }
        }) { (error) in
            print(error)
        }
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
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
