//
//  CameraConfigration.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 29/12/21.
//

import Foundation
import UIKit
import Alamofire
extension UIViewController {
    
    func showToast(message : String, fontSize: CGFloat) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-self.view.frame.size.height/2 + 17.5, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.black
        toastLabel.font = UIFont.systemFont(ofSize: fontSize)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
