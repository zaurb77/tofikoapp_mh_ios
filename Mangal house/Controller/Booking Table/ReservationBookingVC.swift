//
//  ReservationBookingVC.swift
//  Mangal house
//
//  Created by Mahajan on 24/08/21.
//  Copyright © 2021 Almighty Infotech. All rights reserved.
//

import UIKit
import CVCalendar
import KMPlaceholderTextView

protocol BookingComplete : NSObjectProtocol{
    func resvervationComplete()
}

class TimeCell : UICollectionViewCell{
    @IBOutlet weak var vwBack: CustomUIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDis: UILabel!
    @IBOutlet weak var lblSeatsAvail: UILabel!
}

class GuestCell : UICollectionViewCell{
    @IBOutlet weak var vwBack: CustomUIView!
    @IBOutlet weak var lblNo: UILabel!
}

class ReservationBookingVC: Main {
    
    @IBOutlet weak var vwCalender: CVCalendarView!
    @IBOutlet weak var lblMonth: UILabel!
    
    private var currentCalendar: Calendar?
    
    @IBOutlet weak var consCalenderHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwTimeSlot: NSLayoutConstraint!
    @IBOutlet weak var consVwGuestHeight: NSLayoutConstraint!
    @IBOutlet weak var consVwSpecialRequestHeight: NSLayoutConstraint! // 200
    @IBOutlet weak var consBtnBookingHeight: NSLayoutConstraint! // 60
    @IBOutlet weak var cvLunch: UICollectionView!
    @IBOutlet weak var cvDinner: UICollectionView!
    @IBOutlet weak var cvGuest: UICollectionView!
    @IBOutlet weak var vwMonth: CustomUIView!
    @IBOutlet weak var vwTime: CustomUIView!
    @IBOutlet weak var vwMember: CustomUIView!
    @IBOutlet weak var btnApplyBooking: CustomButton!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var lblChooseTime: UILabel!
    @IBOutlet weak var lblLunch: UILabel!
    @IBOutlet weak var lblDinner: UILabel!
    @IBOutlet weak var lblNumberOfGuest: UILabel!
    @IBOutlet weak var lblSpecialRequest: UILabel!
    @IBOutlet weak var tvSpecialRequest: KMPlaceholderTextView!
    @IBOutlet weak var consCVLunchHeight: NSLayoutConstraint!
    @IBOutlet weak var consCVDinnerHeight: NSLayoutConstraint!
    
    var currentType = "calender"
    var storeID = ""
    var arrDictSlot = [[String:AnyObject]]()
    var arrEveningSlot = [[String:AnyObject]]()
    var arrMorningSlot = [[String:AnyObject]]()
    var member_capacity = ""
    
    weak var reservationDelegate : BookingComplete?
    
    var selectedDate = ""
    var selectedTime = ""
    var selectedMember = ""
    var selectedSlotAvailableSeats = 0
    
    var lightGolden = UIColor(red: 212/255, green: 171/255, blue: 92/255, alpha: 0.4)
    var darkGolden = UIColor(red: 212/255, green: 171/255, blue: 92/255, alpha: 1.0).cgColor
    
    static func instantiate() -> ReservationBookingVC? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReservationBookingVC") as? ReservationBookingVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tvSpecialRequest.layer.borderColor = UIColor.lightGray.cgColor
        tvSpecialRequest.layer.borderWidth = 1
        tvSpecialRequest.layer.cornerRadius = 10
        
        tvSpecialRequest.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        let timeZoneBias = 480 // (UTC+08:00)
        currentCalendar = Calendar(identifier: .gregorian)
        currentCalendar?.locale = Locale(identifier: "en_EN")
        if let timeZone = TimeZone(secondsFromGMT: -timeZoneBias * 60) {
            currentCalendar?.timeZone = timeZone
        }
        
        if let currentCalendar = currentCalendar {
            lblMonth.text = CVDate(date: Date(), calendar: currentCalendar).globalDescription
        }
        
        calenderSelect()
        callGetSlotByDate()
        
        selectedDate = convertStringFrom(date: Date(), format: "yyyy-MM-dd")
        
        lblChooseTime.text = Language.CHOOSE_YOUR_TIME
        lblNumberOfGuest.text = Language.NUMBER_OF_GUEST
        lblDinner.text = Language.DINNER
        lblLunch.text = Language.LUNCH
        lblSpecialRequest.text = Language.SPECIAL_REQ
        tvSpecialRequest.placeholder = Language.WRITE_SPECIAL_REQ
        btnApplyBooking.setTitle(Language.SET_BOOKING, for: .normal)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        vwCalender.commitCalendarViewUpdate()
        vwCalender.changeDaysOutShowingState(shouldShow: true)
    }
    
    func calenderSelect(){
        currentType = "calender"
        self.consCalenderHeight.constant = 405
        self.consVwTimeSlot.constant = 0.0
        self.consVwGuestHeight.constant = 0.0
        self.selectedDate = ""
        self.selectedTime = ""
        self.consVwSpecialRequestHeight.constant = 0.0
        self.consBtnBookingHeight.constant = 0.0
        self.selectedSlotAvailableSeats = 0
        vwMonth.layer.backgroundColor = darkGolden
        vwTime.layer.backgroundColor = lightGolden.cgColor
        vwMember.layer.backgroundColor = lightGolden.cgColor
    }
    
    func timeSlotSelect(){
        currentType = "time"
        self.consCalenderHeight.constant = 0.0
        self.consVwTimeSlot.constant = 600.0
        self.consVwGuestHeight.constant = 0.0
        self.selectedTime = ""
        self.consVwSpecialRequestHeight.constant = 0.0
        self.consBtnBookingHeight.constant = 0.0
        self.selectedSlotAvailableSeats = 0
        vwMonth.layer.backgroundColor = darkGolden
        vwTime.layer.backgroundColor = darkGolden
        vwMember.layer.backgroundColor = lightGolden.cgColor
        cvLunch.reloadData()
        cvDinner.reloadData()
    }
    
    func guestMember(){
        currentType = "member"
        self.consCalenderHeight.constant = 0.0
        self.consVwTimeSlot.constant = 0.0
        self.consVwGuestHeight.constant = 400.0
        self.consVwSpecialRequestHeight.constant = 0.0
        self.consBtnBookingHeight.constant = 0.0
        self.selectedSlotAvailableSeats = 0
        vwMonth.layer.backgroundColor = darkGolden
        vwTime.layer.backgroundColor = darkGolden
        vwMember.layer.backgroundColor = darkGolden
        cvGuest.reloadData()
    }
    
    func specialRequest() {
        currentType = "special_request"
        self.consCalenderHeight.constant = 0.0
        self.consVwTimeSlot.constant = 0.0
        self.consVwGuestHeight.constant = 0.0
        self.consVwSpecialRequestHeight.constant = 200.0
        self.consBtnBookingHeight.constant = 60.0
        self.selectedSlotAvailableSeats = 0
    }
    
    @IBAction func btnCalender_Action(_ sender: UIButton) {
        calenderSelect()
    }
    
    @IBAction func btnTimeSlot_Action(_ sender: UIButton) {
        if arrEveningSlot.count > 0 || arrMorningSlot.count > 0{
            timeSlotSelect()
        }
    }
    
    @IBAction func btnGuestMember_Action(_ sender: UIButton) {
        if selectedMember != ""{
            guestMember()
        }
    }
    
    @IBAction func btnApplyBooking_Action(_ sender: UIButton) {
        if selectedDate == ""{
            calenderSelect()
        }else if selectedTime == ""{
            timeSlotSelect()
        }else if selectedMember == ""{
            guestMember()
        }else{
            callApplyBooking()
        }
    }
    
    func callGetSlotByDate() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.GET_SLOT_BY_DATE
        let params = "?store_id=\(storeID)&lang_id=\(UserModel.sharedInstance().app_language!)"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String {
                    if status == "0" {
                        print("Failed")
                    }else {
                        print(jsonObject)
                        if let data = jsonObject["responsedata"]  as? [[String:AnyObject]], data.count > 0{
                            self.arrDictSlot = data
                        }
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }
    
    func callApplyBooking() {
        
        //Checking for internet connection. If internet is not available then system will display toast message.
        guard NetworkManager.shared.isConnectedToNetwork() else {
            self.showWarning(Language.CHECK_INTERNET)
            return
        }
        
        //Creating API request to fetch the data.
        let serviceURL = Constant.WEBURL + Constant.API.BOOK_TABLE
        let params = "?store_id=\(storeID)&lang_id=\(UserModel.sharedInstance().app_language!)&user_id=\(UserModel.sharedInstance().user_id!)&auth_token=\(UserModel.sharedInstance().authToken!)&date=\(selectedDate)&time=\(selectedTime)&guests=\(selectedMember)&notes=\(tvSpecialRequest.text ?? "")"
        
        //Starting process to fetch the data and store default login data.
        APIManager.shared.requestGETURL(serviceURL + params, success: { (response) in
            
            //Parsing method started to parse the data.
            if let jsonObject = response.result.value as? [String:AnyObject] {
                CommonFunctions().hideLoader()
                if let status = jsonObject["status"] as? String{
                    if status == "0"{
                        print("Failed")
                    }else{
                        print(jsonObject)
                        self.dismiss(animated: true, completion: nil)
                        self.reservationDelegate?.resvervationComplete()
                    }
                }
            }
        }) { (error) in
            print(error)
        }
    }

}

extension UINavigationController {
    func popToViewController1(ofClass: AnyClass, animated: Bool = true) {
        if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(vc, animated: animated)
        }
    }
}

extension ReservationBookingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cvLunch{
            return arrMorningSlot.count
        }else if collectionView == cvDinner{
            return arrEveningSlot.count
        }else{
            return Int(member_capacity) ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == cvLunch{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCell
            let data = (arrMorningSlot[indexPath.row])
            
            cell.lblTime.text = data["time"] as? String
            
            if let dis = data["discount"] as? String, dis != ""{
                cell.lblDis.text = dis
                cell.lblDis.isHidden = false
            }else{
                cell.lblDis.text = ""
                cell.lblDis.isHidden = true
            }
            
            if selectedTime == data["time"] as! String{
                cell.vwBack.backgroundColor = lightGolden
            }else{
                cell.vwBack.backgroundColor = .white
            }
            let seats = data["available_capacity"] as! String
            let seats_left = Language.SEATS_LEFT
            cell.lblSeatsAvail.text = "\(seats) \(seats_left)"
            
            return cell
        }else if collectionView == cvDinner{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCell", for: indexPath) as! TimeCell
            let data = (arrEveningSlot[indexPath.row])
            
            cell.lblTime.text = data["time"] as? String
            if let dis = data["discount"] as? String, dis != ""{
                cell.lblDis.text = dis
                cell.lblDis.isHidden = false
            }else{
                cell.lblDis.text = ""
                cell.lblDis.isHidden = true
            }
            
            if selectedTime == data["time"] as! String{
                cell.vwBack.backgroundColor = lightGolden
            }else{
                cell.vwBack.backgroundColor = .white
            }
            
            let seats = data["available_capacity"] as! String
            let seats_left = Language.SEATS_LEFT
            cell.lblSeatsAvail.text = "\(seats) \(seats_left)"
            
            
            
            
            return cell
        }else{
            let cellGuest = collectionView.dequeueReusableCell(withReuseIdentifier: "GuestCell", for: indexPath) as! GuestCell
            
            if selectedMember == "\(indexPath.row + 1)"{
                cellGuest.vwBack.backgroundColor = lightGolden
            }else{
                cellGuest.vwBack.backgroundColor = .white
            }
            
            cellGuest.lblNo.text = "\(indexPath.row + 1)"
            
            return cellGuest
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.size.width - 5) / 3
        if collectionView == cvLunch || collectionView == cvDinner{
            return CGSize(width: width, height: width + 5)
        }else{
            return CGSize(width: width, height: width - 40)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == cvLunch{
            self.selectedTime = (arrMorningSlot[indexPath.row])["time"] as! String
            if let dict = arrMorningSlot[indexPath.row] as? [String:AnyObject]{
                self.selectedSlotAvailableSeats = Int(dict["available_capacity"] as! String) ?? 0
            }
            self.guestMember()
            self.cvLunch.reloadData()
        }else if collectionView == cvDinner{
            self.selectedTime = (arrEveningSlot[indexPath.row])["time"] as! String
            if let dict = arrEveningSlot[indexPath.row] as? [String:AnyObject]{
                self.selectedSlotAvailableSeats = Int(dict["available_capacity"] as! String) ?? 0
            }
            self.guestMember()
            self.cvDinner.reloadData()
        }else{
            
            if self.selectedSlotAvailableSeats <= (indexPath.row + 1){
                self.selectedMember = "\(indexPath.row + 1)"
                self.specialRequest()
                self.cvGuest.reloadData()
            }
        }
    }
    
}

extension ReservationBookingVC: CVCalendarViewAppearanceDelegate, MenuViewDelegate {
    func dayOfWeekFont() -> UIFont {
        return UIFont(name: "Raleway-SemiBold", size: 10.0)!
    }
    
    func dayLabelWeekdayFont() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 12.0)!
    }
    
    func dayLabelWeekdaySelectedFont() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 12.0)!
    }
    
    func dayOfWeekTextColor() -> UIColor {
        return .darkGray
    }
    
    func dayLabelWeekdayInTextColor() -> UIColor {
        return .darkGray
    }
    
    func dayLabelWeekdaySelectedTextColor() -> UIColor {
        return .darkGray
    }
    
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
    }
    
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor {
        return UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
    }
    
    func dayLabelPresentWeekdaySelectedTextColor() -> UIColor {
        return .darkGray
    }
    
    func dayLabelPresentWeekdaySelectedFont() -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 12.0)!
    }
    
    func dayLabelPresentWeekdaySelectedTextSize() -> CGFloat {
        return 12.0
    }
            
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        if status == .disabled {
            return .darkGray
        }else if status == .selected {
            return .darkGray
        }else {
            return .darkGray
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        return AppColors.golden
    }
      
    func dayLabelSize(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> CGFloat {
        return 12.0
    }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        return UIFont(name: "Raleway-Bold", size: 12.0)!
    }
         
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView {
        //let vw = UIView(frame: CGRect(x: dayView.frame.origin.x + 5.0, y: dayView.frame.origin.y + 8.0, width: dayView.frame.size.width - 10.0, height: dayView.frame.size.height - 10.0))
        let vw = UIView(frame: CGRect(x: dayView.frame.origin.x + 5.0, y: dayView.frame.origin.y + 8.0, width: 35, height: 35))
        
        vw.layer.cornerRadius = 8
        vw.clipsToBounds = true
        
        if dayView.isDisabled {
            vw.backgroundColor = .lightGray
        }else if dayView.isHighlighted {
            vw.backgroundColor = AppColors.golden
        }else if dayView.isCurrentDay {
            vw.backgroundColor = AppColors.golden
        }else {
            vw.backgroundColor = .white
        }
        
        return vw
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool {
        return true
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 5.0
    }
}


extension ReservationBookingVC: CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        .monthView
    }
    
    func firstWeekday() -> Weekday {
        .monday
    }
    
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
        
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    func shouldSelectRange() -> Bool {
        return false
    }
    
    func shouldSelectDayView(_ dayView: DayView) -> Bool {
//      let displayDate = convertStringFrom(date: dayView.date.convertedDate()!, format: "yyyy-MM-dd")
//      dayView.layer.cornerRadius = dayView.frame.height / 2
//      if Calendar.current.compare(dayView.date.convertedDate()!, to: Date(), toGranularity: .day) == .orderedAscending {
//          return false
//      }else if arrDisableDates.contains(displayDate) {
//          return false
//      }else {
//          return true
//      }
        return true
    }
        
    func didSelectDayView(_ dayView: DayView, animationDidFinish: Bool) {
        let date = convertStringFrom(date: dayView.date.convertedDate()!, format: "yyyy-MM-dd")
        selectedDate = date
        print("Slot Selected")
        if arrDictSlot.count > 0{
            print("Slot Available")
            if let data = arrDictSlot.filter({$0["date"] as? String == date}) as? [[String:AnyObject]], data.count > 0{
                if let selectedDate = data[0] as? [String:AnyObject], !selectedDate.isEmpty{
                    if let arrMorning = selectedDate["morning"] as? [[String:AnyObject]], arrMorning.count > 0{
                        self.arrMorningSlot = arrMorning
                        self.cvLunch.reloadData()
                        self.timeSlotSelect()
                        self.consCVLunchHeight.constant = 220
                        lblLunch.text = Language.LUNCH
                    }else{
                        self.consCVLunchHeight.constant = 0
                        lblLunch.text = ""
                    }
                    
                    if let arrEvening = selectedDate["evening"] as? [[String:AnyObject]], arrEvening.count > 0{
                        self.arrEveningSlot = arrEvening
                        self.cvDinner.reloadData()
                        self.timeSlotSelect()
                        self.consCVDinnerHeight.constant = 220
                        lblDinner.text = Language.DINNER
                    }else{
                        self.consCVDinnerHeight.constant = 0
                        lblDinner.text = ""
                    }
                    
                }
            }
            
        }else{
            print("NO Slot Available")
            self.showError("No slot available for booking")
        }
        
    }
    
    func presentedDateUpdated(_ date: CVDate) {
        let date = convertStringFrom(date: date.convertedDate()!, format: "yyyy-MM-dd")
    }
    
    func disableScrollingBeforeDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    func earliestSelectableDate() -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    
    func didShowNextMonthView(_ date: Date) {
//        lblMonth.text = convertStringFrom(date: date, format: "MMMM yyyy")
//        checkLeftButton(selectedDate: date)
    }
    
    func didShowPreviousMonthView(_ date: Date) {
//        lblMonth.text = convertStringFrom(date: date, format: "MMMM yyyy")
//        checkLeftButton(selectedDate: date)
    }
    
    func checkLeftButton(selectedDate : Date) {
//        if selectedDate < Date() {
//            btnLeft.isUserInteractionEnabled = false
//        }else {
//            btnLeft.isUserInteractionEnabled = true
//        }
    }
}
