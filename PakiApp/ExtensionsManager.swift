import UIKit

// MARK: - SegmentedControl
extension UISegmentedControl {
    
    func removeBorder(){
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)

        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor.clear.cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGray], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.label], for: .selected)
    }

    func addUnderlineForSelectedSegment(){
        removeBorder()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 2.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 1.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor.label
        underline.tag = 1
        self.addSubview(underline)
    }

    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}

// MARK: - UIImage
extension UIImage {

    class func getColoredRectImageWith(color: CGColor, andSize size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let graphicsContext = UIGraphicsGetCurrentContext()
        graphicsContext?.setFillColor(color)
        let rectangle = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        graphicsContext?.fill(rectangle)
        let rectangleImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return rectangleImage!
    }
}

// MARK: - String
extension String {
    func returnStringHeight(width: CGFloat, fontSize: CGFloat) -> CGSize {
         let size = CGSize(width: 250, height: 1000)
         
         let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
         let estimatedFrame = NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
         
         let estimatedHeight = estimatedFrame.height
         let feedSize = CGSize(width: width, height: estimatedHeight)
         return feedSize
     }
}

// MARK: - UIColor
extension UIColor {
    static func getColorFor(paki: Paki) -> UIColor {
        switch paki {
        case .all:
            return .systemGray
        case .awesome:
            return .systemRed
        case .good:
            return .systemBlue
        case .meh:
            return .systemGreen
        case .bad:
            return .systemPurple
        case .terrible:
            return .systemIndigo
        case .none:
            return .clear
        }
    }
}

// MARK: - UINavigationController
extension UINavigationController {

  public func pushViewController(viewController: UIViewController,
                                 animated: Bool,
                                 completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }

}

// MARK: - UIScrollView
extension UIScrollView {
    
    func scrollToNextItem(width: CGFloat) {
        let contentOffset = CGFloat(self.contentOffset.x + width)
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func scrollToPreviousItem(width: CGFloat) {
        let contentOffset = CGFloat(floor(self.contentOffset.x - width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x: contentOffset, y: self.contentOffset.y , width: self.frame.width, height: self.frame.height)
        self.scrollRectToVisible(frame, animated: true)
    }
    
}

extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.f", self) : String(self)
    }
}

protocol Reusable: class {
    
    static var className: String { get }
    static var nib: UINib { get }
    
}

extension Reusable {
    
    static var className: String {
        return "\(self)"
    }
    
    static var nib: UINib {
        return UINib(nibName: className, bundle: nil)
    }
}
