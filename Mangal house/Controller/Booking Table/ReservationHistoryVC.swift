//
//  ReservationHistoryVC.swift
//  Mangal house
//
//  Created by Mahajan on 25/08/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import SDWebImage

class ReservationHistoryCell : UITableViewCell{
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblGuest: UILabel!
    @IBOutlet weak var ivStore: UIImageView!
    @IBOutlet weak var consVwCancelBookingHeight: NSLayoutConstraint!
    @IBOutlet weak var btnCancelBooking: UIButton!
    @IBOutlet weak var lblStatus: CustomLabel!
    @IBOutlet weak var lblReasonTitle: UILabel!
    @IBOutlet weak var lblReason: UILabel!
    @IBOutlet weak var lblReplyTitle: UILabel!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var lblReject: UILabel!
    
}

class ReservationHistoryVC: Main {
    
    @IBOutlet weak var tblReservationHistory: UITableView!
    
    @IBOutlet weak var vwNoData: UIView!
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var lblSubError: UILabel!
    @IBOutlet weak var btnAddReservation: CustomButton!
    
    var arrDictHistory = [[String:AnyObject]]()
    var isNotification = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnAddReservation.setTitle(Language.ADD_A_NEW_RESERVATION, for: .normal)
        lblWoops.text = Language.WOOPS
        lblSubError.text = Language.BOOKINGS_NOT_FOUND
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callReservationHisotry()
        setStatusBarColor(AppColors.golden)
        if isNotification {
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        if isNotification {
            (UIApplication.shared.delegate as! AppDelegate).ChangeRoot_Home()
        }else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnAddNewReservation_Action(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationListVC") as! ReservationListVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func callReservationHisotry() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
       
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_BOOKING
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //self.showWarning("Warning", jsonObject["message"] as! String)
                        self.arrDictHistory.removeAll()
                        self.tblReservationHistory.reloadData()
                        self.vwNoData.isHidden = false
                        self.tblReservationHistory.isHidden = true
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            self.arrDictHistory = responseData
                            self.vwNoData.isHidden = true
                            self.tblReservationHistory.isHidden = false
                        }else{
                            self.vwNoData.isHidden = false
                        }
                        self.tblReservationHistory.reloadData()
                    }
                }
            }
            
        }) { (error) in
            self.vwNoData.isHidden = false
            self.tblReservationHistory.isHidden = true
            print(error)
        }
    }
    
    func callCancelReservation(_ booking: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
       
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CANCEL_RESERVED_BOOKING
        let params = "?lang_id=\(UserModel.sharedInstance().app_language!)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&booking=\(booking)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        self.callReservationHisotry()
                    }
                }
            }
            
        }) { (error) in
            self.vwNoData.isHidden = false
            self.tblReservationHistory.isHidden = true
            print(error)
        }
    }
    
    
}
extension ReservationHistoryVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationHistoryCell") as! ReservationHistoryCell
        
        let data = (arrDictHistory[indexPath.row])
        let time = data["tm"] as! String
        let date = data["dt"] as! String
        
        if data["store_image"] as! String != ""{
            cell.ivStore.sd_imageIndicator = getSDGrayIndicator()
            cell.ivStore.sd_setImage(with: URL(string: (data["store_image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivStore.sd_imageIndicator = .none
            }
        }else{
            cell.ivStore.image = UIImage(named: "noImage")
        }
        
        cell.btnCancelBooking.setTitle(Language.CANCEL_BOOKING, for: .normal)
        cell.lblname.text = data["store_name"] as? String
        cell.lblGuest.text = data["guests"] as? String
        cell.lblAddress.text = data["address"] as? String
        //cell.lblBooking.text = data["booking_number"] as? String
        cell.lblDateTime.text = "\(date) \(time)"
        
        if let status = data["status"] as? String, status != ""{
            
            if status == "pending"{
                cell.consVwCancelBookingHeight.constant = 60.0
                cell.lblStatus.text = "  \(Language.PENDING)  "
            }else if status == "approved"{
                cell.lblStatus.text = "  \(Language.APPROVED)  "
                cell.consVwCancelBookingHeight.constant = 60.0
            }else if status == "reject"{
                cell.consVwCancelBookingHeight.constant = 0.0
                cell.lblStatus.text = "  \(Language.REJECT)  "
            }else if status == "cancel"{
                cell.consVwCancelBookingHeight.constant = 0.0
                cell.lblStatus.text = "  \(Language.CANCEL)  "
            }else if status == "arrived"{
                cell.consVwCancelBookingHeight.constant = 0.0
                cell.lblStatus.text = "  Arrived  "
            }else if status == "left"{
                cell.consVwCancelBookingHeight.constant = 0.0
                cell.lblStatus.text = "  Left  "
            }
        }
        
        if let notes = data["notes"] as? String, notes != ""{
            cell.lblReasonTitle.text = Language.SPECIAL_REQ
            cell.lblReason.text = "~ \(notes)"
            cell.lblReasonTitle.isHidden = false
            cell.lblReason.isHidden = false
        }else{
            cell.lblReasonTitle.isHidden = true
            cell.lblReason.isHidden = true
        }
        
        if let notes_manager = data["notes_manager"] as? String, notes_manager != ""{
            cell.lblReply.text = "~ \(notes_manager)"
            cell.lblReplyTitle.text = Language.REPLY
            cell.lblReplyTitle.isHidden = false
            cell.lblReply.isHidden = false
        }else{
            cell.lblReplyTitle.isHidden = true
            cell.lblReply.isHidden = true
        }
        
        if let reason = data["reason"] as? String, reason != ""{
            cell.lblReject.text = "~ \(reason)"
            cell.lblReject.isHidden = false
            cell.lblReplyTitle.isHidden = true
            cell.lblReply.isHidden = true
            cell.lblReasonTitle.isHidden = true
            cell.lblReason.isHidden = true
        }else{
            cell.lblReject.isHidden = true
        }
        
        cell.btnCancelBooking.tag = indexPath.row
        cell.btnCancelBooking.addTarget(self, action: #selector(btnCancelBooking_Action(_:)), for: .touchUpInside)
        
        return cell
        
    }
    
    @objc func btnCancelBooking_Action(_ sender: UIButton){
        self.showAlertView("Are you sure you want to cancel this reservation?", defaultTitle: "Yes", cancelTitle: "No") { (finish) in
            if finish{
                if let id = (self.arrDictHistory[sender.tag])["id"] as? String, id != ""{
                    self.callCancelReservation(id)
                }
            }
        }
    }
    
}
