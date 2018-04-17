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
        scanner.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        self.present(navigation, animated: true, completion: nil)
    }
    
    func didScanResult(driverInfo: DriverLicense) {
        print("driver info: \(driverInfo)")
        
        let alert = UIAlertController(title: "Result", message: "driver info: \(driverInfo)", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
}

