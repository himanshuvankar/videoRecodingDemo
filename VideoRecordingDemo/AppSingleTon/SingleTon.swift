//
//  SingleTon.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 30/12/21.
//

import Foundation
import UIKit
import Alamofire
public class LoadingOverlay{

var overlayView = UIView()
var activityIndicator = UIActivityIndicatorView()

class var shared: LoadingOverlay {
    struct Static {
        static let instance: LoadingOverlay = LoadingOverlay()
    }
    return Static.instance
}

    public func showOverlay(view: UIView) {

        overlayView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        overlayView.center = view.center
        overlayView.backgroundColor = UIColor(white: 0x444444, alpha: 0.7)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10

        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.style = .whiteLarge
        activityIndicator.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)

        overlayView.addSubview(activityIndicator)
        view.addSubview(overlayView)

        activityIndicator.startAnimating()
    }

    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
}
class Networking {
    static let sharedInstance = Networking()
    public var sessionManager: Alamofire.SessionManager // most of your web service clients will call through sessionManager
    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
    private init() {
        let defaultConfig = URLSessionConfiguration.default
        defaultConfig.timeoutIntervalForRequest = 500
        
        
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "com.lava.app.backgroundtransfer")
        backgroundConfig.timeoutIntervalForRequest = 500
        
//        self.sessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
        self.sessionManager = Alamofire.SessionManager(configuration: defaultConfig)
        self.backgroundSessionManager = Alamofire.SessionManager(configuration: backgroundConfig)
        
    }
}
