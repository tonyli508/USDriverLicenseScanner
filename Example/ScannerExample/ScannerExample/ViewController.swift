//
//  ViewController.swift
//  ScannerExample
//
//  Created by Li Jiantang on 12/9/16.
//  Copyright © 2016 Li Jiantang. All rights reserved.
//

import UIKit
import USDriverLicenseScanner

class ViewController: UIViewController, ScanDriverLicenseViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openScanner() {
        let scanner = ScanDriverLicenseViewController(title: "Scan Driver License", focusDesc: "Align with the barcode on the back of your license.", detailDesc: "By adding my license, I consent to a standard driver record check, powered by Checkr")
        scanner.delegate = self
        let navigation = UINavigationController(rootViewController: scanner)
        scanner.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Done, target: self, action: #selector(dismiss))
        self.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func didScanResult(driverInfo: DriverLicense) {
        print("driver info: \(driverInfo)")
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

