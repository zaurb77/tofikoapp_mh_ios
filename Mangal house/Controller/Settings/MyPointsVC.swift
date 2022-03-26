//
//  MyPointsVC.swift
//  Mangal House
//
//  Created by My Mac on 19/12/19.
//  Copyright © 2019 Mahajan-iOS. All rights reserved.
//

import UIKit

class PointsCell: UICollectionViewCell {
    
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblMangal: UILabel!
    @IBOutlet weak var lblResName: UILabel!
    @IBOutlet weak var ivLayer: CustomImageView!
}

class MyPointsVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var lblMyMangals: UILabel!
    @IBOutlet weak var cvOffers: UICollectionView!
    @IBOutlet weak var consCvHeight: NSLayoutConstraint!
    @IBOutlet weak var ivQR: UIImageView!
    @IBOutlet weak var lblPoints: UILabel!
    @IBOutlet weak var lblAvalOffer: UILabel!
    
    var arrDictData = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()

        callGetOfferAPI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(UIColor(named: "golden")!)
        
        lblAvalOffer.text = Language.AVAILABLE_OFFERS
        lblMyMangals.text = Language.MY_MANGALS
    }
    
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
 
    //MARK:- Webservices
    func callGetOfferAPI() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        self.arrDictData.removeAll()
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        let time = df.string(from: Date())
        
        df.dateFormat = "EEEE"
        let dayName = df.string(from: Date())
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.OFFER_LIST
        let params = "?time=\(time)&day=\(dayName.lowercased())&latitude=\(LocationManager.sharedInstance.latitude)&longitude=\(LocationManager.sharedInstance.longitude)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
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
                            
                            if let arrOffers = responseData["offer_items"] as? [[String:AnyObject]], arrOffers.count > 0 {
                                self.arrDictData = arrOffers
                                self.cvOffers.reloadData()
                                            
                                let height = self.cvOffers.collectionViewLayout.collectionViewContentSize.height
                                self.consCvHeight.constant = height
                                self.view.setNeedsLayout()
                                
                            }else {
                                //No offer found
                            }
                            
                            if let qrImage = responseData["qr_image"] as? String, qrImage != "" {
                                self.ivQR.sd_imageIndicator = self.getSDGrayIndicator()
                                self.ivQR.sd_setImage(with: URL(string: qrImage.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                    self.ivQR.sd_imageIndicator = .none
                                }
                            }else{
                                self.ivQR.image = UIImage(named: "noImage")
                            }
                            
                            if let points = responseData["points"] as? String, points != "" {
                                self.lblPoints.text = "\(Language.MY_MANGAL_POINT) (\(points))"
                            }
                            
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
                            self.showError(Language.WENT_WRONG)
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
}

extension MyPointsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PointsCell", for: indexPath) as! PointsCell
        
        if let image = arrDictData[indexPath.row]["image"] as? String, image != "" {
            cell.imgItem.sd_imageIndicator = self.getSDGrayIndicator()
            cell.imgItem.sd_setImage(with: URL(string: image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.imgItem.sd_imageIndicator = .none
            }
        }
        
        if arrDictData[indexPath.row]["is_offer_active"] as! String == "1" {
//            cell.imgItem.alpha = 1.0
//            cell.contentView.backgroundColor = .white
            cell.ivLayer.isHidden = true
        }else {
            cell.ivLayer.isHidden = false
//            cell.imgItem.alpha = 0.2
//            cell.contentView.backgroundColor = UIColor(red: 184/255, green: 184/255, blue: 184/255, alpha: 0.4)
        }
        
        cell.lblItemName.text = arrDictData[indexPath.row]["offer_name"] as? String
        cell.lblResName.text = "\(Language.FROM) : \(arrDictData[indexPath.row]["restaurant_name"] as! String)"
        cell.lblMangal.text = arrDictData[indexPath.row]["offered_price"] as? String
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return CGSize(width: (self.cvOffers.frame.size.width - 20) / 2, height: 190)
        
        let size = self.cvOffers.frame.size.width
        return CGSize(width: ((size - 20) / 2), height: (size / 2) + 20 )
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let isOrderAccept = arrDictData[indexPath.row]["is_order_accept"] as! String
        let resError = arrDictData[indexPath.row]["res_open_error"] as! String
        
        if isOrderAccept == "1" {
            if settingModel.orderType != "" {
                        
                if arrDictData[indexPath.row]["is_offer_active"] as! String == "1" {
                    
                    if (self.arrDictData[indexPath.row]["item_id"] as! String).contains(",") {
                        callAddToCartAPI((self.arrDictData[indexPath.row])["id"] as! String, (self.arrDictData[indexPath.row])["restaurant_id"] as! String)
                    }else {
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ItemDetailVC") as! ItemDetailVC
                        vc.comeFrom = "BANNER_ITEM"
                        vc.orderType = settingModel.orderType
                        vc.itemId = (self.arrDictData[indexPath.row])["id"] as! String
                        vc.resId = (self.arrDictData[indexPath.row])["restaurant_id"] as! String
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            }else {
                if arrDictData[indexPath.row]["is_offer_active"] as! String == "1" {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderTypeVC") as! OrderTypeVC
                    
                    if (self.arrDictData[indexPath.row]["item_id"] as! String).contains(",") {
                        vc.comeFrom = "BANNER_ITEM_COMBO"
                        vc.itemId = (self.arrDictData[indexPath.row])["id"] as! String
                    }else {
                        vc.comeFrom = "BANNER_ITEM"
                        vc.itemId = (self.arrDictData[indexPath.row])["id"] as! String
                    }
                    
                    vc.resId = (self.arrDictData[indexPath.row])["restaurant_id"] as! String
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }else {
            if arrDictData[indexPath.row]["is_offer_active"] as! String == "1" {
                self.showError(resError)
            }
        }
        
        
    }
}
