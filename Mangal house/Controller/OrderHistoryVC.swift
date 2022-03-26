//
//  OrderHistoryVC.swift
//  Mangal house
//
//  Created by Mahajan on 08/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import HCSStarRatingView

class HistoryCell : UITableViewCell {
    @IBOutlet weak var lblResName: UILabel!
    @IBOutlet weak var ivRes: CustomImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTransactionID: UILabel!
    @IBOutlet weak var lblOrderDate: UILabel!
    @IBOutlet weak var btnRateNow: UIButton!
    @IBOutlet weak var btnRepeatOrder: UIButton!
    @IBOutlet weak var vwRate: HCSStarRatingView!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var cnsRateNowWidth: NSLayoutConstraint!
    @IBOutlet weak var cnsRateNowHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cnsVwRateWidth: NSLayoutConstraint!
    @IBOutlet weak var cnsVwRateHeight: NSLayoutConstraint!
    
    @IBOutlet weak var consRepeatNowHeight: NSLayoutConstraint!
    @IBOutlet weak var consDeliveredHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblTotalAmnt: UILabel!
    @IBOutlet weak var lblTransactionIDTitle: UILabel!
    @IBOutlet weak var lblOrderDateTitle: UILabel!
    
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblSep: UILabel!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var ivOrderStatus: UIImageView!
}

class OrderHistoryVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCompleted: CustomButton!
    @IBOutlet weak var btnPrepare: CustomButton!
    @IBOutlet weak var btnPending: CustomButton!
    @IBOutlet weak var ivCompleted: UIImageView!
    @IBOutlet weak var ivPrepare: UIImageView!
    @IBOutlet weak var ivPending: UIImageView!
    
    @IBOutlet weak var vwOrderHistory: UIView!
    @IBOutlet weak var tblOrderList: UITableView!
    
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var lblNoOrder: UILabel!
    
    //MARK:- Global Variables
    var selectedTab = "completed"
    var arrOrderList = [[String:AnyObject]]()
    var isNotification = false
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lblTitle.text = Language.ORDER_HISTORY
        btnCompleted.setTitle(Language.COMPLETED, for: .normal)
        btnPrepare.setTitle(Language.IN_PREPARE, for: .normal)
        btnPending.setTitle(Language.PENDING, for: .normal)
        lblWoops.text = Language.WOOPS
        
        setStatusBarColor(AppColors.golden)
        callOrderHistoryAPI()
        
        if isNotification {
            self.navigationController?.isNavigationBarHidden = true
        }
        
        if selectedTab == "in_prepare" {
            self.btnCompleted.backgroundColor = .white
            self.btnPrepare.backgroundColor = AppColors.golden
            self.btnPending.backgroundColor = .white
            
            self.btnCompleted.setTitleColor(AppColors.golden, for: .normal)
            self.btnPrepare.setTitleColor(.white, for: .normal)
            self.btnPending.setTitleColor(AppColors.golden, for: .normal)
            
            self.ivCompleted.isHidden = true
            self.ivPrepare.isHidden = false
            self.ivPending.isHidden = true
            
        }else if selectedTab == "pending" {
            self.btnCompleted.backgroundColor = .white
            self.btnPrepare.backgroundColor = .white
            self.btnPending.backgroundColor = AppColors.golden
            
            self.btnCompleted.setTitleColor(AppColors.golden, for: .normal)
            self.btnPrepare.setTitleColor(AppColors.golden, for: .normal)
            self.btnPending.setTitleColor(.white, for: .normal)
            
            self.ivCompleted.isHidden = true
            self.ivPrepare.isHidden = true
            self.ivPending.isHidden = false
            
        }else {
            self.btnCompleted.backgroundColor = AppColors.golden
            self.btnPrepare.backgroundColor = .white
            self.btnPending.backgroundColor = .white
            
            self.btnCompleted.setTitleColor(.white, for: .normal)
            self.btnPrepare.setTitleColor(AppColors.golden, for: .normal)
            self.btnPending.setTitleColor(AppColors.golden, for: .normal)
            
            self.ivCompleted.isHidden = false
            self.ivPrepare.isHidden = true
            self.ivPending.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        if isNotification {
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
        }else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnCompleted(_ sender: Any) {
        self.btnCompleted.backgroundColor = AppColors.golden
        self.btnPrepare.backgroundColor = .white
        self.btnPending.backgroundColor = .white
        
        self.btnCompleted.setTitleColor(.white, for: .normal)
        self.btnPrepare.setTitleColor(AppColors.golden, for: .normal)
        self.btnPending.setTitleColor(AppColors.golden, for: .normal)
        
        self.ivCompleted.isHidden = false
        self.ivPrepare.isHidden = true
        self.ivPending.isHidden = true
                
        selectedTab = "completed"
        callOrderHistoryAPI()
    }
    
    @IBAction func btnPrepare(_ sender: Any) {
        self.btnCompleted.backgroundColor = .white
        self.btnPrepare.backgroundColor = AppColors.golden
        self.btnPending.backgroundColor = .white
        
        self.btnCompleted.setTitleColor(AppColors.golden, for: .normal)
        self.btnPrepare.setTitleColor(.white, for: .normal)
        self.btnPending.setTitleColor(AppColors.golden, for: .normal)
        
        self.ivCompleted.isHidden = true
        self.ivPrepare.isHidden = false
        self.ivPending.isHidden = true
                
        selectedTab = "in_prepare"
        
        callOrderHistoryAPI()
    }
    
    @IBAction func btnPending(_ sender: Any) {
        self.btnCompleted.backgroundColor = .white
        self.btnPrepare.backgroundColor = .white
        self.btnPending.backgroundColor = AppColors.golden
        
        self.btnCompleted.setTitleColor(AppColors.golden, for: .normal)
        self.btnPrepare.setTitleColor(AppColors.golden, for: .normal)
        self.btnPending.setTitleColor(.white, for: .normal)
        
        self.ivCompleted.isHidden = true
        self.ivPrepare.isHidden = true
        self.ivPending.isHidden = false
                
        selectedTab = "pending"
        
        callOrderHistoryAPI()
    }
    
    //MARK:- Web Service Calling
    func callOrderHistoryAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
                
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ORDER_HISTORY
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&type=\(selectedTab)"
        
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
                        self.tblOrderList.isHidden = true
                        self.vwOrderHistory.isHidden = false
                        self.lblNoOrder.text = jsonObject["message"] as? String
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            
                            self.arrOrderList = responseData
                            if responseData.count > 0 {
                                self.tblOrderList.isHidden = false
                                self.vwOrderHistory.isHidden = true
                            }else {
                                self.tblOrderList.isHidden = true
                                self.vwOrderHistory.isHidden = false
                            }

                            self.lblNoOrder.text = jsonObject["message"] as? String
                            self.tblOrderList.reloadData()
                        } else {
                            self.showError(Language.WENT_WRONG)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    func callRepeatOrderAPI(_ orderID: String) {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        var cartId = ""
        if self.settingModel.cart_id != nil {
            cartId = self.settingModel.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.REPEAT_ORDER
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&time=\(time)&day=\(dayName.lowercased())&order_id=\(orderID)&cart_id=\(cartId)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else {
                        print(jsonObject)
                        
                        if let responseData = jsonObject["responsedata"] as? [String:String] {
                            if let isDiff = responseData["isdiff_res"], isDiff == "1"{
                               
                                var old = ""
                                if let oldName = responseData["diff_res_name"]{
                                    old = oldName
                                }
                                
                                let sen1 = Language.REPLACE_CART_ITEM
//                                let sen2 = "Your old cart is from xxx. Do you want to reorder?".replacingOccurrences(of: "xxx", with: "\((old))", options: .literal, range: nil)
                                
                                self.showAlertView("\n\(sen1) \n\n\(Language.WANT_TO_REORDER1) \(old). \(Language.WANT_TO_REORDER2)", defaultTitle: Language.YES_LABEL, cancelTitle: Language.NO_LABEL, completionHandler: { (finish) in
                                    if finish{
                                        self.settingModel.cart_id = ""
                                        UserModel.sharedInstance().synchroniseData()
                                        self.callRepeatOrderAPI(orderID)
                                    }
                                })
                            }else{
                                self.showSuccess(jsonObject["message"] as! String)
                                
                                self.settingModel.cart_id = responseData["cart_id"]!
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartVC") as! CartVC
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }

    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let destVC = segue.destination as! OrderHistoryDetailVC
            destVC.orderNo = sender as! String
            
        }else if segue.identifier == "toRate" {
            let destVC = segue.destination as! RatingVC
            destVC.orderID = sender as! String
        }
    }
    
}

extension OrderHistoryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOrderList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryCell
        

        cell.ivRes.sd_imageIndicator = self.getSDGrayIndicator()
        if let image = (self.arrOrderList[indexPath.row])["image"] as? String, image != ""{
            cell.ivRes.sd_setImage(with: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivRes.sd_imageIndicator = .none}
        }else{
            cell.ivRes.image = UIImage(named: "noImage")
        }
        
        cell.lblTotalAmnt.text = Language.TOTAL_AMOUNT.uppercased()
        cell.lblTransactionIDTitle.text = Language.TRANSACTION_ID.uppercased()
        cell.lblOrderDateTitle.text = Language.ORDER_DATE.uppercased()
        cell.btnRateNow.setTitle(Language.RATE_NOW, for: .normal)
        cell.btnRepeatOrder.setTitle(Language.REPEAT_ORDER, for: .normal)
        
        cell.lblResName.text = (self.arrOrderList[indexPath.row])["restaurant_name"] as? String
        cell.lblPrice.text = "\(self.settingModel.currency ?? "")\((self.arrOrderList[indexPath.row])["order_amount"] as! String)"
        cell.lblTransactionID.text = "#\((self.arrOrderList[indexPath.row])["order_number"] as! String)"
        cell.lblOrderDate.text = (self.arrOrderList[indexPath.row])["order_date"] as? String
        
        if self.selectedTab == "completed" {
            cell.consDeliveredHeight.constant = 20
            
            if self.arrOrderList[indexPath.row]["customer_comment"] as! String != "" && self.arrOrderList[indexPath.row]["rating"] as! String != "" {
                cell.cnsRateNowWidth.constant = 0
                cell.cnsRateNowHeight.constant = 0
                
                cell.cnsVwRateWidth.constant = 75
                cell.cnsVwRateHeight.constant = 30
                
                cell.vwRate.value = CGFloat(Double(self.arrOrderList[indexPath.row]["rating"] as! String)!)
                cell.lblRating.text = "~\(self.arrOrderList[indexPath.row]["restaurant_comment"] as! String)"
            }else {
                cell.cnsRateNowWidth.constant = 75
                cell.cnsRateNowHeight.constant = 35
                
                cell.cnsVwRateWidth.constant = 0
                cell.cnsVwRateHeight.constant = 0
                
                cell.lblRating.text = ""
            }
            
            if self.arrOrderList[indexPath.row]["order_status"] as! String == "decline" {
                cell.lblOrderStatus.text = Language.CANCELLED
                cell.ivOrderStatus.image = UIImage(named: "wrong")
            }else if self.arrOrderList[indexPath.row]["order_status"] as! String == "completed" {
                cell.lblOrderStatus.text = Language.COMPLETED
                cell.ivOrderStatus.image = UIImage(named: "select")
            }
            
            
            cell.lblSep.isHidden = false
            cell.consRepeatNowHeight.constant = 35
            
        }else {
            
            cell.consDeliveredHeight.constant = 0
            
            cell.cnsRateNowHeight.constant = 0
            cell.cnsRateNowWidth.constant = 0
            
            cell.cnsVwRateWidth.constant = 0
            cell.cnsVwRateHeight.constant = 0
            
            cell.lblRating.text = ""
            cell.lblSep.isHidden = true
            cell.consRepeatNowHeight.constant = 0
        }
        
        cell.btnRateNow.tag = indexPath.row
        cell.btnRateNow.addTarget(self, action: #selector(btnRateNow_Action(_:)), for: .touchUpInside)
        
        cell.btnRepeatOrder.tag = indexPath.row
        cell.btnRepeatOrder.addTarget(self, action: #selector(btnRepeatOrder_Action), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDetail", sender: (self.arrOrderList[indexPath.row])["order_number"] as! String)
    }
    
    @objc func btnRateNow_Action(_ sender: UIButton){
        self.performSegue(withIdentifier: "toRate", sender: (self.arrOrderList[sender.tag])["cart_id"] as! String)
    }
    
    @objc func btnRepeatOrder_Action(_ sender: UIButton) {
        self.showAlertView("\(Language.WANT_TO_REORDER1) \(self.arrOrderList[sender.tag]["restaurant_name"] as! String)\n"+"\(Language.WANT_TO_REORDER2)", defaultTitle: Language.YES_LABEL, cancelTitle: Language.NO_LABEL, completionHandler: { (finish) in
            if finish{
                self.callRepeatOrderAPI((self.arrOrderList[sender.tag])["cart_id"] as! String)
            }
        })
        
    }
    
}
