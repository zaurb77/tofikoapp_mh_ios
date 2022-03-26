
//
//  UserModel.swift

import UIKit

class UserModel: NSObject, NSCoding {
    
    var user_id : String?
    var authToken: String?
    var deviceToken: String?
    
    var firstname : String?
    var lastname : String?
    var email : String?
    var password : String?
    var profile_image : String?
    var birthdate : String?
    var gender: String?
    var mobileNo: String?
    var country_code : String?
    
    var address: String?
    var address1: String?
    var city: String?
    var country: String?
    var zipCode: String?
    
    var latitude: String?
    var longitude: String?
    
    var isCompany: Int?
    var companyId : String?
    var companyName: String?
    var companyLegalEmail: String?
    var province: String?
    var uniqueInvoiceCode: String?
    var vatId: String?
    
    var newsEmailNotification: Int?
    var newsPushNotification: Int?
    var orderEmailNotification: Int?
    var orderPushNotification: Int?
        
    var stripeCustId : String?
    
    var total_points : String?
    var fb_point : String?
    var insta_point : String?
    var invite_points : String?
    
    var qr_img : String?
    var refer_Code : String?
    
    var app_language : String?
    
    var isPaypalCheckout: String?
    
    var isGuestLogin: String?
    var app_version: String?
    
    static var userModel: UserModel?
    static func sharedInstance() -> UserModel {
        if UserModel.userModel == nil {
            if let data = UserDefaults.standard.value(forKey: "UserModel") as? Data {
                let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: data)
                if let objUserModel = retrievedObject as? UserModel {
                    UserModel.userModel = objUserModel
                    return objUserModel
                }
            }
            
            if UserModel.userModel == nil {
                UserModel.userModel = UserModel.init()
            }
            return UserModel.userModel!
        }
        return UserModel.userModel!
    }
    
    override init() {
        
    }
    
    
    func synchroniseData(){
        let data : Data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: "UserModel")
        UserDefaults.standard.synchronize()
    }
    
    func removeData() {
        UserModel.userModel = nil
        UserDefaults.standard.removeObject(forKey: "UserModel")
        UserDefaults.standard.synchronize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        self.user_id = aDecoder.decodeObject(forKey: "user_id") as? String
        self.authToken = aDecoder.decodeObject(forKey: "authToken") as? String
        self.deviceToken = aDecoder.decodeObject(forKey: "deviceToken") as? String
        
        self.firstname = aDecoder.decodeObject(forKey: "firstname") as? String
        self.lastname = aDecoder.decodeObject(forKey: "lastname") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.password = aDecoder.decodeObject(forKey: "password") as? String
        self.profile_image = aDecoder.decodeObject(forKey: "profile_image") as? String
        self.birthdate = aDecoder.decodeObject(forKey: "birthdate") as? String
        self.gender = aDecoder.decodeObject(forKey: "gender") as? String
        self.mobileNo = aDecoder.decodeObject(forKey: "mobileNo") as? String
        self.country_code = aDecoder.decodeObject(forKey: "country_code") as? String
        
        self.address = aDecoder.decodeObject(forKey: "address") as? String
        self.address1 = aDecoder.decodeObject(forKey: "address1") as? String
        self.city = aDecoder.decodeObject(forKey: "city") as? String
        self.country = aDecoder.decodeObject(forKey: "country") as? String
        self.zipCode = aDecoder.decodeObject(forKey: "zipCode") as? String
        
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? String
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? String
        
        self.isCompany = aDecoder.decodeObject(forKey: "isCompany") as? Int
        self.companyId = aDecoder.decodeObject(forKey: "companyId") as? String
        self.companyName = aDecoder.decodeObject(forKey: "companyName") as? String
        self.companyLegalEmail = aDecoder.decodeObject(forKey: "companyLegalEmail") as? String
        self.province = aDecoder.decodeObject(forKey: "province") as? String
        self.uniqueInvoiceCode = aDecoder.decodeObject(forKey: "uniqueInvoiceCode") as? String
        self.vatId = aDecoder.decodeObject(forKey: "vatId") as? String
        
        self.newsEmailNotification = aDecoder.decodeObject(forKey: "newsEmailNotification") as? Int
        self.newsPushNotification = aDecoder.decodeObject(forKey: "newsPushNotification") as? Int
        self.orderEmailNotification = aDecoder.decodeObject(forKey: "orderEmailNotification") as? Int
        self.orderPushNotification = aDecoder.decodeObject(forKey: "orderPushNotification") as? Int
        
        self.stripeCustId = aDecoder.decodeObject(forKey: "stripeCustId") as? String
        
        self.total_points = aDecoder.decodeObject(forKey: "total_points") as? String
        self.fb_point = aDecoder.decodeObject(forKey: "fb_point") as? String
        self.insta_point = aDecoder.decodeObject(forKey: "insta_point") as? String
        self.invite_points = aDecoder.decodeObject(forKey: "invite_points") as? String
        
        self.qr_img = aDecoder.decodeObject(forKey: "qr_img") as? String
        self.refer_Code = aDecoder.decodeObject(forKey: "refer_Code") as? String
        
        self.app_language = aDecoder.decodeObject(forKey: "app_language") as? String
        
        self.isPaypalCheckout = aDecoder.decodeObject(forKey: "isPaypalCheckout") as? String
        self.isGuestLogin = aDecoder.decodeObject(forKey: "isGuestLogin") as? String
        self.app_version = aDecoder.decodeObject(forKey: "app_version") as? String
        
    }
    
    func encode(with aCoder: NSCoder) {

        aCoder.encode(self.user_id, forKey: "user_id")
        aCoder.encode(self.authToken, forKey: "authToken")
        aCoder.encode(self.deviceToken, forKey: "deviceToken")
        
        aCoder.encode(self.firstname, forKey: "firstname")
        aCoder.encode(self.lastname, forKey: "lastname")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.profile_image, forKey: "profile_image")
        aCoder.encode(self.birthdate, forKey: "birthdate")
        aCoder.encode(self.gender, forKey: "gender")
        aCoder.encode(self.mobileNo, forKey: "mobileNo")
        aCoder.encode(self.country_code, forKey: "country_code")
        
        aCoder.encode(self.address, forKey: "address")
        aCoder.encode(self.address1, forKey: "address1")
        aCoder.encode(self.city, forKey: "city")
        aCoder.encode(self.country, forKey: "country")
        aCoder.encode(self.zipCode, forKey: "zipCode")
        
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        
        aCoder.encode(self.isCompany, forKey: "isCompany")
        aCoder.encode(self.companyId, forKey: "companyId")
        aCoder.encode(self.companyName, forKey: "companyName")
        aCoder.encode(self.companyLegalEmail, forKey: "companyLegalEmail")
        aCoder.encode(self.province, forKey: "province")
        aCoder.encode(self.uniqueInvoiceCode, forKey: "uniqueInvoiceCode")
        aCoder.encode(self.vatId, forKey: "vatId")
        
        aCoder.encode(self.newsEmailNotification, forKey: "newsEmailNotification")
        aCoder.encode(self.newsPushNotification, forKey: "newsPushNotification")
        aCoder.encode(self.orderEmailNotification, forKey: "orderEmailNotification")
        aCoder.encode(self.orderPushNotification, forKey: "orderPushNotification")
        
        aCoder.encode(self.stripeCustId, forKey: "stripeCustId")
        
        aCoder.encode(self.total_points, forKey: "total_points")
        aCoder.encode(self.fb_point, forKey: "fb_point")
        aCoder.encode(self.insta_point, forKey: "insta_point")
        aCoder.encode(self.invite_points, forKey: "invite_points")
        
        aCoder.encode(self.qr_img, forKey: "qr_img")
        aCoder.encode(self.refer_Code, forKey: "refer_Code")
        
        aCoder.encode(self.app_language, forKey: "app_language")
        aCoder.encode(self.isPaypalCheckout, forKey: "isPaypalCheckout")
        
        aCoder.encode(self.isGuestLogin, forKey: "isGuestLogin")
        aCoder.encode(self.app_version, forKey: "app_version")
        
    }
}
