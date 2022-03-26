//
//  OTPVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class OTPVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var vwOTP: CustomUIView!
    @IBOutlet weak var tfOTP: UITextField!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnNext: CustomButton!
    
    //MARK:- Global Variables
    var otp = ""
    var email = ""
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        
        lblTitle.text = Language.SECURITY_CODE
        tfOTP.text = Language.SECURITY_CODE
        lblDescription.text = Language.SECURITY_CODE_MSG
        btnNext.setTitle(Language.NEXT, for: .normal)
        
        self.lblEmail.text = email
    }
    
    //MARK:- Other Methods
    func checkValidation() -> Bool{
        if tfOTP.text!.isEmpty {
            tfOTP.becomeFirstResponder()
            self.showError(Language.PROVIDE_OTP)
            return false
        }else{
            return true
        }
    }

    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNext_Action(_ sender: Any) {
        if checkValidation() {
            callVerifyOTPAPI()
        }
    }
    
    //MARK:- Webservice Calling
    func callVerifyOTPAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.VERIFY_OTP
        let params = "?email=\(email)&otp=\(tfOTP.text!)"
        
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
                        self.performSegue(withIdentifier: "toPassword", sender: nil)
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPassword" {
            let destVC = segue.destination as! SetPasswordVC
            destVC.email = self.email
        }
    }
}
