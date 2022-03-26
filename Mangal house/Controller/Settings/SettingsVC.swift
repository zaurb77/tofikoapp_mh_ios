//
//  SettingsVC.swift


import UIKit

class LanguageCell : UITableViewCell{
    @IBOutlet weak var lblLangage: UILabel!
    @IBOutlet weak var ivMark: UIImageView!
}

//User can manage Push notification and make changes in own profile.
class SettingsVC: Main {

    //MARK:- Outlets
    @IBOutlet var tblSettingHeightCons: NSLayoutConstraint!
    @IBOutlet var tblSetting: UITableView!
    @IBOutlet weak var tblLanguage: UITableView!
    @IBOutlet var vwLanguage: UIView!
    @IBOutlet weak var blurView: UIImageView!
    @IBOutlet weak var lblSelectLang: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var lblVersion: UILabel!
    
    //MARK:- Global Variables
    var arrOption = [String]()
    var currentLanguageIndexPath = ""
    var arrDictLanguage = [[String:AnyObject]]()
    
    //MARK:- View Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vwLanguage.center = self.view.center
        self.view.addSubview(self.vwLanguage)
        self.blurView.isHidden = true
        self.vwLanguage.isHidden = true
        
        
        self.lblVersion.text = version()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.Language_Localization), name: Notification.Name("Language_Localization"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLayout()
        setStatusBarColor(AppColors.golden)
    }
        
    //MARK:- Selector Method
    @objc func Language_Localization() {
        setLayout()
        tblSetting.reloadData()
    }
    
    //MARK:- Other Methods
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(Language.VERSION)\n\(version).\(build)"
    }
    
    func setLayout() {
        
        lblSelectLang.text = Language.SELECT_LANGUAGE
        btnContinue.setTitle(Language.CONTINUE, for: .normal)
        
//        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
//        lblVersion.text = "\(Language.VERSION)\n\(appVersion)"
        
        arrOption.removeAll()
        let settingModel = SettingsModels.shared
        if !isGuestUser() {
            arrOption.append(Language.EDIT_PROFILE)
            arrOption.append(Language.PUSH_NOTIFICATION)
        }
        
        
        arrOption.append("LANGUAGE")
        callGetLanguageListAPI()
        
        if settingModel.terms == "1" {
            arrOption.append(Language.TERMS_AND_CONDITIONS)
        }
        if settingModel.policy == "1" {
            arrOption.append(Language.PRIVACY_POLICY)
        }
        if settingModel.cookie == "1" {
            arrOption.append(Language.COOKIES)
        }
        
        self.tblSetting.reloadData()
        
        
        tblSettingHeightCons.constant = tblSettingHeightCons.constant * CGFloat(arrOption.count)
        tblSetting.tableFooterView = UIView()
        tblLanguage.tableFooterView = UIView()
    }
    
    //MARK:- Button Actions
    @IBAction func btnMenu_Action(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnCancelPopup_Action(_ sender: Any) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blurView.isHidden = true
            self.vwLanguage.isHidden = true
        })
    }
    
    @IBAction func btnContinuePopup_Action(_ sender: Any) {
        let id = currentLanguageIndexPath
        
        if isGuestUser(){
            self.currentLanguageIndexPath = UserModel.sharedInstance().app_language!
            UserModel.sharedInstance().app_language = id
            UserModel.sharedInstance().synchroniseData()
            (UIApplication.shared.delegate as! AppDelegate).call_Get_Language()
        }else{
            callSetLanguageAPI(id)
        }
        
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.blurView.isHidden = true
            self.vwLanguage.isHidden = true
        })
    }
    
    //MARK:- WebServices
    func callGetLanguageListAPI() {
        
//        Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }

        var langId = ""
        if UserModel.sharedInstance().app_language != nil {
            langId = UserModel.sharedInstance().app_language!
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.LANGUAGE_LIST
        let params = "?lang_id=\(langId)"

        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in

            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {

                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        print(jsonObject)
                        if let responseData = jsonObject["responsedata"] as? [[String:AnyObject]] {
                            self.arrDictLanguage = responseData
                            self.tblLanguage.reloadData()

                            if UserModel.sharedInstance().app_language != nil{
                                self.currentLanguageIndexPath = UserModel.sharedInstance().app_language!
                            }
                        }
                    }
                }
            }

        }) { (error) in
            print(error)
        }
    }
    
    func callSetLanguageAPI(_ id : String) {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.SET_LANGUAGE
        let params = "?user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&lang_id=\(id)"
        
        //Starting process to fetch the data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                
                //Getting status of API. If status is 0 then fetching data otherwise it will show message of failure with reason.
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        print("Failed")
//                        CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                    }else {
//                        CommonFunctions.shared.showToast(self.view, jsonObject["message"] as! String)
                        print(jsonObject)
                        UserModel.sharedInstance().app_language = id
                        UserModel.sharedInstance().synchroniseData()
                        (UIApplication.shared.delegate as! AppDelegate).call_Get_Language()
                        
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
}

extension SettingsVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblSetting{
            return arrOption.count
        }else{
            return arrDictLanguage.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblSetting{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
            
            cell.lblTitle.text = arrOption[indexPath.row].uppercased()
//            cell.accessoryType = .disclosureIndicator
//            cell.textLabel?.textColor = UIColor(red: 75/255, green: 78/255, blue: 78/255, alpha: 1.0)
//            cell.textLabel?.font = UIFont(name: "Raleway-Bold", size: 16.0)
            cell.selectionStyle = .none
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell", for: indexPath) as! LanguageCell
            
            cell.lblLangage.text = (arrDictLanguage[indexPath.row])["full_name"] as? String
            
            if currentLanguageIndexPath == (arrDictLanguage[indexPath.row])["id"] as! String {
                cell.ivMark.image = UIImage(named: "checkboxFill")
            }else{
                cell.ivMark.image = UIImage(named: "checkboxEmpty")
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblSetting{
            let title = arrOption[indexPath.row]
            if title == Language.EDIT_PROFILE {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if title == Language.PUSH_NOTIFICATION {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if title == "LANGUAGE" {
                UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.blurView.isHidden = false
                    self.vwLanguage.isHidden = false
                })
                
            }else if title == Language.TERMS_AND_CONDITIONS {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
                vc.strPageType = "terms"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if title == Language.PRIVACY_POLICY {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
                vc.strPageType = "policy"
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else if title == Language.COOKIES {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
                vc.strPageType = "cookie"
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }else{
            
            currentLanguageIndexPath = (arrDictLanguage[indexPath.row])["id"] as! String
            self.tblLanguage.reloadData()
        }
        
    }
}
