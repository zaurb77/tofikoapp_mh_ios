//
//  StaticPageVC.swift


import UIKit

class StaticPageVC: Main {

    //MARK:- Outlets
    @IBOutlet var tvContent: UITextView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    var strPageType = ""
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        callStaticPageAPI()
        
        if strPageType == "terms" {
            lblHeader.text = Language.TERMS_AND_CONDITIONS
        }else if strPageType == "policy" {
            lblHeader.text = Language.PRIVACY_POLICY
        }else if strPageType == "cookie" {
            lblHeader.text = Language.COOKIE_POLICY
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(UIColor(named: "golden")!)
    }
    
    //MARK:- Button Action
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Webserives
    func callStaticPageAPI() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.STATIC
        let params = "?type=\(strPageType)&lang_id=\(UserModel.sharedInstance().app_language!)&company_id=\(company_id)"
        
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
//                            self.tvContent.text = (responseData["content"] as! String).html2String
                            self.tvContent.attributedText = (responseData["content"] as! String).html2AttributedString
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
