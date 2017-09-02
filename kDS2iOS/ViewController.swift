//
//  ViewController.swift
//  test-kds-bug
//
//  Created by Rob on 16/08/2017.
//  Copyright © 2017 Rob. All rights reserved.
//

import UIKit
import CoreML
import Foundation
import aubio
import AVFoundation


class ViewController: UIViewController, AVAudioRecorderDelegate{

    let model = kds()
    var state = 0;
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var rec_btn: UIButton!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func rec_btn_go(_ sender: Any) {
        if audioRecorder == nil{
            print("Tapped --> ON ")
            rec_btn.setImage( UIImage.init(named: "rec_on"), for: .normal)
            //            let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
            //            plot.color = UIColor.red
            state = 1
            startRecording()
            
        } else {
            print("Tapped --> OFF ")
            rec_btn.setImage( UIImage.init(named: "rec_off"), for: .normal)
            //            let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
            //            plot.color = UIColor.blue
            state = 0
            finishRecording(success: true)
        }
    }
    
    @IBAction func btn_go(_ sender: Any) {
        ml_run()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in DispatchQueue.main.async {
                    if allowed {
                        print("Rec permisions allowed")
                    } else {
                        // failed to record!
                        print("Rec failed allowed")
                    }
                }
            }
        } catch {
            // failed to record!
            print("BIG RECORD FAIL")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func foo(arg:UnsafeMutableRawPointer) {
        print(arg)
    }
    
    @IBAction func beta_run_trans_for_rec(_ sender: Any) {
        
            let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first
            let path = NSURL(fileURLWithPath: dir!).appendingPathComponent("rec.wav")
            print(path as Any)
            
            if (path != nil) {
                let win_s:uint_t = 512
                let hop_size : uint_t = uint_t(win_s / 4)
                
                let a = new_fvec(hop_size)
                let src = new_aubio_source(path?.path, 0, hop_size)
                let n_filters:uint_t = 26
                let n_coefs:uint_t = 26
                let samplerate:uint_t = 16000
                let pv = new_aubio_pvoc(win_s, hop_size)
                let iin = new_cvec(win_s)
                let oout = new_fvec(n_coefs)
                
                let c = new_aubio_mfcc(win_s, n_filters, n_coefs, samplerate);
                
                var read: uint_t = 0
                var total_frames : uint_t = 0
                
                var dataStore = [[smpl_t]] ()
                var row = [smpl_t]()

                while (true) {
                    aubio_source_do(src, a, &read)
                    aubio_pvoc_do(pv, a, iin)
                    aubio_mfcc_do(c, iin, oout)
                    
                    if let data = fvec_get_data(oout) {
                        for j in 0..<Int(n_coefs) {
                            row.append(data[j])
                        }
                    }
                    
                    dataStore.append(row)
                    row.removeAll()
                    total_frames += read
                    if (read < hop_size) { break }
                }
                
                print("read", total_frames, "frames at", aubio_source_get_samplerate(src), "Hz")
                print(dataStore)
                
                del_aubio_source(src)
                del_fvec(a)
                del_aubio_mfcc(c)
                
                
            } else {
                print("could not find file at \(String(describing: path?.absoluteString))")
            }
        }

    func startRecording(){
        print("Starting recording")
        let audioFilename = getDocumentsDirectory().appendingPathComponent("rec.wav")
        
        let settings = [
            AVFormatIDKey : NSNumber(value: Int32(kAudioFormatLinearPCM)),
            AVSampleRateKey : NSNumber(value: Float(16000.0)),
            AVNumberOfChannelsKey : NSNumber(value: 1),
            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            print("audiorec: \(audioRecorder)")
            print("at: \(audioFilename)")
            
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        print("Stopping recording with: \(success)")
        if success {
            rec_btn.setImage( UIImage.init(named: "rec_off"), for: .normal)
        } else {
            // recording failed :(
            rec_btn.setImage( UIImage.init(named: "rec_off"), for: .normal)
        }
    }

    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
//    ###############################

    func ml_run() {
        print("ml_run")
        
        let cpu = MLPredictionOptions()
        cpu.usesCPUOnly = true
        
        let INPUT_DIMS: NSNumber = 26 //161
        let TIME_STEPS: NSNumber = 234 //131
        let BATCH_SIZE: NSNumber = 1 // use 1 for inference
        let IN_SHAPE = [BATCH_SIZE, TIME_STEPS, INPUT_DIMS]
        
        let OUT_DIMS: NSNumber = 29 // 29 characters is default


        //set this batchsize x 234 x 26
        guard let input_data = try? MLMultiArray(shape:IN_SHAPE, dataType:MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        var arrayOfStrings0: [String]?
        var myDouble: Double?

        do {
            if let path = Bundle.main.path(forResource: "test_mfcc_0", ofType: "csv"){
                let data0 = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                arrayOfStrings0 = data0.components(separatedBy: "\n")
            }
        } catch let err as NSError {
            print(err)
        }
        
        //loop through array of strings and build MLMultiArray
        for (r_ind,rows) in (arrayOfStrings0?.enumerated())! {
            for (c_ind,cols) in (rows.components(separatedBy: ",").enumerated()){
                myDouble = Double(cols)
                if myDouble != nil{
                    let x = 0
                    let b = x as NSNumber
                    let r = r_ind as NSNumber
                    let c = c_ind as NSNumber
                    input_data[[b, r, c]] = NSNumber(value: myDouble!)
                }
            }
        }
        
        //print out all values to make sure it's correct
        for r_ind in 0..<Int(truncating: TIME_STEPS){
            for c_ind in 0..<Int(truncating: INPUT_DIMS){
                let x = 0
                let b = x as NSNumber
                let r = r_ind as NSNumber
                let c = c_ind as NSNumber
                print(r_ind, c_ind, input_data[[b, r, c]])
                //these seem to print out okay
            }
        }

        print(input_data) //Double 1 x 234 x 26 array
        let c = kdsInput(input1: input_data)
        guard let kdsOutput = try? model.optpredict(from: c, options: cpu) else {
            fatalError("Unexpected runtime error.")
        }
        
        // uncomment these 3 lines to ensure that GPU is used on device. Note this currently breaks with DS1
        // see: https://forums.developer.apple.com/thread/84966
//        guard let kdsOutput = try? model.prediction(input: c) else {
//            fatalError("Unexpected runtime error.")
//        }

        let o = kdsOutput.output1
        //Double 234 x 29 matrix
        var dblarr = [Double]()
        var output = String()
        
        for r_ind in 0..<Int(truncating: TIME_STEPS){
            dblarr.removeAll()
            for c_ind in 0..<Int(truncating: OUT_DIMS){
                let r = r_ind as NSNumber
                let c = c_ind as NSNumber
                dblarr.append(Double(truncating: o[[r, c]]))
            }
            output.append(argMaxDecode(t: dblarr))
        }
        
        print("raw output:", output)
        output = removeConsecRepeated(str: output)
        print("merge out:", output)
        label.text = output
    }
}

