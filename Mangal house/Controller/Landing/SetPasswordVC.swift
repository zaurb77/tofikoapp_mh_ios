//
//  SetPasswordVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class SetPasswordVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfNewPassword: UITextField!
    @IBOutlet weak var tfConfirmPassword: UITextField!
    
    @IBOutlet weak var vwNewPassword: CustomUIView!
    @IBOutlet weak var vwConfirmPassword: CustomUIView!
    
    @IBOutlet weak var btnSave: CustomButton!
    
    //MARK:- Global Variables
    var email = ""
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = Language.SET_PASSWORD
        tfNewPassword.text = Language.NEW_PASS
        tfConfirmPassword.text = Language.CONFIRM_PASS
        btnSave.setTitle(Language.NEXT, for: .normal)
    }
    
    //MARK:- Other Functions
    func checkValidation() -> Bool{
        if tfNewPassword.text!.isEmpty{
            tfNewPassword.becomeFirstResponder()
            self.showError(Language.PROVIDE_PASS)
            return false
        }else if tfConfirmPassword.text!.isEmpty{
            tfConfirmPassword.becomeFirstResponder()
            self.showError(Language.PROVIDE_CONFIRM_PASS)
            return false
        }else if tfNewPassword.text != tfConfirmPassword.text{
            tfConfirmPassword.becomeFirstResponder()
            self.showError(Language.CONFIRM_PASS_NOT_MATCHED)
            return false
        }else if tfNewPassword.text!.count < 6{
            self.showError(Language.PASSWORD_LENGTH_ERROR)
            return false
        }else if tfConfirmPassword.text!.count < 6{
            self.showError(Language.PASSWORD_LENGTH_ERROR)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSave_Action(_ sender: Any) {
        if checkValidation(){
            callSetPassAPI()
        }
    }
    
    //MARK:- Webservice Calling
    func callSetPassAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESET_PASSWORD
        let params = "?email=\(email)&password=\(tfNewPassword.text!)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Login()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}
