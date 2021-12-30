//
//  Extension.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 29/12/21.
//

import Foundation
import UIKit
extension String {
    
    func stringByAppendingPathComponent(_ path: String) -> String {
        
        let nsSt = self as NSString
        
        return nsSt.appendingPathComponent(path)
    }
}
