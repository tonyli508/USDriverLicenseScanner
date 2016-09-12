//
//  ScanDriverLicenseViewController.swift
//  Ridepool
//
//  Created by Li Jiantang on 07/05/2015.
//  Copyright (c) 2015 Carma. All rights reserved.
//

import UIKit
import AVFoundation

/// callback with driver license details after scanned
public protocol ScanDriverLicenseViewControllerDelegate: class {
    func didScanResult(driverInfo: DriverLicense)
}

public class ScanDriverLicenseViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var boundLayer = ScanBoundaryView()
    private lazy var session = AVCaptureSession()
    private var sessionStopped = false
    private var container = UIView()
    public weak var delegate: ScanDriverLicenseViewControllerDelegate?
    
    /// focus desc, expose for change font and style
    public let lblFocusDesc = UILabel(frame: CGRectZero)
    /// scan detail desc, expose for change font and style
    public let lblScanDesc = UILabel(frame: CGRectZero)
    
    /// set title
    public var titleString: String {
        didSet {
            self.title = titleString
        }
    }
    /// set focus string (in the middle of screen)
    public var focusString: String {
        didSet {
            self.lblFocusDesc.text = focusString
        }
    }
    /// set details string (at bottom of screen)
    public var detailString: String {
        didSet {
            self.lblScanDesc.text = detailString
        }
    }
    
    public init(title: String, focusDesc: String, detailDesc: String) {
        self.titleString = title
        self.focusString = focusDesc
        self.detailString = detailDesc
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.titleString = NSLocalizedString("SCAN_DRIVER_LICENSE", comment: "Scan license")
        self.focusString = NSLocalizedString("SCAN_DRIVER_LICENSE_SCAN_BARCODE_DESC", comment: "")
        self.detailString = NSLocalizedString("SCAN_DRIVER_LICENSE_BOTTOM_DESC", comment: "")
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
        self.title = titleString
        
        self.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        lblFocusDesc.textColor = UIColor.whiteColor()
        lblFocusDesc.numberOfLines = 3
        lblFocusDesc.translatesAutoresizingMaskIntoConstraints = false
        lblFocusDesc.text = focusString
        self.view.addSubview(lblFocusDesc)

        lblScanDesc.font = UIFont.systemFontOfSize(12)
        lblScanDesc.textColor = UIColor.whiteColor()
        lblScanDesc.translatesAutoresizingMaskIntoConstraints = false
        lblScanDesc.numberOfLines = 3
        lblScanDesc.text = detailString
        self.view.addSubview(lblScanDesc)
        
        let padding: CGFloat = 70
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding)-[focus]-\(padding)-|",
                options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: [
                    "focus": lblFocusDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-[focus]-|",
                options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: [
                    "focus": lblFocusDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(padding)-[scan]-\(padding)-|",
                options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: [
                    "scan": lblScanDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:[scan]-20-|",
                options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: [
                    "scan": lblScanDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[topLayoutGuide]-0-[container]-0-|",
                options: NSLayoutFormatOptions.AlignAllLeft, metrics: nil, views: [
                    "topLayoutGuide": self.topLayoutGuide,
                    "container": container
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[container]-0-|",
                options: NSLayoutFormatOptions.AlignAllTop, metrics: nil, views: [
                    "container": container
                ])
        )
    }
    
    deinit {
        sessionStopped = true
        session.stopRunning()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !sessionStopped {
            session.startRunning()
        }
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.stopRunning()
    }
    
    override public func viewDidLayoutSubviews() {
        
        if container.frame.width > 0 && container.frame.height > 0 && boundLayer.superview == nil {
            self.showScanCameraView()
            self.addFocusFrameLayer()
        }
    }
    
    private func showScanCameraView() {
        
        if TARGET_IPHONE_SIMULATOR != 1 {
            startAvFoundationSession()
        }
    }
    
    private func startAvFoundationSession() {
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        if session.canSetSessionPreset(AVCaptureSessionPreset1920x1080) && device.supportsAVCaptureSessionPreset(AVCaptureSessionPreset1920x1080) {
            session.sessionPreset = AVCaptureSessionPreset1920x1080
        } else if session.canSetSessionPreset(AVCaptureSessionPresetiFrame1280x720) && device.supportsAVCaptureSessionPreset(AVCaptureSessionPresetiFrame1280x720) {
            session.sessionPreset = AVCaptureSessionPreset1280x720
        }
        
        if device.supportsAVCaptureSessionPreset(session.sessionPreset) {
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                try device.lockForConfiguration()
                if device.activeFormat.videoZoomFactorUpscaleThreshold > 1.1 {
                    device.videoZoomFactor = device.activeFormat.videoZoomFactorUpscaleThreshold - 0.1
                }
                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
                device.unlockForConfiguration()
                
                session.addInput(input)
                
                let output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
                
                session.addOutput(output)
                
                output.metadataObjectTypes = [AVMetadataObjectTypePDF417Code]
                
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.frame = container.layer.bounds
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                container.layer.addSublayer(previewLayer!)
                
                session.startRunning()
                sessionStopped = false
                
            } catch let error as NSError {
                sessionStopped = true
                print("failed to init AVCaptureDeviceInput with error: \(error.localizedDescription)")
            }
            
        } else {
            
            print("device don't support \(session.sessionPreset) preset")
        }
    }
    
    private func addFocusFrameLayer() {
        
        container.addSubview(boundLayer)
        container.bringSubviewToFront(boundLayer)
        
        changeToDefaultFocusFrame()
    }
    
    private func changeToDefaultFocusFrame() {
        let frameWithPaddings = CGRectApplyAffineTransform(container.bounds, CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9))
        
        UIView.animateWithDuration(0.2, animations: { [weak self] in
            if self != nil {
                self?.boundLayer.frame = CGRectMake((self!.container.bounds.width - frameWithPaddings.width)/2.0, (self!.container.bounds.height - frameWithPaddings.height)/2.0, frameWithPaddings.width, frameWithPaddings.height)
            }
        })
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        session.stopRunning()
        
        self.view.startSpinning()
        
        for metadata in metadataObjects {
            if let _metadata = metadata as? AVMetadataMachineReadableCodeObject {
                
                let transformedData = previewLayer?.transformedMetadataObjectForMetadataObject(_metadata)
                UIView.animateWithDuration(0.2, animations: { [weak self] in
                    self?.boundLayer.frame = transformedData!.bounds
                })
                
                if _metadata.type == AVMetadataObjectTypePDF417Code {
                    if DriverLicenseParser.isDriverLicenseFormat(_metadata.stringValue) {
                        
                        if let driverInfo = DriverLicenseParser(SerialString: _metadata.stringValue).driverInfo() {
                            delegate?.didScanResult(driverInfo)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                }
            }
        }
        
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) { [weak self] in
            if self != nil && !self!.sessionStopped {
                self?.changeToDefaultFocusFrame()
                self?.session.startRunning()
            }
            self?.view.stopSpinning()
        }
    }
}
