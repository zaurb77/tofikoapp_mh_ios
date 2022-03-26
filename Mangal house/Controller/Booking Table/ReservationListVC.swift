//
//  ReservationListVC.swift
//  Mangal house
//
//  Created by Almighty Infotech on 20/08/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
   
class ReservationListCell : UITableViewCell{
    @IBOutlet weak var ivStore: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
 }

class ReservationListVC: Main {

    @IBOutlet weak var tfSearch: CustomTextField!
    @IBOutlet weak var tblReservationStore: UITableView!
    
    @IBOutlet weak var vwNoData: UIView!
    @IBOutlet weak var lblWoops: UILabel!
    @IBOutlet weak var lblSubError: UILabel!
    
    var arrStoreData = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tfSearch.addTarget(self, action: #selector(tfSearch_Action(_:)), for: .editingChanged)
        callReservationTableStoreList("")
        
        tfSearch.placeholder = Language.SEARCH
        lblWoops.text = Language.WOOPS
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
       
    @objc func tfSearch_Action(_ sender: UITextField){
        if sender.text != ""{
            callReservationTableStoreList(sender.text!)
        }
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callReservationTableStoreList(_ search: String) {
        
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
       
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESERVATION_STORE_LIST
        let params = "?time=\(time)&day=\(dayName)&company_id=\(company_id)&search=\(search)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
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
                        self.tblReservationStore.reloadData()
                        self.vwNoData.isHidden = false
                        self.tblReservationStore.isHidden = true
                        self.lblSubError.text = jsonObject["message"] as? String
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]], responseData.count > 0 {
                            self.arrStoreData = responseData
                            self.vwNoData.isHidden = true
                            self.tblReservationStore.isHidden = false
                        }
                        self.tblReservationStore.reloadData()
                    }
                }
            }
            
        }) { (error) in
            self.vwNoData.isHidden = false
            self.tblReservationStore.isHidden = true
            print(error)
        }
    }

}
extension ReservationListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStoreData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReservationListCell") as! ReservationListCell
        
        let data = (arrStoreData[indexPath.row])
        cell.lblName.text = data["name"] as? String
        cell.lblDesc.text = data["description"] as? String
        
        cell.lblPhone.text = data["mobile_no"] as? String
        
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
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReservationDetailVC") as! ReservationDetailVC
        vc.storeID = (arrStoreData[indexPath.row])["id"] as! String
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}
