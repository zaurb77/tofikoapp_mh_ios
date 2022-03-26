//
//  ForgotPasswordVC.swift
//  Mangal house
//
//  Created by Mahajan on 19/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class ForgotPasswordVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var vwEmail: CustomUIView!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    //MARK:- Global Variables
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfEmail.placeholder = Language.EMAIL_ADDRESS
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
    }
    
    //MARK:- Button Actions
    @IBAction func btnSubmit_Action(_ sender: Any) {
        if checkValidation() {
            callForgotPasswordAPI()
        }
    }
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    //MARK:- Other Functions
    //Checking validation for login screen.
    func checkValidation()->Bool {
        if tfEmail.text == ""{
            tfEmail.becomeFirstResponder()
            self.showError(Language.PROVIDE_EMAIL)
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
    func callForgotPasswordAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.FORGOT_PASSWORD
        let params = "?email=\(tfEmail.text!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
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
                            
                            if let otp = responseData["otp"] as? String {
                                self.performSegue(withIdentifier: "toOTP", sender: otp)
                            }
                            
                        } else {
                            self.showWarning(Language.WENT_WRONG)
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
        if segue.identifier == "toOTP" {
            let destVC = segue.destination as! OTPVC
            destVC.otp = sender as! String
            destVC.email = self.tfEmail.text!
        }
    }
}

extension ForgotPasswordVC {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 2
            self.vwEmail.layer.borderColor = AppColors.yellow.cgColor
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == tfEmail{
            self.vwEmail.layer.borderWidth = 1
            self.vwEmail.layer.borderColor = AppColors.golden.cgColor
        }
    }
}
