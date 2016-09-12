

import UIKit

enum SpinnerViewStyle {
    case White
    case Black
    case Clear
    
    /// Loading style for background color
    var backgroundColor: UIColor {
        switch self {
        case White:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        case Black:
            return UIColor(red: 87/255, green: 87/255, blue: 87/255, alpha: 0.5)
        case Clear:
            return UIColor.clearColor()
        }
    }
}

// MARK: - Spinner
extension UIView {
    
    // get previous spinner if exist
    private func getPreviousSpinner(parentView: UIView) -> BaseSpinnerView? {
        
        for subview in parentView.subviews {
            if let spinner = subview as? BaseSpinnerView where spinner.tag == BaseSpinnerView.UNIQUE_SPINNER_VIEW_TAG {
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
        
        let spinner = getPreviousSpinner(self) ?? IndicatorSpinnerView(parentView: self, style: style)
        spinner.startSelfSpinning()
    }
    
    /**
     Start spinning with custom animation image
     
     - parameter animationImage: animationImage UIImage
     - parameter style:          SpinnerViewStyle
     */
    func startSpinning(animationImage: UIImage, style: SpinnerViewStyle = .Black) {
        
        let spinner = getPreviousSpinner(self) ?? ImageSpinnerView(parentView: self, animationImage: animationImage, style: style)
        spinner.startSelfSpinning()
    }
    
    /**
     Start loading spinning with default loading image
     
     - parameter style: SpinnerViewStyle
     */
    func startLoading(style: SpinnerViewStyle = .Black) {
        self.startSpinning(style)
    }
    
    /**
     Stop spinning
     */
    func stopSpinning() {
        
        self.getPreviousSpinner(self)?.stopSelfSpinning()
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
        
        self.hidden = true
        self.backgroundColor = style.backgroundColor
        self.tag = BaseSpinnerView.UNIQUE_SPINNER_VIEW_TAG
        
        parentView.addSubview(self)
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-[view(==container)]-|",
                options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: [
                    "view": self,
                    "container": parentView
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-[view(==container)]-|",
                options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: [
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
        
        self.superview?.bringSubviewToFront(self)
        self.hidden = false
    }
    
    /**
     to hide loading view and stop animation
     override this to make custom spinner action
     */
    func stopSelfSpinning() {
        self.hidden = true
    }
}

class IndicatorSpinnerView: BaseSpinnerView {
    
    private let activityIndicator: UIActivityIndicatorView
    
    required init(parentView: UIView, style: SpinnerViewStyle = .Black) {
        
        let indicatorViewStyle = style == .Black ? UIActivityIndicatorViewStyle.White : UIActivityIndicatorViewStyle.Gray
        let defaultSpinnerSize: CGFloat = 40.0
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: indicatorViewStyle)
        
        super.init(parentView: parentView, style: style)
        
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-[indicator(=\(defaultSpinnerSize))]-|",
                options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: [
                    "indicator": activityIndicator
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-[indicator(=\(defaultSpinnerSize))]-|",
                options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: [
                    "indicator": activityIndicator
                ])
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
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
        let frame : CGRect = CGRectMake(0.0, 0.0, loadingImage.size.width, loadingImage.size.height)
        
        animationLayer.frame = frame
        animationLayer.contents = loadingImage.CGImage
        animationLayer.masksToBounds = true
        
        frameView.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(layer: animationLayer)
        
        self.addSubview(frameView)
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("H:|-[indicator(=28)]-|",
                options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: [
                    "indicator": frameView
                ])
        )
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat("V:|-[indicator(=28)]-|",
                options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: [
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
        rotation.removedOnCompletion = false
        rotation.repeatCount = HUGE
        rotation.fillMode = kCAFillModeForwards
        rotation.fromValue = NSNumber(float: 0.0)
        rotation.toValue = NSNumber(double: M_PI * 2.0)
        
        layer.addAnimation(rotation, forKey: "rotate")
    }
    
    private func pause(layer layer : CALayer) {
        
        layer.speed = 0.0
        
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.timeOffset = pausedTime
    }
    
    private func resume(layer layer : CALayer) {
        let pausedTime : CFTimeInterval = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
