//
//  NotificationVC.swift
//  Mangal House
//
//  Created by APPLE on 06/09/19.
//  Copyright © 2019 Mahajan-iOS. All rights reserved.
//

import UIKit

class NotificationVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblNotifications: UITableView!
    @IBOutlet weak var lblHeader: UILabel!
    
    //MARK:- Global Variables
    let arrCategoty = [Language.ORDER_NOTIFICATION , Language.NEWS_AND_OFFERS]
    let arrOption = [Language.PUSH_NOTIFICATION, Language.EMAIL_NOTIFICATION]
    
    //MARK:- View life cycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNotifications.tableFooterView = UIView()
        //lblHeader.text = Language.PUSH_NOTIFICATION
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
        
    //MARK:- Selector Method
    @objc func btnSwitch_Action(_ sender:UISwitch) {
        let tag = sender.accessibilityLabel!
        let arr = tag.components(separatedBy: "_")
        if arr[0] == "0" {
            if arr[1] == "0" {
                if sender.isOn {
                    callNotificationStatusService("order_push", 1)
                }else {
                    callNotificationStatusService("order_push", 0)
                }
            }else {
                if sender.isOn {
                    callNotificationStatusService("order_email", 1)
                }else {
                    callNotificationStatusService("order_email", 0)
                }
            }
        }else {
            if arr[1] == "0" {
                if sender.isOn {
                    callNotificationStatusService("news_push", 1)
                }else {
                    callNotificationStatusService("news_push", 0)
                }
            }else {
                if sender.isOn {
                    callNotificationStatusService("news_email", 1)
                }else {
                    callNotificationStatusService("news_email", 0)
                }
            }
        }
    }
    
    //MARK:- Webservices
    func callNotificationStatusService(_ notiType:String, _ notiStatus:Int) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_NOTIFICATION_STATUS
        let params = "?type=\(notiType)&status=\(notiStatus)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)"
        
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
                        
                        if notiType == "order_push" {
                            UserModel.sharedInstance().orderPushNotification = notiStatus
                        }else if notiType == "order_email" {
                            UserModel.sharedInstance().orderEmailNotification = notiStatus
                        }else if notiType == "news_push" {
                            UserModel.sharedInstance().newsPushNotification = notiStatus
                        }else {
                            UserModel.sharedInstance().newsEmailNotification = notiStatus
                        }
                        UserModel.sharedInstance().synchroniseData()
                        self.tblNotifications.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

//Notification manage from below code
extension NotificationVC : UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCategoty.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOption.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrCategoty[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "   \(arrOption[indexPath.row])".uppercased()
        cell.textLabel?.textColor = UIColor(named: "golden")
        cell.textLabel?.font = UIFont(name: "Raleway-Regular", size: 15.0)
        
        let switchView = UISwitch()
        switchView.onTintColor = UIColor(named: "golden")
        switchView.accessibilityLabel = "\(indexPath.section)_\(indexPath.row)"
        switchView.addTarget(self, action: #selector(btnSwitch_Action), for: .touchUpInside)
        cell.accessoryView = switchView
                
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if UserModel.sharedInstance().orderPushNotification != nil && UserModel.sharedInstance().orderPushNotification! == 0 {
                    switchView.setOn(false, animated: false)
                }else {
                    switchView.setOn(true, animated: false)
                }
            }else {
                if UserModel.sharedInstance().orderEmailNotification != nil && UserModel.sharedInstance().orderEmailNotification! == 0 {
                    switchView.setOn(false, animated: false)
                }else {
                    switchView.setOn(true, animated: false)
                }
            }
        }else {
            if indexPath.row == 0 {
                if UserModel.sharedInstance().newsPushNotification != nil && UserModel.sharedInstance().newsPushNotification! == 0 {
                    switchView.setOn(false, animated: false)
                }else {
                    switchView.setOn(true, animated: false)
                }
            }else {
                if UserModel.sharedInstance().newsEmailNotification != nil && UserModel.sharedInstance().newsEmailNotification! == 0 {
                    switchView.setOn(false, animated: false)
                }else {
                    switchView.setOn(true, animated: false)
                }
            }
        }
        return cell
    }
}
