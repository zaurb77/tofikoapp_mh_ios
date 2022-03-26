//
//  HomeVC.swift
//  Mangal house
//
//  Created by Mahajan on 21/12/20.
//  Copyright © 2020 Almighty Infotech. All rights reserved.
//

import UIKit
import SDWebImage

class HomeBannerCell: UICollectionViewCell{
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var cnsPriceHeight: NSLayoutConstraint!
    @IBOutlet weak var btnAdd: CustomButton!
    @IBOutlet weak var cnsHeightBtnadd: NSLayoutConstraint!
}

class HomeMenuCell: UITableViewCell{
    @IBOutlet weak var lblTitle: UILabel!
}

class HomeVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var cvBanner: UICollectionView!
    @IBOutlet weak var tblOptions: UITableView!
    @IBOutlet weak var cnsTblHeight: NSLayoutConstraint!
    @IBOutlet weak var cnsCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var lblCartQty: CustomLabel!
    @IBOutlet weak var btnCart: UIButton!
    @IBOutlet weak var ivSponser: UIImageView!
    
    
    //MARK:- Global Variables
    var arrTitle = [String]()
    var arrBanners = [[String:AnyObject]]()
    var timer = Timer()
    var currentIndex = 0
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openSponser))
        ivSponser.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if UserModel.sharedInstance().app_version != nil && UserModel.sharedInstance().app_version != "" {
            let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
            if Double(UserModel.sharedInstance().app_version!)! > Double(appVersion)!{
                launchAppUpdatePopup()
            }
        }
        
        (UIApplication.shared.delegate as! AppDelegate).call_Get_Language()
        
        setStatusBarColor(AppColors.golden)
        self.callGetSettingAPI()
        
        if UserModel.sharedInstance().isPaypalCheckout != nil && UserModel.sharedInstance().isPaypalCheckout == "true" {
            
            UserModel.sharedInstance().isPaypalCheckout = nil
            UserModel.sharedInstance().synchroniseData()
            
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
    
    func doStuffInAppear() {
        
    }
    
    //MARK:- Button Actions
    @objc func openSponser(_ sender: UITapGestureRecognizer) {
        guard let url = URL(string: "https://www.tofiko.com/") else { return }
        UIApplication.shared.open(url)
    }
    
    @objc func changeSliderImage() {
        if currentIndex < arrBanners.count {
            let indexPath = IndexPath(row: currentIndex, section: 0)
            self.cvBanner.scrollToItem(at: indexPath, at: .left, animated: true)
        }else {
            currentIndex = 0
            let indexPath = IndexPath(row: currentIndex, section: 0)
            self.cvBanner.scrollToItem(at: indexPath, at: .right, animated: true)
        }
        currentIndex += 1
    }
    
    @IBAction func btnMenu_Action(_ sender: Any) {
        self.performSegue(withIdentifier: "toMenu", sender: nil)
    }
    
    @IBAction func btnCart_Action(_ sender: Any) {
        
        if isGuestUser() {
            changeGuestToLogin()
        }else {
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
    }
    
    @objc func btnAddBanner_Action(_ sender: UIButton) {
        if !isGuestUser() {
            if settingModel.orderType != "" {
                callAddToCartAPI((self.arrBanners[sender.tag])["id"] as! String, (self.arrBanners[sender.tag])["res_id"] as! String)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderTypeVC") as! OrderTypeVC
                vc.comeFrom = "BANNER_ITEM_COMBO"
                vc.itemId = (self.arrBanners[sender.tag])["item_id"] as! String
                vc.resId = (self.arrBanners[sender.tag])["res_id"] as! String
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK:- Web Service Calling
    func callGetSettingAPI() {
        
        self.view.endEditing(true)
        
//        Checking for internet connection. If internet is not available then system will display toast message.
//        guard NetworkManager.shared.isConnectedToNetwork() else {
//            self.showWarning(Language.CHECK_INTERNET)
//            return
//        }
        
        self.checkNoInternetConnection()
        
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_APP_SETTINGS
        
        var userId = "", authToken = ""
        if UserModel.sharedInstance().user_id == nil && UserModel.sharedInstance().authToken == nil{
            userId = ""
            authToken = ""
        }else {
            userId = UserModel.sharedInstance().user_id!
            authToken = UserModel.sharedInstance().authToken!
        }
        
        let params = "?latitude=\(LocationManager.sharedInstance.latitude)&longitude=\(LocationManager.sharedInstance.longitude)&user_id=\(userId)&auth_token=\(authToken)&cart_id=\(cartId)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
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
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if let settings = responseData["settings"] as? [String:AnyObject] {
                                self.settingModel.terms              = settings["terms"] as? String
                                self.settingModel.policy             = settings["policy"] as? String
                                self.settingModel.cookie             = settings["cookie"] as? String
                                self.settingModel.offer_banner       = settings["offer_banner"] as? String
                                self.settingModel.youtube_channel    = settings["youtube_channel"] as? String
                                self.settingModel.mangal_link        = settings["mangal_link"] as? String
                                self.settingModel.facebook_channel   = settings["facebook_channel"] as? String
                                self.settingModel.instagram_channel  = settings["instagram_channel"] as? String
                                self.settingModel.telegram_channel   = settings["telegram_channel"] as? String
                                self.settingModel.facebook_share     = settings["facebook_share"] as? String
                                self.settingModel.instagram_share    = settings["instagram_share"] as? String
                                self.settingModel.linkedin_share     = settings["linkedin_share"] as? String
                                self.settingModel.whatsapp_share     = settings["whatsapp_share"] as? String
                                self.settingModel.telegram_share     = settings["telegram_share"] as? String
                                self.settingModel.where_we_are       = settings["where_we_are"] as? String
                                self.settingModel.about_us           = settings["about_us"] as? String
                                self.settingModel.invite_friends     = settings["invite_friends"] as? String
                                self.settingModel.menu_search        = settings["menu_search"] as? String
                                self.settingModel.grid               = settings["grid"] as? String
                                self.settingModel.table_booking      = settings["table_booking"] as? String
                            }
                            
                            if let currency = responseData["currency"] as? String, currency != "" {
                                self.settingModel.currency           = "\(currency) "
                            }
                            
                            if let settings = responseData["social_links"] as? [String:String] {
                                self.settingModel.fb_url              = settings["fb_url"]
                                self.settingModel.insta_url           = settings["insta_url"]
                                self.settingModel.mangal_url          = settings["mangal_url"]
                                self.settingModel.youtube_url         = settings["youtube_url"]
                                self.settingModel.telegram_url        = settings["telegram_url"]
                                self.settingModel.insta_img           = settings["insta_img"]
                                self.settingModel.referral_msg        = settings["referral_msg"]
                            }
                            
                            self.settingModel.near_res_id            = responseData["restaurant_id"] as? String
                            self.settingModel.orderType              = responseData["order_type"] as? String
                            
                            if responseData["order_status"] as! String == "1" {
                                self.settingModel.cart_id = responseData["cart_id"] as? String
                            }else {
                                self.settingModel.cart_id = ""
                                self.settingModel.selected_delivery_address = ""
                            }
                            
                            if responseData["cart_items"] as! String != "" && responseData["cart_items"] as! String != "0" {
                                self.lblCartQty.text = responseData["cart_items"] as? String
                                self.lblCartQty.isHidden = false
                            }else {
                                self.lblCartQty.text = ""
                                self.lblCartQty.isHidden = true
                            }
                            
                            self.arrTitle.removeAll()
                            
                            self.arrTitle.append(Language.ORDER_FROM_MENU)
                            
                            if self.settingModel.table_booking == "1" {
                                self.arrTitle.append(Language.BOOK_A_TABLE)
                            }
                            
                            self.arrTitle.append(Language.INVITE_FRIENDS_LABEL)
                            self.arrTitle.append(Language.MY_ORDER_HISTORY)
                            self.arrTitle.append(Language.SPECIAL_OFFERS)
                            if self.settingModel.where_we_are == "1" {
                                self.arrTitle.append(Language.WHERE_WE_ARE)
                            }
                            
                            if self.settingModel.about_us == "1" {
                                self.arrTitle.append(Language.ABOUT_US)
                            }
                            
                            if self.isGuestUser() {
                                self.arrTitle.append(Language.LOGIN)
                            }else {
                                self.arrTitle.append(Language.MY_ACCOUNT)
                            }
                            
                            self.tblOptions.reloadData()
                            
                            if self.settingModel.offer_banner == "1" {
                                if let banners = responseData["banners"] as? [[String:AnyObject]], banners.count > 0 {
                                    self.cnsCollectionHeight.constant = self.view.frame.height * 0.28
                                    self.arrBanners = banners
                                    self.cvBanner.reloadData()
                                    
                                    self.timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(self.changeSliderImage), userInfo: nil, repeats: true)
                                }else {
                                    self.arrBanners.removeAll()
                                    self.cvBanner.reloadData()
                                    self.cnsCollectionHeight.constant = 0
                                }
                            }else {
                                self.arrBanners.removeAll()
                                self.cvBanner.reloadData()
                                self.cnsCollectionHeight.constant = 0
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
    
    func callAddToCartAPI(_ itemID: String, _ resID: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ADD_TO_CART
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&restaurant_id=\(resID)&item_id=\(itemID)&quantity=1&paid_customization=&free_customization=&cart_id=\(cartId)&address_id=&order_type=pickup"
        
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
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if let isDiffRes = responseData["isdiff_res"] as? String, isDiffRes == "1" {
                                
                                var old = ""
                                if let oldName = responseData["diff_res_name"] as? String {
                                    old = oldName
                                }
                                self.showAlertView("Replace Cart Item?", "Your cart contains dishes from \(old). Do you want to discard selection and add dishes from this store.", defaultTitle: "Yes", cancelTitle: "No") { (finish) in
                                    if finish {
                                        self.settingModel.cart_id = ""
                                        self.callAddToCartAPI(itemID, resID)
                                    }
                                }
                                
                            }else {
                                if let cart_id = responseData["cart_id"] as? String  {
                                    self.settingModel.cart_id = cart_id
                                }
                                self.showSuccess(jsonObject["message"] as! String)
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                                vc.isFrom = "address"
                                self.navigationController?.pushViewController(vc, animated: true)
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
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeMenuCell") as! HomeMenuCell
        
        cell.lblTitle.text = arrTitle[indexPath.row].uppercased()
        
        self.cnsTblHeight.constant = tblOptions.contentSize.height
        self.view.layoutIfNeeded()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let title = arrTitle[indexPath.row]
        if title == Language.ORDER_FROM_MENU {
            
            if settingModel.cart_id != "" {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
                vc.orderType = settingModel.orderType
                vc.resId = settingModel.near_res_id
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                if settingModel.orderType == "" {
                    self.performSegue(withIdentifier: "toOrderType", sender: nil)
                    
                }else if settingModel.orderType == "pickup" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantMapViewVC") as! RestaurantMapViewVC
                    vc.orderType = settingModel.orderType
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
                    vc.orderType = "delivery"
                    vc.resId = settingModel.near_res_id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }else if title == Language.INVITE_FRIENDS_LABEL {
            if isGuestUser() {
                changeGuestToLogin()
            }else {
                self.performSegue(withIdentifier: "toInvite", sender: nil)
            }
        }else if title == Language.MY_ORDER_HISTORY {
            
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
                self.performSegue(withIdentifier: "toPoint", sender: nil)
            }
            
        }else if title == Language.WHERE_WE_ARE {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RestaurantMapViewVC") as! RestaurantMapViewVC
            vc.comeFrom = "WHERE_WE_ARE"
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.ABOUT_US {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsVC") as! AboutUsVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.MY_ACCOUNT {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else if title == Language.LOGIN {
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Login()
            
        }else if title == Language.BOOK_A_TABLE {
            
          let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationHistoryVC") as! ReservationHistoryVC
          self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrBanners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeBannerCell", for: indexPath) as! HomeBannerCell
        
        cell.ivBanner.sd_imageIndicator = SDWebImageActivityIndicator.white
        cell.ivBanner.sd_setImage(with: URL(string: ((self.arrBanners[indexPath.row])["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
            cell.ivBanner.sd_imageIndicator = .none
        }
        
        if arrBanners[indexPath.row]["ad_type"] as! String == "0" {
            cell.cnsPriceHeight.constant = 0
        }else {
            
            if arrBanners[indexPath.row]["ad_type"] as! String == "2" {
                cell.cnsHeightBtnadd.constant = 30
                
                cell.btnAdd.tag = indexPath.row
                cell.btnAdd.addTarget(self, action: #selector(btnAddBanner_Action), for: .touchUpInside)
            }else {
                cell.cnsHeightBtnadd.constant = 0
            }
            
            cell.cnsPriceHeight.constant = 50
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !isGuestUser() {
            if (self.arrBanners[indexPath.row])["ad_type"] as! String == "1" {
                
                if settingModel.orderType != "" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
                    vc.comeFrom = "BANNER_ITEM"
                    vc.orderType = settingModel.orderType
                    vc.itemId = (self.arrBanners[indexPath.row])["item_id"] as! String
                    vc.resId = (self.arrBanners[indexPath.row])["res_id"] as! String
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderTypeVC") as! OrderTypeVC
                    vc.comeFrom = "BANNER_ITEM"
                    vc.itemId = (self.arrBanners[indexPath.row])["item_id"] as! String
                    vc.resId = (self.arrBanners[indexPath.row])["res_id"] as! String
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.height * 0.28)
    }
}
