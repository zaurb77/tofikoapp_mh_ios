//
//  AboutUsVC.swift


import UIKit
import Alamofire
import SDWebImage

class AboutCell : UITableViewCell {
    
    @IBOutlet weak var ivBanner: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
}

class AboutUsVC: Main {

    //MARK:- Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var cnsHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivTopBanner: UIImageView!
    //MARK:- Global Variables
    var arrDictData = [[String:String]]()
    
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()

        tblView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        callAboutUs()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]{
                let newsize  = newvalue as! CGSize
                self.cnsHeight.constant = newsize.height
            }
        }
    }
    
    //MARK:- Button Actions
    @IBAction func btnBack_Action(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func callAboutUs() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.ABOUT_US
        let params = "?&company_id=\(company_id)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    if status == "0"{
                        print("Failed")
                        self.showWarning(jsonObject["message"] as! String)
                        
                    }else{
                        print(jsonObject)
                        
                        //Getting data from API and storing it in the UserDefault variable for further use.
                        if let responseData = jsonObject["responsedata"] as? [String:AnyObject] {
                            
                            if let arrOffers = responseData["data"] as? [[String:String]], arrOffers.count > 0 {
                                self.arrDictData = arrOffers
                                self.tblView.reloadData()
                                
                            }
                            
                            if let img = responseData["about_banner"] as? String, img != "" {
                                self.ivTopBanner.sd_imageIndicator = self.getSDGrayIndicator()
                                self.ivTopBanner.sd_setImage(with: URL(string: img.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                                    self.ivTopBanner.sd_imageIndicator = .none
                                }
                            }else{
                                self.ivTopBanner.image = UIImage(named: "noImage")
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


extension AboutUsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDictData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AboutCell", for: indexPath) as! AboutCell
        
        if let img = arrDictData[indexPath.row]["image"], img != "" {
            cell.ivBanner.sd_imageIndicator = self.getSDGrayIndicator()
            cell.ivBanner.sd_setImage(with: URL(string: img.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)) { (image, error, cache, url) in
                cell.ivBanner.sd_imageIndicator = .none
            }
        }else{
            cell.ivBanner.image = UIImage(named: "noImage")
        }
        
        cell.lblTitle.text = arrDictData[indexPath.row]["title"]!
        cell.lblSubTitle.text = arrDictData[indexPath.row]["sub_title"]!
        cell.lblDesc.text = arrDictData[indexPath.row]["descr"]!
            
        return cell
    }
}
