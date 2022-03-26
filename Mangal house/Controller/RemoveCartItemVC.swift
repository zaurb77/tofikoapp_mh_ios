
//  RemoveCartItemVC.swift
//  Mangal house
//
//  Created by Kinjal on 10/02/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import BottomPopup
import SDWebImage

protocol RemoveItemDelegate : NSObjectProtocol{
    func itemRemoved()
}

class RemoveCartItemCell : UITableViewCell{
 
    @IBOutlet weak var ivPic: CustomImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblitemName: UILabel!
    @IBOutlet weak var lblAddOn: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQty: CustomLabel!
    @IBOutlet weak var btnMinus: UIButton!
    
    @IBOutlet weak var cnsIvImageWIdth: NSLayoutConstraint!
}

class RemoveCartItemVC: BottomPopupViewController {

    //MARK:- Outlets
    @IBOutlet weak var tblView: UITableView!
    
    //MARK:- Global Variables
    var itemID = ""
    var arrCustList = [[String:AnyObject]]()
    var pHeight = 400.0
    weak var delegate : RemoveItemDelegate?
    
    //MARK:- Overridden Variables
    override var popupHeight: CGFloat {
        return CGFloat(pHeight)
    }
    override var popupTopCornerRadius: CGFloat { return  CGFloat(20) }
    override var popupPresentDuration: Double { return  0.5 }
    override var popupDismissDuration: Double { return  0.5 }
    override var popupShouldDismissInteractivelty: Bool { return  true }
    
    //MARK:- View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callCustListAPI()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if isBeingDismissed {
            self.dismiss(animated: true) {
                self.delegate?.itemRemoved()
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                
                
            }
        }
    }
        
    //MARK:- API Calling
    func callCustListAPI() {
        
        self.arrCustList.removeAll()
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var cartId = ""
        if SettingsModels.shared.cart_id != nil {
            cartId = SettingsModels.shared.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CART_CUSTOMIZATION_ITEMS
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&item_id=\(itemID)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.delegate?.itemRemoved()
                        self.dismiss(animated: true, completion: nil)
                        
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrCustList = responseData
                        }
                        
                        if self.arrCustList.count == 0 {
                            self.delegate?.itemRemoved()
                            self.dismiss(animated: true, completion: nil)
                        }else {
                            DispatchQueue.main.async {
                                self.tblView.reloadData()
                                let contentHeight = Double(self.tblView.contentSize.height + 20.0)
                                if contentHeight < 500.0 {
                                    self.pHeight = contentHeight
                                    self.tblView.isScrollEnabled = false
                                }else {
                                    self.pHeight = 500.0
                                    self.tblView.isScrollEnabled = true
                                }
                            self.view.layoutIfNeeded()
                            }
                        }
                        
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callChangeQtyAPI(_ itemID: String, _ qty: String) {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        var cartId = ""
        if SettingsModels.shared.cart_id != nil {
            cartId = SettingsModels.shared.cart_id
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.CHANGE_QTY
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&cart_id=\(cartId)&cart_item_id=\(itemID)&quantity=\(qty)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURLNoLoader(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        self.callCustListAPI()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension RemoveCartItemVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCustList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RemoveCartItemCell", for: indexPath) as! RemoveCartItemCell
        
        let dictData = arrCustList[indexPath.row]
        
        if dictData["image_enable"] as! String == "1" {
            cell.cnsIvImageWIdth.constant = 80
            if dictData["item_image"] as! String != ""{
                cell.ivPic.sd_imageIndicator = SDWebImageActivityIndicator.white
                cell.ivPic.sd_setImage(with: URL(string: (dictData["item_image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                    cell.ivPic.sd_imageIndicator = .none
                }
            }else {
                cell.ivPic.image = UIImage(named: "noImage")
            }
            
        }else {
            cell.cnsIvImageWIdth.constant = 0
        }
        
        cell.lblName.text = dictData["item_name"] as? String
        cell.lblPrice.text = "\(SettingsModels.shared.currency ?? "")\(dictData["price"] as! String)"
        cell.lblitemName.text = dictData["category"] as? String
        cell.lblQty.text = dictData["quantity"] as? String
        
        var strDesc = ""
        if let paidCust = dictData["paid_customization"] as? String, paidCust != "" {
            strDesc = "\(paidCust)"
        }
        
        if let freeCust = dictData["free_customization"] as? String, freeCust != "" {
            if strDesc != "" {
                strDesc = strDesc + "\n\(freeCust)"
            }else {
                strDesc = "\(freeCust)"
            }
        }
        cell.lblAddOn.text = strDesc
        
        cell.btnMinus.addTarget(self, action: #selector(btnMinus_Action(_:)), for: .touchUpInside)
        cell.btnMinus.tag = indexPath.row
        
        return cell
        
    }
    
    @objc func btnMinus_Action(_ sender : UIButton){
        var qty = 0
        if arrCustList[sender.tag]["quantity"] as! String != "" && arrCustList[sender.tag]["quantity"] as! String != "0" {
            qty = Int(arrCustList[sender.tag]["quantity"] as! String)!
        }
        callChangeQtyAPI(arrCustList[sender.tag]["cart_item_id"] as! String, "\(qty - 1)")
    }
    
}
