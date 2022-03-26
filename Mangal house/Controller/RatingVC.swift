 //
//  RatingVC.swift
//  Mangal house
//
//  Created by Kinjal on 30/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import HCSStarRatingView
import KMPlaceholderTextView

class RatingVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var vwRate: HCSStarRatingView!
    @IBOutlet weak var tvMessage: KMPlaceholderTextView!
    @IBOutlet weak var btnSubmit: CustomButton!
    
    //MARK:- Global Variables
    var orderID = ""
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tvMessage.placeholder = Language.MESSAGE
        tvMessage.contentInset = UIEdgeInsets(top: 8, left: 15, bottom: 5, right: 15)

        tvMessage.layer.borderColor = UIColor(named: "golden")?.cgColor
        tvMessage.layer.borderWidth = 1
        tvMessage.layer.cornerRadius = 10.0
        
        btnSubmit.setTitle(Language.SUBMIT, for: .normal)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit_Action(_ sender: Any) {
        if checkValidation() {
            callOrderRatingAPI()
        }
    }
    
    //MARK:- Other Functions
    func checkValidation() -> Bool{
        if vwRate.value < 0.0 {
            self.showError(Language.SELECT_RATING_TYPE)
            return false
        }else if tvMessage.text!.isEmpty{
            tvMessage.becomeFirstResponder()
            self.showError(Language.ENTER_COMMENT)
            return false
        }else{
            return true
        }
    }
    
    //MARK:- API Calling
    func callOrderRatingAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ORDER_RATING
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&order_id=\(orderID)&rating=\(vwRate.value)&rating_text=\(tvMessage.text!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
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
