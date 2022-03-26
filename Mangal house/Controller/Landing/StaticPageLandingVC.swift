//
//  StaticPageLandingVC.swift
//  Mangal house
//
//  Created by Kinjal on 02/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class StaticPageLandingVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    //MARK:- Global Variables
    var staticType = ""
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTitle.text = Language.TERMS_AND_CONDITIONS
        callStaticPageAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Webservices
    func callStaticPageAPI() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.STATIC
        let params = "?type=\(staticType)&lang_id=\(UserModel.sharedInstance().app_language!)&company_id=\(company_id)"
        
        //Starting process to fetch the data of terms & conditions
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            self.lblContent.text = (responseData["content"] as! String).html2String
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

}
