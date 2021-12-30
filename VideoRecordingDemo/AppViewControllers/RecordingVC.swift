//
//  RecordingVC.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 29/12/21.
//

import UIKit
import Photos
import MediaWatermark
class RecordingVC: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var TimerBGView: UIView!
    @IBOutlet weak var btnStartStop: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var MainCameraView: UIView!
    @IBOutlet weak var imgRedDot: UIImageView!
    //MARK: - Variables
    var cameraConfig: CameraConfiguration!
    var timer: Timer!
    var TotalTime : Int = 120
    var startTime = 0
    var folderPathVideo = "video_community"//"videos"
    var arrMediaSelect = [MediaSelect]()
    var videoRecordingStarted: Bool = false {
        didSet{
            if videoRecordingStarted {
//                self.cameraButton.backgroundColor = UIColor.red
                self.btnStartStop.setImage(UIImage(named: "start_ic"), for: .normal)
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
            } else {
//                self.cameraButton.backgroundColor = UIColor.white
                self.btnStartStop.setImage(UIImage(named: "record_ic"), for: .normal)
                timer?.invalidate()
                timer = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVuiew()
    }

    //MARK: - Local functions
    private func setupVuiew(){
        self.cameraConfig = CameraConfiguration()
        cameraConfig.setup { (error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            try? self.cameraConfig.displayPreview(self.MainCameraView)
        }
        imgRedDot.layer.cornerRadius = imgRedDot.bounds.height / 2
        imgRedDot.clipsToBounds = true
        lblTimer.text = "00:00"
        TimerBGView.layer.cornerRadius = 15
        removeAllFiles()
    }
    //Remove & add folder
    fileprivate func removeAllFiles() {
        
        let fileOperation = FileOperation.init()
        fileOperation.removeAllImage(folderName: self.folderPathVideo)
        self.folderPathVideo = "video_community"//"videos"
        if !fileOperation.isFileExistInDocDirectory(strFolderName: folderPathVideo) {
            let isCreate = fileOperation.createFolderInDocDirectory(strFolderName: self.folderPathVideo)
            if isCreate == false{
                fatalError()
            }
        }
    }
    // handle timer of recoding
    @objc func onTimerFires() {
        startTime += 1
        if startTime == TotalTime{
            timer?.invalidate()
            timer = nil
        }
        if startTime >= 60{
            if startTime <= 69{
                self.lblTimer.text = "01:0\(startTime - 60)"
            }else{
                self.lblTimer.text = "01:\(startTime)"
            }
        }else{
            if startTime <= 9{
                self.lblTimer.text = "00:0\(startTime)"
            }else{
                self.lblTimer.text = "00:\(startTime)"
            }
        }
    }
    
    @objc fileprivate func showToastForSaved() {
        showToast(message: "Saved!", fontSize: 12.0)
    }
    
    @objc fileprivate func showToastForRecordingStopped() {
        showToast(message: "Recording Stopped", fontSize: 12.0)
    }
    @objc func video(_ video: String, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showToast(message: "Could not save!! \n\(error)", fontSize: 12)
        } else {
            showToast(message: "Saved", fontSize: 12.0)
        }
        print(video)
    }
    @IBAction func btnStartStop_Pressed(_ sender: UIButton) {
        if videoRecordingStarted {
            videoRecordingStarted = false
            self.cameraConfig.stopRecording { (error) in
                print(error ?? "Video recording error")
            }
        } else if !videoRecordingStarted {
            videoRecordingStarted = true
            self.cameraConfig.recordVideo { (url, error) in
                guard let url = url else {
                    print(error ?? "Video recording error")
                    return
                }
                print(url)
                // for save video into Galery
//                UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(self.video(_:didFinishSavingWithError:contextInfo:)), nil)
                do
                {
                    let videoData = try Data(contentsOf: url.absoluteURL, options: .alwaysMapped)
                    
                    let fileOperation = FileOperation.init()
                    var documentPath = fileOperation.getDocumentsDirectory()
                    let timestamp = NSDate().timeIntervalSince1970
                    let intTimeStamp = Int(timestamp)
                    documentPath =  documentPath.stringByAppendingPathComponent(self.folderPathVideo)
                    let fullPath : String = documentPath.appending("/\("video")\(intTimeStamp)\(".mp4")");
                    print(fullPath)
                    try? videoData.write(to: URL(fileURLWithPath: fullPath), options: [])
                    
                    self.arrMediaSelect.append(MediaSelect( videoFileName: "\("video")\(intTimeStamp).mp4", pathOfMedia: fullPath))
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoPlayVC") as! VideoPlayVC
                    vc.arrMediaSelect = self.arrMediaSelect
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                catch
                {
                    print(error)
                }
            }
            
        }
    }
}
//MARK: - WaterMark Code
extension RecordingVC{
    func processVideo(url: URL) {
        
        if let item = MediaItem(url: url) {
            // create attributed string
            let myString = "Creditt"
            let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25) ]
            let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
            
            let WaterMark = MediaElement(text: myAttrString)
            WaterMark.frame = CGRect(x: 150, y: 150, width: 200, height: 50)
            
            item.add(elements: [WaterMark])
            
            let mediaProcessor = MediaProcessor()
            mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                DispatchQueue.main.async {
//                    self?.playVideo(url: result.processedUrl!, view: (self?.resultImageView)!)
                }
            }
        }
    }
}
//MARK: - Model get Video
struct MediaSelect {
    var videoFileName: String?
    var pathOfMedia: String?
}
