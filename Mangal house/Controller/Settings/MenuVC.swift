//
//  MenuVC.swift
//  Mangal house
//
//  Created by Mahajan on 22/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
}

class MenuVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var consTblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnInstagram: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnMangal: UIButton!
    @IBOutlet weak var btnYoutube: UIButton!
    @IBOutlet weak var btnTelegram: UIButton!
    
    
    //MARK:- Global Variables
    var arrTitle = [String]()
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(UIColor.black)
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let tableViewHeight = self.tblView.frame.height
        let contentHeight = self.tblView.contentSize.height
        let centeringInset = (tableViewHeight - contentHeight) / 2.0
        let topInset = max(centeringInset, 0.0)
        if contentHeight < tableViewHeight {
            tblView.isScrollEnabled = false
        }else {
            tblView.isScrollEnabled = true
        }
        self.tblView.contentInset = UIEdgeInsets(top: topInset, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    //MARK:- Button Actions
    @IBAction func btnClose_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- Other Functions
    func setLayout() {
        
//        arrTitle.append(Language.HOME)
        arrTitle.append(Language.MY_CART)
        arrTitle.append(Language.ORDER_HISTORY)
        arrTitle.append(Language.SPECIAL_OFFERS)
        if settingModel.where_we_are == "1" {
            arrTitle.append(Language.WHERE_WE_ARE)
        }
        arrTitle.append(Language.CUSTOMER_SERVICE)
        
        if !isGuestUser() {
            arrTitle.append(Language.NOTIFICATION)
        }
        
        arrTitle.append(Language.SETTING)
        arrTitle.append(Language.SHARE_AND_EARN)
        
        if settingModel.policy == "1" {
            arrTitle.append(Language.PRIVACY_POLICY)
        }
        if settingModel.terms == "1" {
            arrTitle.append(Language.TERMS_AND_CONDITIONS)
        }
        if isGuestUser() {
            arrTitle.append(Language.LOGIN)
        }else {
            arrTitle.append(Language.LOGOUT)
        }
        
        if settingModel.instagram_channel == "1" {
            btnInstagram.isHidden = false
        }else {
            btnInstagram.isHidden = true
        }
        
        if settingModel.facebook_channel == "1" {
            btnFacebook.isHidden = false
        }else {
            btnFacebook.isHidden = true
        }
        
        if settingModel.mangal_link == "1" {
            btnMangal.isHidden = false
        }else {
            btnMangal.isHidden = true
        }
        
        if settingModel.youtube_channel == "1" {
            btnYoutube.isHidden = false
        }else {
            btnYoutube.isHidden = true
        }
        
        if settingModel.telegram_channel == "1" {
            btnTelegram.isHidden = false
        }else {
            btnTelegram.isHidden = true
        }
        
        self.tblView.reloadData()
    }
    
    func callLogoutLocal() {
        let email = UserModel.sharedInstance().email!
        let lang = UserModel.sharedInstance().app_language!
        let deviceToken = UserModel.sharedInstance().deviceToken!
        UserModel.sharedInstance().removeData()
        UserModel.sharedInstance().synchroniseData()
        UserModel.sharedInstance().email = email
        UserModel.sharedInstance().app_language = lang
        UserModel.sharedInstance().deviceToken = deviceToken
        UserModel.sharedInstance().synchroniseData()
        
        (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Login()
    }
    
    @IBAction func btnInsta_Action(_ sender: Any) {
        guard let url = URL(string: self.settingModel.insta_url) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnFb_Action(_ sender: Any) {
        guard let url = URL(string: self.settingModel.fb_url) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnWeb_Action(_ sender: Any) {
        guard let url = URL(string: self.settingModel.mangal_url) else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func btnYouTube_Action(_ sender: Any) {
       guard let url = URL(string: self.settingModel.youtube_url) else { return }
       UIApplication.shared.open(url)
    }
    
    @IBAction func btnTelegram_Action(_ sender: Any) {
        guard let url = URL(string: self.settingModel.telegram_url) else { return }
        UIApplication.shared.open(url)
    }
    
    //MARK:- WebService Calling
    func callLogOut() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.LOGOUT
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&device_token=\(UserModel.sharedInstance().deviceToken!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    self.showSuccess(jsonObject["message"] as! String)
                    if status == "0" {
                        self.callLogoutLocal()
                        print("Logout Failed")
                    }else {
                        self.callLogoutLocal()
                        print("Logout success")
                    }
                }
            }
        }) { (error) in
            self.callLogoutLocal()
            print(error)
        }
    }
}

extension MenuVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        
        cell.lblTitle.text = arrTitle[indexPath.row].uppercased()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = arrTitle[indexPath.row]
        if title == Language.HOME {
            self.navigationController?.popViewController(animated: false)
            
        }else if title == Language.MY_CART {
            
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                vc.isFrom = "menu"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if title == Language.ORDER_HISTORY {
            
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderHistoryVC") as! OrderHistoryVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if title == Language.SPECIAL_OFFERS {
            
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "MyPointsVC") as! MyPointsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if title == Language.WHERE_WE_ARE {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantMapViewVC") as! RestaurantMapViewVC
            vc.comeFrom = "WHERE_WE_ARE"
            self.navigationController?.pushViewController(vc, animated: true)
            
            
        }else if title == Language.CUSTOMER_SERVICE {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.SETTING {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.SHARE_AND_EARN {
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "InviteFriendsVC") as! InviteFriendsVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else if title == Language.PRIVACY_POLICY {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
            vc.strPageType = "policy"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.TERMS_AND_CONDITIONS {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
            vc.strPageType = "terms"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.LOGOUT {
            self.showAlertView(Language.LOGOUT_CONFIRM, defaultTitle: Language.YES_LABEL, cancelTitle: Language.NO_LABEL) { (finish) in
                if finish {
                    self.callLogOut()
                }
            }
            
        }else if title == Language.NOTIFICATION {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.LOGIN {
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Login()
        }
        
    }
    
}
