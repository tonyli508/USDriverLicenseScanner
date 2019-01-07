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

class ScanDriverLicenseViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var boundLayer = ScanBoundaryView()
    private lazy var session = AVCaptureSession()
    private var sessionStopped = false
    private var container = UIView()
    public weak var delegate: ScanDriverLicenseViewControllerDelegate?
    
    /// focus desc, expose for change font and style
    public let lblFocusDesc = UILabel(frame: CGRect.zero)
    /// scan detail desc, expose for change font and style
    public let lblScanDesc = UILabel(frame: CGRect.zero)
    
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
        
        self.view.backgroundColor = UIColor.black
        self.title = titleString
        
        self.view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        lblFocusDesc.textColor = UIColor.white
        lblFocusDesc.numberOfLines = 3
        lblFocusDesc.translatesAutoresizingMaskIntoConstraints = false
        lblFocusDesc.text = focusString
        self.view.addSubview(lblFocusDesc)

        lblScanDesc.font = UIFont.systemFont(ofSize: 12)
        lblScanDesc.textColor = UIColor.white
        lblScanDesc.translatesAutoresizingMaskIntoConstraints = false
        lblScanDesc.numberOfLines = 3
        lblScanDesc.text = detailString
        self.view.addSubview(lblScanDesc)
        
        let padding: CGFloat = 70
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(padding)-[focus]-\(padding)-|",
                options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: [
                    "focus": lblFocusDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[focus]-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: [
                    "focus": lblFocusDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(padding)-[scan]-\(padding)-|",
                options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: [
                    "scan": lblScanDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:[scan]-20-|",
                                           options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: [
                    "scan": lblScanDesc
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[topLayoutGuide]-0-[container]-0-|",
                                           options: NSLayoutFormatOptions.alignAllLeft, metrics: nil, views: [
                    "topLayoutGuide": self.topLayoutGuide,
                    "container": container
                ])
        )
        
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[container]-0-|",
                                           options: NSLayoutFormatOptions.alignAllTop, metrics: nil, views: [
                    "container": container
                ])
        )
    }
    
    deinit {
        sessionStopped = true
        session.stopRunning()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !sessionStopped {
            session.startRunning()
        }
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
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
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        
        if session.canSetSessionPreset(AVCaptureSession.Preset.hd1920x1080) && device.supportsSessionPreset(AVCaptureSession.Preset.hd1920x1080) {
            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        } else if session.canSetSessionPreset(AVCaptureSession.Preset.iFrame1280x720) && device.supportsSessionPreset(AVCaptureSession.Preset.iFrame1280x720) {
            session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        
        if device.supportsSessionPreset(session.sessionPreset) {
            
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                try device.lockForConfiguration()
                if device.activeFormat.videoZoomFactorUpscaleThreshold > 1.1 {
                    device.videoZoomFactor = device.activeFormat.videoZoomFactorUpscaleThreshold - 0.1
                }
                device.focusMode = AVCaptureDevice.FocusMode.continuousAutoFocus
                device.unlockForConfiguration()
                
                session.addInput(input)
                
                let output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                
                session.addOutput(output)
                
                output.metadataObjectTypes = [AVMetadataObject.ObjectType.pdf417]
                
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.frame = container.layer.bounds
                previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
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
        container.bringSubview(toFront: boundLayer)
        
        changeToDefaultFocusFrame()
    }
    
    private func changeToDefaultFocusFrame() {
        
        let frameWithPaddings = container.bounds.applying(CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9))
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            if self != nil {
                self?.boundLayer.frame = CGRect(x: (self!.container.bounds.width - frameWithPaddings.width)/2.0, y: (self!.container.bounds.height - frameWithPaddings.height)/2.0, width: frameWithPaddings.width, height: frameWithPaddings.height)
            }
        })
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        session.stopRunning()
        
        self.view.startSpinning()
        
        for metadata in metadataObjects {
            if let _metadata = metadata as? AVMetadataMachineReadableCodeObject {
                
                let transformedData = previewLayer?.transformedMetadataObject(for: _metadata)
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.boundLayer.frame = transformedData!.bounds
                })
                
                if _metadata.type == AVMetadataObject.ObjectType.pdf417 {
                    if DriverLicenseParser.isDriverLicenseFormat(codeString: _metadata.stringValue!) {
                        
                        if let driverInfo = DriverLicenseParser(SerialString: _metadata.stringValue!).driverInfo() {
                            delegate?.didScanResult(driverInfo: driverInfo)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        
        let delay = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) { [weak self] in
            if self != nil && !self!.sessionStopped {
                self?.changeToDefaultFocusFrame()
                self?.session.startRunning()
            }
            self?.view.stopSpinning()
        }
    }
}
