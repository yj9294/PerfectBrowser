//
//  FirebaseUtil.swift
//  PerfectBrowser
//
//  Created by yangjian on 2023/4/11.
//

import Foundation
import Firebase

class FirebaseUtil: NSObject {
    static func log(event: AnaEvent, params: [String: Any]? = nil) {
        
        if event.first {
            if UserDefaults.standard.bool(forKey: event.rawValue) == true {
                return
            } else {
                UserDefaults.standard.set(true, forKey: event.rawValue)
            }
        }
        
        #if DEBUG
        #else
        Analytics.logEvent(event.rawValue, parameters: params)
        #endif
        
        NSLog("[Event] \(event.rawValue) \(params ?? [:])")
    }
    
    static func log(property: AnaProperty, value: String? = nil) {
        
        var value = value
        
        if property.first {
            if UserDefaults.standard.string(forKey: property.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: property.rawValue)!
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: property.rawValue)
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: property.rawValue)
#endif
        NSLog("[Property] \(property.rawValue) \(value ?? "")")
    }
}

enum AnaProperty: String {
    /// 設備
    case local = "ay_per"
    
    var first: Bool {
        switch self {
        case .local:
            return true
        }
    }
}

enum AnaEvent: String {
    
    var first: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }
    
    case open = "lun_per"
    case openCold = "er_per"
    case openHot = "ew_per"
    case homeShow = "eq_per"
    case navigaClick = "ws_per"
    case navigaSearch = "wa_per"
    case cleanClick = "bu_per"
    case cleanSuccess = "xian_per"
    case cleanAlert = "dd_per"
    case tabShow = "dl_per"
    case tabNew = "acv_per"
    case shareClick = "xmo_per"
    case copyClick = "qws_per"
    case webStart = "zxc_per"
    case webSuccess = "bnm_per"
}
