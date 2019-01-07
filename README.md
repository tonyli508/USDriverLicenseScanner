# USDriverLicenseScanner

[![Swift](https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat)](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)(https://swift.org)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

USDriverLicenseScanner is a library for scanning US driver license details from your iPhone camera.

![USDriverLicenseScanner](https://github.com/tonyli508/USDriverLicenseScanner/blob/master/images/screenshot2.png)

## How to use
* Make your UIViewController conformed to ScanDriverLicenseViewControllerDelegate
* Implement `func didScanResult(driverInfo: DriverLicense)` (it will be callbacked with driver license info, once scanned)
* Show scanner view
```swift
/// create
let scanner = ScanDriverLicenseViewController(
	title: "Scan Driver License", 
	focusDesc: "Align with the barcode on the back of your license.", 
	detailDesc: "By adding my license, I consent to a standard driver record check, powered by Checkr")
/// delegate
scanner.delegate = self
/// add cancel button
let navigation = UINavigationController(rootViewController: scanner)
scanner.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
/// show
self.present(navigation, animated: true, completion: nil)
```
Or check out the example app.

## Carthage
```ogdl
github "tonyli508/USDriverLicenseScanner" ~> 1.0.0
```
Check out the example code in Carthage branch as well, if you need more details.
