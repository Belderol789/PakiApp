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
    
    func compressTo(_ expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue)  {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                    return imgData
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        return nil
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
            return UIColor.hexStringToUIColor(hex: "#edcf50")
        case .good:
            return UIColor.hexStringToUIColor(hex: "#88c664")
        case .meh:
            return UIColor.hexStringToUIColor(hex: "#5783c3")
        case .bad:
            return UIColor.hexStringToUIColor(hex: "#f9a65c")
        case .terrible:
            return UIColor.hexStringToUIColor(hex: "#ee3a39")
        case .none:
            return .clear
        }
    }
    
    static func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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

// MARK: - UIViewController
extension UIViewController {
    func showAlertWith(title: String, message: String, actions: [UIAlertAction], hasDefaultOK: Bool) {
        
        var userActions = actions
        
        if hasDefaultOK {
            userActions.append(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        userActions.forEach { (action) in
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion: nil)
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
    
    func scrollToDown(height: CGFloat) {
        let frame: CGRect = CGRect(x: self.contentOffset.x, y: height, width: self.frame.width, height: self.frame.height)
        self.scrollRectToVisible(frame, animated: true)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x: contentOffset, y: self.contentOffset.y , width: self.frame.width, height: self.frame.height)
        self.scrollRectToVisible(frame, animated: true)
    }
    
}

// MARK: - Double
extension Double {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.f", self) : String(self)
    }
}

// MARK: - Date
extension Date {
    
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        return localDate
    }
    
    func convertToString(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}

// MARK: - UITextfield
extension UITextField {
    func returnTextCount(textField: UITextField, string: String, range: NSRange) -> Int {
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace = range.length

        let newLength = startingLength + lengthToAdd - lengthToReplace
        return newLength
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
