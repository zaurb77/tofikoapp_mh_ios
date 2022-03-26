//
//  FAQVC.swift
//  Mangal house
//
//  Created by Mahajan on 01/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class FaqCell : UITableViewCell{
    @IBOutlet weak var btnOpenClose: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
}

class FAQVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tblFaq: UITableView!
    @IBOutlet weak var lblContactSupport: UILabel!
    @IBOutlet weak var lblFaq: UILabel!
    @IBOutlet weak var btnContactUs: UIButton!
    
    //MARK:- Global Variables
    var arrDictData = [[String:String]]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblContactSupport.text = Language.CONTACT_SUPPORT
        lblFaq.text = Language.FAQ
        btnContactUs.setTitle(Language.STILL_QUESTIONS, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
        callFAQQueAPI()
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnContactUs_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toContact", sender: nil)
    }
    
    //MARK:- Webservices
    func callFAQQueAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CONTACT_QUE + "?lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL, success: { (response) in
            
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
                        if let responseData = jsonObject["responsedata"] as? [[String:String]] {
                            
                            self.arrDictData = responseData
                            
                        } else {
                            self.showWarning(Language.WENT_WRONG)
                        }
                        
                        self.tblFaq.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension FAQVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqCell") as! FaqCell
        
        cell.lblTitle.text = (self.arrDictData[indexPath.row])["question"]
        
        if cell.lblDesc.text == ""{
            cell.lblDesc.text = ""
            cell.btnOpenClose.setTitle("+", for: .normal)
        }else{
            cell.btnOpenClose.setTitle("-", for: .normal)
            cell.lblDesc.text = (self.arrDictData[indexPath.row])["answer"]
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FaqCell
        
        if cell.lblDesc.text != ""{
           cell.lblDesc.text = ""
            cell.btnOpenClose.setTitle("+", for: .normal)
        }else{
            cell.btnOpenClose.setTitle("-", for: .normal)
            cell.lblDesc.text = (self.arrDictData[indexPath.row])["answer"]
        }
        self.tblFaq.reloadData()
    }
}
