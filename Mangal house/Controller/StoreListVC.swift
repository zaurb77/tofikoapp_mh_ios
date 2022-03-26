 //
//  StoreListVC.swift
//  Mangal house
//
//  Created by Mahajan on 21/03/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit

class StoreListCell : UITableViewCell{
   
    @IBOutlet weak var ivStore: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblDays: UILabel!
    @IBOutlet weak var lblTime1: UILabel!
    @IBOutlet weak var lblTime2: UILabel!
 }

class StoreListVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var tblOrderList: UITableView!
    @IBOutlet weak var vwEmpty: UIView!
    
    @IBOutlet weak var btnAnotherAddress: CustomButton!
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var lblSubError: UILabel!
    
    
    //MARK:- Global Variables
    var arrStoreData = [[String:AnyObject]]()
    var addressID = ""
    var orderType = ""
    
    var subErrorText = ""
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tblOrderList.tableFooterView = UIView()
        
        if arrStoreData.count == 0{
            self.arrStoreData.removeAll()
            self.tblOrderList.reloadData()
            self.vwEmpty.isHidden = false
            self.lblSubError.text = subErrorText
        }else{
            self.vwEmpty.isHidden = true
        }
        
        if isGuestUser() {
            callRestaurantListAPI()
        }
        
        lblWoops.text = Language.WOOPS
        btnAnotherAddress.setTitle(Language.SELECT_ANOTHER_ADDRESS, for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBackToMainMenu_Action(_ sender: CustomButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Web Service Calling
    
    
    //MARK:- Navigation
    func callRestaurantListAPI() {
        
        self.view.endEditing(true)
        
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
        
        let lat = String(format: "%.5f", LocationManager.sharedInstance.latitude)
        let lng = String(format: "%.5f", LocationManager.sharedInstance.longitude)
        
        var oType = ""
        if orderType == "" {
            oType = "pickup"
        }else {
            oType = orderType
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_RESTAURANT_LIST
        let params = "?latitude=\(lat)&longitude=\(lng)&time=\(time)&day=\(dayName)&address_id=\(addressID)&order_type=\(oType)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        //self.showWarning("Warning", jsonObject["message"] as! String)
                        self.arrStoreData.removeAll()
                        self.tblOrderList.reloadData()
                        self.vwEmpty.isHidden = false
                        self.lblSubError.text = jsonObject["message"] as? String
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            self.arrStoreData = responseData
                            self.vwEmpty.isHidden = true
                        }
                        self.tblOrderList.reloadData()
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}

extension StoreListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStoreData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreListCell") as! StoreListCell
        
        let data = (arrStoreData[indexPath.row])
        cell.lblName.text = data["name"] as? String
        cell.lblDesc.text = data["description"] as? String
        cell.lblDays.text = data["days"] as? String
        
        cell.lblPhone.text = data["mobile_no"] as? String
        cell.lblTime1.text = data["open_close_time1"] as? String
        cell.lblTime2.text = data["open_close_time2"] as? String
        
        if data["image"] as! String != ""{
            cell.ivStore.sd_imageIndicator = getSDGrayIndicator()
            cell.ivStore.sd_setImage(with: URL(string: (data["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivStore.sd_imageIndicator = .none
            }
        }else{
            cell.ivStore.image = UIImage(named: "noImage")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let data = (arrStoreData[indexPath.row])
        if let res_id = data["id"] as? String  {
            self.settingModel.near_res_id = res_id
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
        vc.selectedAddressId = self.addressID
        vc.orderType = self.orderType
        vc.resId = self.settingModel.near_res_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
