//
//  Constant.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 29/12/21.
//

import Foundation
import UIKit
class FileOperation: NSObject{
    override init() {
        super.init();
        
    }
    //MARK: CHECK FILE EXIST OR NOT
    func isFileExistInDocDirectory(strFolderName : String) -> Bool
    {
        let filePath = self.getDirPath(strName: strFolderName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath as String) {
            return true;
        } else {
            return false;
        }
    }
    //MARK: GET DOC FILE PATH
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getDirPath(strName : String) -> String {
        let path = self.getDocumentsDirectory();
        let filePath = String(format: "%@/%@",path,strName);
        return filePath;
    }
    //MARK: CREATE FOLDER
    func createFolderInDocDirectory(strFolderName : String) -> Bool
    {
        
        let dataPath = getDocumentsDirectory().appending("/"+strFolderName)
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath, withIntermediateDirectories: false, attributes: nil)
            return true;
        } catch  {
//            //printFolder Error : \(error.localizedDescription)");
            return false;
        }
    }
    
    //MARK:  REMOVE FILE
    func removeFile(strPath: String)
        {
            let fileManager = FileManager.default
            
            do {
                try fileManager.removeItem(atPath: strPath)
            }
            catch  {
    //            //printOoops! Something went wrong: \(error)")
            }
        }
    func removeFile(strFolderName : String)
    {
        let fileManager = FileManager.default
        let docPath = self.getDocumentsDirectory();
        let dicPath = NSString(format: "%@/%@", docPath,strFolderName)
        do {
            try fileManager.removeItem(atPath: dicPath as String)
        }
        catch  {
//            //printOoops! Something went wrong: \(error)")
        }
    }
    func removeAllImage(folderName:String)
    {
        if(self.isFileExistInDocDirectory(strFolderName: folderName) == true)
        {
            self.removeFile(strFolderName: folderName)
        }
    }
}
