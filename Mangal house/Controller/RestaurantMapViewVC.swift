//
//  RestaurantMapViewVC.swift
//  Mangal house
//
//  Created by Mahajan on 08/01/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import MapViewPlus
import MapKit
import CoreLocation

class CustomCalloutViewModel: CalloutViewModel {
    
    var resId: String
    var resName: String
    var description: String
    var address: String
    var phoneNo: String
    var openTime: String
    var closeTime: String
    
    init(resId: String, resName: String, description: String, address: String, phoneNo: String, openTime: String, closeTime: String) {
        self.resId = resId
        self.resName = resName
        self.description = description
        self.address = address
        self.phoneNo = phoneNo
        self.openTime = openTime
        self.closeTime = closeTime
    }
}

class CalloutView: UIView, CalloutViewPlus {
    
    //MARK:- Outlets
    @IBOutlet weak var btnCollectHere: UIButton!
    @IBOutlet weak var lblResName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPhno: UILabel!
    @IBOutlet weak var lblOpenTime: UILabel!
    @IBOutlet weak var lblCloseTime: UILabel!
        
    @IBOutlet weak var lblPhnoTitle: UILabel!
    @IBOutlet weak var lblOpenCloseTitle: UILabel!
    
    func configureCallout(_ viewModel: CalloutViewModel) {
        let viewModel = viewModel as! CustomCalloutViewModel
        
        lblResName.text = viewModel.resName
        lblDescription.text = viewModel.description
        lblAddress.text = viewModel.address
        lblPhno.text = viewModel.phoneNo
        lblOpenTime.text = viewModel.openTime
        lblCloseTime.text = viewModel.closeTime
        btnCollectHere.accessibilityLabel = viewModel.resId
        
        lblOpenCloseTitle.text = "\(Language.MONDAY)-\(Language.SUNDAY)"
        lblPhnoTitle.text = Language.PHONE_NUMBER
        btnCollectHere.setTitle(Language.COLLECT_HERE.capitalized, for: .normal)
    }
}

class RestaurantMapViewVC: Main {
    
    //MARK:- Outlets
    @IBOutlet weak var mapView: MapViewPlus!
    
    //MARK:- Global Variables
    var comeFrom = ""
    var orderType = ""
    var arrDictData = [[String:AnyObject]]()
    var annotations: [AnnotationPlus] = []
    var didUpdateUserLocation = false
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        callRestaurantListAPI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setStatusBarColor(AppColors.golden)
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        if comeFrom == "WHERE_WE_ARE"{
            self.navigationController?.popToRootViewController(animated: true)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK:- Other Functions
    func setMapPin() {
        mapView.removeAllAnnotations()
        annotations.removeAll()
        
        for i in 0..<arrDictData.count {
            if let lat = arrDictData[i]["latitude"] as? String, let lng = arrDictData[i]["longitude"] as? String, lat != "", lng != "" {
                let location =  CLLocationCoordinate2DMake(Double(lat)!, Double(lng)!)
                let viewModel = CustomCalloutViewModel(resId: arrDictData[i]["id"] as! String, resName: arrDictData[i]["name"] as! String, description: arrDictData[i]["description"] as! String, address: arrDictData[i]["address"] as! String, phoneNo: arrDictData[i]["mobile_no"] as! String, openTime: arrDictData[i]["open_close_time1"] as! String, closeTime: arrDictData[i]["open_close_time2"] as! String)
                let annotation = AnnotationPlus(viewModel: viewModel, coordinate: location)
                annotations.append(annotation)
            }
        }
        mapView.setup(withAnnotations: annotations)
    }
   
    //MARK:- Web Service Calling
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
        let serviceURL = Constant.WEBURL + Constant.API.RESTAURANT_LIST
        let params = "?latitude=\(lat)&longitude=\(lng)&time=\(time)&day=\(dayName.lowercased())&address_id=&order_type=\(oType)&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                //Getting status of user login credentials. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                        self.showError(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            
                            self.arrDictData = responseData
                            self.setMapPin()
                            
                        } else {
                            self.showError("Someting went wrong")
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }
    
}

extension RestaurantMapViewVC : MapViewPlusDelegate{
    func mapView(_ mapView: MapViewPlus, imageFor annotation: AnnotationPlus) -> UIImage {
        let ivPin = UIImageView()
        ivPin.image = UIImage(named: "logoPin")!.withRenderingMode(.alwaysTemplate)
        ivPin.tintColor = .black
        return ivPin.image!
    }
    
    func mapView(_ mapView: MapViewPlus, calloutViewFor annotationView: AnnotationViewPlus) -> CalloutViewPlus{
        let calloutView = Bundle.main.loadNibNamed("CustomCallout", owner: nil, options: nil)!.first as! CalloutView
        
        calloutView.btnCollectHere.addTarget(self, action: #selector(btnCollectHere_Action(_:)), for: .touchUpInside)
        
        if comeFrom == "WHERE_WE_ARE" {
            calloutView.btnCollectHere.isHidden = true
        }else {
            calloutView.btnCollectHere.isHidden = false
        }
        
        return calloutView
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if(pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        }
        return pinView
    }
    
    @objc func btnCollectHere_Action(_ sender: UIButton){
        if comeFrom != "WHERE_WE_ARE"{
            let destVC = self.storyboard?.instantiateViewController(withIdentifier: "OrderMenuVC") as! OrderMenuVC
            destVC.resId = sender.accessibilityLabel!
            destVC.orderType = "pickup"
            self.navigationController?.pushViewController(destVC, animated: true)
        }
    }
                
    func mapView(_ mapView: MapViewPlus, didAddAnnotations annotations: [AnnotationPlus]) {
        if !didUpdateUserLocation {
            let lastAnnotation = annotations[annotations.count - 1]
            mapView.selectAnnotation(lastAnnotation, animated: true)
            
            let center = CLLocationCoordinate2DMake(lastAnnotation.coordinate.latitude, lastAnnotation.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10))
            self.mapView.setRegion(region, animated: true)
            
            didUpdateUserLocation = true
        }
    }
}
