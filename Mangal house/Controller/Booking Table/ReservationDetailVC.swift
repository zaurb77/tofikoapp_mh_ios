//
//  ReservationDetailVC.swift
//  Mangal house
//
//  Created by Almighty Infotech on 20/08/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import EzPopup
import SDWebImage
import MapKit

class ReservationDetailVC: Main {

    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var lblStoreName: UILabel!
    @IBOutlet weak var lblStoreDescription: UILabel!
    
    @IBOutlet weak var btnnext: CustomButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var lblAbout: UILabel!
    var storeID = ""
    var member_capacity = "0"
    
    var latitude = ""
    var longitude = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblAbout.text = Language.ABOUT
        btnnext.setTitle(Language.NEXT, for: .normal)
        
        callReservationTableStoreDetail()
        
    }
    
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnNext_Action(_ sender: UIButton) {
        let reservationBookingPopVC = ReservationBookingVC.instantiate()
        reservationBookingPopVC?.member_capacity = self.member_capacity
        reservationBookingPopVC?.reservationDelegate = self
        reservationBookingPopVC?.storeID = self.storeID
        let popupVC = PopupViewController(contentController: reservationBookingPopVC!, popupWidth: self.view.frame.size.width - 50)
        popupVC.cornerRadius = 5
        popupVC.canTapOutsideToDismiss = true
        present(popupVC, animated: true, completion: nil)
    }
    
    @IBAction func btnGetDirection_Action(_ sender: UIButton) {
        print("Direction")
        
        let latitude: CLLocationDegrees = Double(self.latitude)!
        let longitude: CLLocationDegrees = Double(self.longitude)!
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)

        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]

        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Place Name"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    func callReservationTableStoreDetail() {
        
        self.view.endEditing(true)
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.RESERVATION_STORE_DETAIL
        let params = "?store_id=\(storeID)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        if let msg = jsonObject["message"] as? String{
                            self.showWarning(msg)
                        }
                    }else{
                        print(jsonObject)
                        if let data = jsonObject["responsedata"] as? [String:AnyObject], !data.isEmpty{
                            
                            self.lblStoreName.text = data["name"] as? String
                            self.lblStoreDescription.text = data["description"] as? String
                            self.lblAddress.text = data["address"] as? String
                            self.lblMobile.text = data["mobile_no"] as? String
                            self.member_capacity = data["member_capacity"] as! String
                            
                            self.latitude = data["latitude"] as! String
                            self.longitude = data["longitude"] as! String
                            
                            self.ivBanner.sd_imageIndicator = SDWebImageActivityIndicator.white
                            self.ivBanner.sd_setImage(with: URL(string: (data["image"] as! String).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                self.ivBanner.sd_imageIndicator = .none
                            }
                        }
                        
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
}
extension ReservationDetailVC : BookingComplete{
    func resvervationComplete() {
        self.navigationController?.popToViewController1(ofClass: ReservationHistoryVC.self, animated: true)
    }
}
