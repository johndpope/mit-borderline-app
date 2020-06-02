import UIKit
import SwiftyGif

class LogoAnimationView: UIView {

    let logoGifImageView: UIImageView = {
        guard let gifImage = try? UIImage(gifName: "logoAnimation.gif") else {
            return UIImageView()
        }
        return UIImageView(gifImage: gifImage, loopCount: 1)
    }()
    
    let backgroundImageView: UIImageView = UIImageView(image: UIImage(imageLiteralResourceName: "TunnelGradient"))
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(backgroundImageView)
        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        backgroundImageView.preservesSuperviewLayoutMargins = true
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        let margins = self.layoutMarginsGuide

        backgroundImageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        backgroundImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(logoGifImageView)
        logoGifImageView.translatesAutoresizingMaskIntoConstraints = false
        logoGifImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoGifImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        logoGifImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.2).isActive = true
        logoGifImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.12798).isActive = true // 621/661*1.2 (aspect ratio times width multiplier)

    }
}
