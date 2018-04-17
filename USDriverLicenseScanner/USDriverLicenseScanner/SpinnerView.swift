

import UIKit

enum SpinnerViewStyle {
    case White
    case Black
    case Clear
    
    /// Loading style for background color
    var backgroundColor: UIColor {
        switch self {
        case .White:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        case .Black:
            return UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 0.5)
        case .Clear:
            return UIColor.clear
        }
    }
}

// MARK: - Spinner
extension UIView {
    
    // get previous spinner if exist
    private func getPreviousSpinner(parentView: UIView) -> BaseSpinnerView? {
        
        for subview in parentView.subviews {
            if let spinner = subview as? BaseSpinnerView, spinner.tag == BaseSpinnerView.UNIQUE_SPINNER_VIEW_TAG {
                return spinner
            }
        }
        return nil
    }
    
    /**
     Start spinning with UIActivityIndicatorView
     
     - parameter style: SpinnerViewStyle
     */
    func startSpinning(style: SpinnerViewStyle = .Black) {
        
        let spinner = getPreviousSpinner(parentView: self) ?? IndicatorSpinnerView(parentView: self, style: style)
        spinner.startSelfSpinning()
    }
    
    /**
     Start spinning with custom animation image
     
     - parameter animationImage: animationImage UIImage
     - parameter style:          SpinnerViewStyle
     */
    func startSpinning(animationImage: UIImage, style: SpinnerViewStyle = .Black) {
        
        let spinner = getPreviousSpinner(parentView: self) ?? ImageSpinnerView(parentView: self, animationImage: animationImage, style: style)
        spinner.startSelfSpinning()
    }
    
    /**
     Start loading spinning with default loading image
     
     - parameter style: SpinnerViewStyle
     */
    func startLoading(style: SpinnerViewStyle = .Black) {
        self.startSpinning(style: style)
    }
    
    /**
     Stop spinning
     */
    func stopSpinning() {
        
        self.getPreviousSpinner(parentView: self)?.stopSelfSpinning()
    }
}

/// BaseSpinnerView, default just show a block background, subclass this to show the spinner
class BaseSpinnerView: UIView {
    
    static let UNIQUE_SPINNER_VIEW_TAG = 987654321
    
    deinit {
        print("SpinnerView deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(parentView: UIView, style: SpinnerViewStyle = .Black) {
        super.init(frame: parentView.bounds)
        
        self.isHidden = true
        self.backgroundColor = style.backgroundColor
        self.tag = BaseSpinnerView.UNIQUE_SPINNER_VIEW_TAG
        
        parentView.addSubview(self)
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[view(==container)]-|",
                                           options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: [
                    "view": self,
                    "container": parentView
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[view(==container)]-|",
                                           options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: [
                    "view": self,
                    "container": parentView
                ])
        )
    }
    
    /**
     to show the loading view and start animation
     override this to make custom spinner action
    */
    func startSelfSpinning() {
        
        self.superview?.bringSubview(toFront: self)
        self.isHidden = false
    }
    
    /**
     to hide loading view and stop animation
     override this to make custom spinner action
     */
    func stopSelfSpinning() {
        self.isHidden = true
    }
}

class IndicatorSpinnerView: BaseSpinnerView {
    
    private let activityIndicator: UIActivityIndicatorView
    
    required init(parentView: UIView, style: SpinnerViewStyle = .Black) {
        
        let indicatorViewStyle = style == .Black ? UIActivityIndicatorViewStyle.white : UIActivityIndicatorViewStyle.gray
        let defaultSpinnerSize: CGFloat = 40.0
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorViewStyle)
        
        super.init(parentView: parentView, style: style)
        
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[indicator(=\(defaultSpinnerSize))]-|",
                options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: [
                    "indicator": activityIndicator
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[indicator(=\(defaultSpinnerSize))]-|",
                options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: [
                    "indicator": activityIndicator
                ])
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        super.init(coder: aDecoder)
    }
    
    override func startSelfSpinning() {
        super.startSelfSpinning()
        
        activityIndicator.startAnimating()
    }
    
    override func stopSelfSpinning() {
        super.stopSelfSpinning()
        
        activityIndicator.stopAnimating()
    }
}

class ImageSpinnerView: BaseSpinnerView {
    
    private var animationLayer = CALayer()
    
    convenience init(parentView: UIView, animationImage: UIImage, style: SpinnerViewStyle = .Black) {
        self.init(parentView: parentView, style: style)
        
        let frameView = UIView()
        let loadingImage = animationImage
        let frame : CGRect = CGRect(x: 0, y: 0, width: loadingImage.size.width, height: loadingImage.size.height)
        
        animationLayer.frame = frame
        animationLayer.contents = loadingImage.cgImage
        animationLayer.masksToBounds = true
        
        frameView.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(layer: animationLayer)
        
        self.addSubview(frameView)
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[indicator(=28)]-|",
                                                           options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: [
                    "indicator": frameView
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[indicator(=28)]-|",
                                           options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: [
                    "indicator": frameView
                ])
        )
    }
    
    required init(parentView: UIView, style: SpinnerViewStyle = .Black) {
        super.init(parentView: parentView, style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func startSelfSpinning() {
        super.startSelfSpinning()
        
        resume(layer: animationLayer)
    }
    
    override func stopSelfSpinning() {
        super.stopSelfSpinning()
        
        pause(layer: animationLayer)
    }
    
    private func addRotation(forLayer layer : CALayer) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        
        rotation.duration = 1.0
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = HUGE
        rotation.fillMode = kCAFillModeForwards
        rotation.fromValue = NSNumber(value: 0.0)
        rotation.toValue = NSNumber(value: Double.pi * 2.0)
        
        layer.add(rotation, forKey: "rotate")
    }
    
    private func pause(layer : CALayer) {
        
        layer.speed = 0.0
        
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.timeOffset = pausedTime
    }
    
    private func resume(layer : CALayer) {
        let pausedTime : CFTimeInterval = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
