//
//  VideoPlayVC.swift
//  VideoRecordingDemo
//
//  Created by imobdev on 29/12/21.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
let videoUrl = URL(string: "https://v.cdn.vine.co/r/videos/AA3C120C521177175800441692160_38f2cbd1ffb.1.5.13763579289575020226.mp4")!
class VideoPlayVC: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var AttributesView: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var CameraView: UIView!
    //MARK: - variables
    var arrMediaSelect = [MediaSelect]()
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    var isPlay = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    //MARK: - Local methods
    private func setupView(){
        CameraView.layer.cornerRadius = 10
        CameraView.clipsToBounds = true
        initializeVideoPlayerWithVideo()
    }
    func initializeVideoPlayerWithVideo() {

            // get the path string for the video from assets
            let videoString:String? = Bundle.main.path(forResource: "SampleVideo_360x240_1mb", ofType: "mp4")
            guard let unwrappedVideoPath = videoString else {return}
            let strURL = arrMediaSelect.last?.pathOfMedia
        print("unwrappedVideoPath",unwrappedVideoPath)
            // convert the path string to a url
        let videoUrl = URL(fileURLWithPath: strURL ?? "")

        // initialize the video player with the url
        self.player = AVPlayer(url: videoUrl)

        // create a video layer for the player
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)

        // make the layer the same size as the container view
        layer.frame = CameraView.bounds

        // make the video fill the layer as much as possible while keeping its aspect size
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // add the layer to the container view
        CameraView.layer.addSublayer(layer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        self.view.bringSubviewToFront(AttributesView)
        
        let strDuration = getDuration()
        self.lblDuration.text = strDuration
        
    }
    private func getDuration() -> String{
        let VideoData = arrMediaSelect.last
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = documentDirectory[0].appendingPathComponent("video_community").appendingPathComponent("\(VideoData?.videoFileName ?? "")")
//        let videoURL = documentDirectory.appendingPathComponent([filePath])
        let duration = AVURLAsset(url: filePath).duration.seconds
            print(duration)
        let time: String
        if duration > 3600 {
            time = String(format:"%dh %dm %ds",
                Int(duration/3600),
                Int((duration/60).truncatingRemainder(dividingBy: 60)),
                Int(duration.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%d:%d",
                Int((duration/60).truncatingRemainder(dividingBy: 60)),
                Int(duration.truncatingRemainder(dividingBy: 60)))
        }
        print(time)
        return time
    }
    //MARK: - All Actions
    @IBAction func btnBack_Pressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnPlayPause_Pressed(_ sender: UIButton) {
        if isPlay{
            self.player.pause()
            self.btnPlayPause.setImage(UIImage(named: "play_ic"), for: .normal)
        }else{
            self.player.play()
            self.btnPlayPause.setImage(UIImage(named: "pause_ic"), for: .normal)
        }
    }
    
    @IBAction func btnReRecord_Pressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecordingVC") as! RecordingVC
        vc.arrMediaSelect = self.arrMediaSelect
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btn_Submit(_ sender: UIButton) {
        registerDataUploadAPI()
//        uploadInBackground()
    }
    // call when video is over
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        isPlay = false
        self.btnPlayPause.setImage(UIImage(named: "play_ic"), for: .normal)
    }
}
//MARK: - API Calling
extension VideoPlayVC{
    
    func registerDataUploadAPI(){
        let parameters = [:] as [String : Any]
        print(parameters)
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 1000//Increase time interval
        LoadingOverlay.shared.showOverlay(view: self.view)
        if Connectivity.isConnectedToInternet {
            
            let headers: HTTPHeaders =  ["Accept-Language":"en"]
            
            let VideoData = arrMediaSelect.last
            let paths123 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let filePath = paths123[0].appendingPathComponent("video_community").appendingPathComponent("\(VideoData?.videoFileName ?? "")")
//            let filePath = URL(string: VideoData?.pathOfMedia ?? "") ?? URL(string: "")
            print(VideoData?.pathOfMedia ?? "")
            print(filePath)
            do{
                let SampleZipFile = try Data(contentsOf: filePath)//
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(SampleZipFile, withName: "video", fileName: VideoData?.videoFileName ?? "", mimeType: "video/mp4")
                    for (key, value) in parameters {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                    }
                }, usingThreshold: UInt64.init(), to:"http://111.118.214.237:4050/v4/unAuthRoutes/videoUpload", method: .post, headers: headers) { (result) in
                    switch result{
                    case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (progress) in
                            //Print progress
                            let value =  Int(progress.fractionCompleted * 100)
                            print("\(value) %")
                        })
                        upload.responseJSON { response in
                            LoadingOverlay.shared.hideOverlayView()
                            print(response.result.value)
                            guard let dictData =  response.result.value as? NSDictionary else {return}
//                            print(dictData)
                            
                        }
                    case .failure(let error):
                        LoadingOverlay.shared.hideOverlayView()
                        print("Error in upload: \(error.localizedDescription)")
                        self.showToast(message: error.localizedDescription, fontSize: 20)
                    }
                }
            }
            catch{
                LoadingOverlay.shared.hideOverlayView()
                print("errot to get data")
                showToast(message: "video not exist", fontSize: 20)
            }
            
        }else{
            LoadingOverlay.shared.hideOverlayView()
            showToast(message: "Pleae check your internet connection", fontSize: 20)
        }
    }
    func uploadInBackground() {
            let headers: [String : String] = [ "Authorization": "key"]
        LoadingOverlay.shared.showOverlay(view: self.view)
        let VideoData = arrMediaSelect.last
        let paths123 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filePath = paths123[0].appendingPathComponent("video_community").appendingPathComponent("\(VideoData?.videoFileName ?? "")")
            do{
                let fileInData = try Data(contentsOf: filePath)
                Networking.sharedInstance.backgroundSessionManager.upload(multipartFormData: { (multipartFormData) in
                    multipartFormData.append(fileInData, withName: "video", mimeType: "video/mp4")

                }, usingThreshold: UInt64.init(), to: "http://111.118.214.237:4050/v4/unAuthRoutes/videoUpload", method: .post, headers: headers)
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        LoadingOverlay.shared.hideOverlayView()
                        upload.uploadProgress(closure: { (progress) in
                            //Print progress
                            let value =  Int(progress.fractionCompleted * 100)
                            print("\(value) %")
                        })
                        print(upload.response?.statusCode)
                        upload.responseJSON { response in
                            //print response.result
                            print(response.description)
                            let res = response.response?.statusCode
                            print(res)
                        }
                        
                    case .failure(let encodingError):
                        //print encodingError.description
                        LoadingOverlay.shared.hideOverlayView()
                        print(encodingError.localizedDescription)
                    }
                }
            }catch{
                LoadingOverlay.shared.hideOverlayView()
                print("errot to get data")
                showToast(message: "video not exist", fontSize: 20)
            }
        }
}

