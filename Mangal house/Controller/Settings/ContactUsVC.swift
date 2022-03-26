//
//  ContactUsVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class ContactUsVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tvMessage: KMPlaceholderTextView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhno: UITextField!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tfName.placeholder = Language.NAME
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        tfPhno.placeholder = Language.MOBILE_NUMBER
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
        
        tvMessage.placeholder = Language.MESSAGE
        tvMessage.layer.borderWidth = 1.5
        tvMessage.layer.borderColor = UIColor(named: "golden")?.cgColor
        
        tvMessage.layer.cornerRadius = 10.0
        tvMessage.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        if UserModel.sharedInstance().firstname != nil && UserModel.sharedInstance().firstname != "" && UserModel.sharedInstance().lastname != nil && UserModel.sharedInstance().lastname != "" {
            tfName.text = "\(UserModel.sharedInstance().firstname!) \(UserModel.sharedInstance().lastname!)"
        }
        
        if UserModel.sharedInstance().email != nil && UserModel.sharedInstance().email != "" {
            tfEmail.text = UserModel.sharedInstance().email!
        }
        
        if UserModel.sharedInstance().mobileNo != nil && UserModel.sharedInstance().mobileNo != "" {
            tfPhno.text = UserModel.sharedInstance().mobileNo!
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSubmit_Action(_ sender: Any) {
        if checkValidation(){
            self.callContactUs()
        }
    }
    
    
    //MARK:- Other Methods
    //Validation checker method - Use to check the validation of controls.
    func checkValidation()->Bool{
        if tfName.text == "" {
            tfName.becomeFirstResponder()
            self.showError(Language.PROVIDE_NAME)
            return false
        }else if tfEmail.text == "" {
            tfEmail.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
            return false
        }else if !tfEmail.text!.isEmail {
            tfEmail.becomeFirstResponder()
            self.showError(Language.VAILD_EMAIL)
            return false
        }else if tfPhno.text == "" {
            tfPhno.becomeFirstResponder()
            self.showError(Language.PHONE_NUMBER)
            return false
        }else if tvMessage.text == "" {
            tvMessage.becomeFirstResponder()
            self.showError(Language.PROVIDE_MSG)
            return false
        }else {
            return true
        }
    }
    
    //MARK:- Webservices
    func callContactUs() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CONTACT_US
        let params = "?&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&message=\(tvMessage.text!)&name=\(tfName.text!)&email=\(tfEmail.text!)&phone_no=\(tfPhno.text!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                    }else{
                        self.showSuccess(jsonObject["message"] as! String)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }

}
