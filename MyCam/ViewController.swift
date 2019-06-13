//
//  ViewController.swift
//  MyCam
//
//  Created by Harshit Jindal on 12/06/19.
//  Copyright © 2019 Harshit Jindal. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var takePhoto = false
    var ISOValues:[Float]!
    var exposureIndex:Int = 0
    
    var images:[UIImage] = [UIImage]()
    
    var captureDevice:AVCaptureDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        
        // Calculating Exposure Ranges
        let calcISOValues = calculateExposureRange()
        ISOValues = calcISOValues
        beginSession()
    }
    
    func beginSession() {
        do {
            let cameraDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(cameraDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
            
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "clockworksciencce")
        dataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
//        for ISO in ISOValues {
//            changeExposure(isoVal: ISO)
//            print("take photo = true")
//            self.takePhoto = true
//        }
//
//        stopCaptureSession()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        //        let savedImageSelector = Selector(("imageWasSavedSuccessfully:didFinishSavingWithError:context:"))
        
        
        for capture in images {
            UIImageWriteToSavedPhotosAlbum(capture, self, nil, nil)
        }
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto == true && exposureIndex < 9 {
            var ISO = ISOValues[exposureIndex]
            exposureIndex += 1
            changeExposure(isoVal: ISO)
            print("Exposure changed to \(ISO)")
            
            if var capture = getImageFromSampleBuffer(buffer: sampleBuffer){
                usleep(100)
                images.append(capture)
            }
            
        } else if exposureIndex >= 9 {
            
            
            takePhoto = false
            stopCaptureSession()
            
            
        }
        
        //            takePhoto = false
        
        //            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
        //                images.append(image)
        
        
        
        
        //                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoVC") as! PhotoViewController
        //
        //                photoVC.takenPhoto = image
        //
        //                DispatchQueue.main.async {
        //                    self.present(photoVC, animated: true, completion: {
        //                        self.stopCaptureSession()
        //                    })
        //
    }
    
    
    
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right )
            }
        }
        return nil  //if it doesn't work return a nil
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    func calculateExposureRange() -> [Float]{
        // Determine ISO Range
        let activeFormat = captureDevice.activeFormat
        print("Min ISO: \(activeFormat.minISO) & Max ISO: \(activeFormat.maxISO)")
        let minISO = activeFormat.minISO
        let maxISO = activeFormat.maxISO
        
        // Generate Exposure Array
        let ISOStepSize:Float = Float(maxISO - minISO)/8
        var ISOValues:[Float] = [minISO]
        for i in 0 ... 7 {
            ISOValues.append(ISOValues[i] + ISOStepSize)
        }
        print(ISOValues)
        return(ISOValues)
    }
    
    
    func changeExposure(isoVal: Float) {
        //MARK: SET CUSTOM EXPOSURE
        do {
            // Lock Camera Configuration
            try captureDevice.lockForConfiguration()
            
            // Modify CAM Parameters
            let CMTime = AVCaptureDevice.currentExposureDuration
            captureDevice.setExposureModeCustom(duration: CMTime, iso: isoVal) { (CMTime) in
                AVCaptureDevice.ExposureMode.custom
            }
            
            // Unlock Camera Configuration
            captureDevice.unlockForConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
