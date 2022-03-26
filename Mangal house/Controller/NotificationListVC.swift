//
//  NotificationVC.swift
//  Mangal house
//
//  Created by Mahajan on 25/07/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class NotificationCell : UITableViewCell{
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDate: UILabel!
}

class NotificationListVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var lblNOData: UILabel!
    @IBOutlet weak var vwNoData: UIView!
    var arrDictData = [[String:AnyObject]]()
    
    //MARK:- Global Variables
    
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callNotificationList()
        
        lblWoops.text = Language.WOOPS
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Button Actions
   
    
    //MARK:- Other Methods
    
    
    //MARK:- Webservices
    func callNotificationList() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let serviceURL = Constant.WEBURL + Constant.API.NOTIFICATION_LIST
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String , status == "1"{
                    if let data = jsonObject["responsedata"] as? [[String:AnyObject]], data.count > 0{
                        self.arrDictData = data
                        self.tblNotification.reloadData()
                        self.tblNotification.isHidden = false
                        self.vwNoData.isHidden = true
                    }else{
                        self.tblNotification.isHidden = true
                        self.vwNoData.isHidden = false
                        self.lblNOData.text = jsonObject["message"] as? String
                    }
                }else{
                    self.tblNotification.isHidden = true
                    self.vwNoData.isHidden = false
                    self.lblNOData.text = jsonObject["message"] as? String
                }
            }
        }) { (error) in
            self.tblNotification.isHidden = true
            self.vwNoData.isHidden = false
            print(error)
        }
    }
    
   
    
}

extension NotificationListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! NotificationCell
        
        cell.lblStoreName.text = (arrDictData[indexPath.row])["store_name"] as? String
        cell.lblHeading.text = (arrDictData[indexPath.row])["heading"] as? String
        
        if let cat = (arrDictData[indexPath.row])["cat"] as? String, cat != ""{
            cell.lblDate.text = self.convertDateFormatterDynamic(inputFormatter: "yyyy-MM-dd HH:mm:ss", outputFormatter: "MMM dd, yyyy hh:mm a", date: cat)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailVC") as! NotificationDetailVC
        vc.dictData = arrDictData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
