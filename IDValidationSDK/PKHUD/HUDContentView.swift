//
//  HUDContentView.swift
//  PKHUD
//
//  Created by Philip Kluz on 6/17/14.
//  Copyright (c) 2014 NSExceptional. All rights reserved.
//

import UIKit
import QuartzCore

public struct HUDContentView {
    /// Provides a square view, which you can subclass and add additional views to.
    open class SquareBaseView: UIView {

        public override init(frame: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 196.0, height: 196.0))) {
            super.init(frame: frame)
        }

        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
    }
    
    /// Provides a wide base view, which you can subclass and add additional views to.
    open class WideBaseView: UIView {
        
        public override init(frame: CGRect = CGRect(origin: CGPoint.zero, size: CGSize(width: 265.0, height: 90.0))) {
            super.init(frame: frame)
        }

        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
    /// Provides a wide, three line text view, which you can use to display information.
    open class TextView: WideBaseView {
        
        public init(text: String?) {
            super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 265.0, height: 90.0)))
            commonInit(text)
        }

        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit("")
        }
        
        fileprivate func commonInit(_ text: String?) {
            titleLabel.text = text
            addSubview(titleLabel)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            let padding: CGFloat = 10.0
            titleLabel.frame = bounds.insetBy(dx: padding, dy: padding)
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.textColor = UIColor.black.withAlphaComponent(0.85)
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 3
            return label
        }()
    }
    
    /// Provides a square view, which you can use to display a single image.
    open class ImageView: SquareBaseView {
        public init(image: UIImage?) {
            super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 176.0, height: 176.0)))
            commonInit(image)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit(nil)
        }
        
        fileprivate func commonInit(_ image: UIImage?) {
            imageView.image = image
            addSubview(imageView)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            imageView.frame = bounds
        }
        
        public let imageView: UIImageView = {
            let imageView = UIImageView()
            imageView.alpha = 0.85
            imageView.clipsToBounds = true
            imageView.contentMode = .center
            return imageView
        }()
    }
    
    /// Provides a square (indeterminate) progress view.
    open  class ProgressView: ImageView {
        public init() {
            super.init(image: UIImage(named: "progress"))
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        fileprivate override func commonInit(_ image: UIImage?) {
            super.commonInit(image)
            
            let progressImage = HUDAssets.progressImage
            
            imageView.image = progressImage
            imageView.layer.add({
                let animation = CABasicAnimation(keyPath: "transform.rotation.z")
                animation.toValue = NSNumber(value: 2.0 * Float(Double.pi) as Float)
                animation.duration = 0.65
                animation.isCumulative = true
                animation.repeatCount = Float(INT_MAX)
                return animation
                }(), forKey: "transform.rotation.z")
            imageView.alpha = 0.9
        }
    }
    
    /// Provides a square view, which you can use to display a picture and a title (above the image).
    public final class TitleView: ImageView {
        public init(title: String?, image: UIImage?) {
            super.init(image: image)
            commonInit(title)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit("");
        }
        
        fileprivate func commonInit(_ title: String?) {
            titleLabel.text = title
            addSubview(titleLabel)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            let viewWidth: CGFloat = bounds.size.width
            let viewHeight: CGFloat = bounds.size.height
            
            //let halfHeight = CGFloat(ceilf(CFloat(viewHeight / 2.0)))
            let quarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0)))
            let threeQuarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0 * 3.0)))
            
            let opticalOffset: CGFloat = 10.0
            
            titleLabel.frame = CGRect(origin: CGPoint(x:0.0, y:opticalOffset), size: CGSize(width: viewWidth, height: quarterHeight))
            imageView.frame = CGRect(origin: CGPoint(x:0.0, y:quarterHeight - opticalOffset), size: CGSize(width: viewWidth, height: threeQuarterHeight))
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.textColor = UIColor.black.withAlphaComponent(0.85)
            return label
        }()
    }
    
    /// Provides a square view, which you can use to display a picture and a subtitle (beneath the image).
    public final class SubtitleView: ImageView {
        public init(subtitle: String?, image: UIImage?) {
            super.init(image: image)
            commonInit(subtitle)
        }

        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit("");
        }
        
        fileprivate func commonInit(_ subtitle: String?) {
            subtitleLabel.text = subtitle
            addSubview(subtitleLabel)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            let viewWidth: CGFloat = bounds.size.width
            let viewHeight: CGFloat = bounds.size.height
            
            //let halfHeight = CGFloat(ceilf(CFloat(viewHeight / 2.0)))
            let quarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0)))
            let threeQuarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0 * 3.0)))
            
            let opticalOffset: CGFloat = 10.0
            
            imageView.frame = CGRect(origin: CGPoint(x: 0.0, y: opticalOffset), size: CGSize(width: viewWidth, height: threeQuarterHeight - opticalOffset))
            subtitleLabel.frame = CGRect(origin: CGPoint(x:5.0, y:threeQuarterHeight - opticalOffset), size: CGSize(width: viewWidth-10, height: quarterHeight))
        }
        
        public let subtitleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.textColor = UIColor.black.withAlphaComponent(0.85)
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 10
            return label
        }()
    }
    
    /// Provides a square view, which you can use to display a picture, a title and a subtitle. This type of view replicates the Apple HUD one to one.
    public final class StatusView: ImageView {
        public init(title: String?, subtitle: String?, image: UIImage?) {
            super.init(image: image)            
            self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 256.0, height: 256.0))
            commonInit(title, subtitle: subtitle)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit("", subtitle: "")
        }
        
        fileprivate func commonInit(_ title: String?, subtitle: String?) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            
            addSubview(titleLabel)
            addSubview(subtitleLabel)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            let viewWidth = bounds.size.width
            let viewHeight = bounds.size.height
            
            let halfHeight = CGFloat(ceilf(CFloat(viewHeight / 2.0)))
            let quarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0)))
            let threeQuarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0 * 3.0)))
            
            titleLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: viewWidth, height: quarterHeight))
            imageView.frame = CGRect(origin: CGPoint(x:0.0, y:quarterHeight), size: CGSize(width: viewWidth, height: halfHeight))
            subtitleLabel.frame = CGRect(origin: CGPoint(x:5.0, y:threeQuarterHeight), size: CGSize(width: viewWidth-10, height: quarterHeight))
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.textColor = UIColor.black.withAlphaComponent(0.85)
            return label
        }()
        
        public let subtitleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = UIColor.black.withAlphaComponent(0.7)
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 10
            return label
        }()
    }
    
    /// Provides a square view, which you can use to display a picture, a title and a subtitle. This type of view replicates the Apple HUD one to one.
    public final class ProgressStatusView: ProgressView {
        public init(title: String?, subtitle: String?) {
            super.init()
            commonInit(title, subtitle: subtitle)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit("", subtitle: "")
        }
        
        fileprivate func commonInit(_ title: String?, subtitle: String?) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            
            addSubview(titleLabel)
            addSubview(subtitleLabel)
        }
        
        public override func layoutSubviews() {
            super.layoutSubviews()
            
            let viewWidth = bounds.size.width
            let viewHeight = bounds.size.height
            
            let halfHeight = CGFloat(ceilf(CFloat(viewHeight / 2.0)))
            let quarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0)))
            let threeQuarterHeight = CGFloat(ceilf(CFloat(viewHeight / 4.0 * 3.0)))
            
            titleLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: viewWidth, height: quarterHeight))
            imageView.frame = CGRect(origin: CGPoint(x:0.0, y:quarterHeight), size: CGSize(width: viewWidth, height: halfHeight))
            subtitleLabel.frame = CGRect(origin: CGPoint(x:5.0, y:threeQuarterHeight), size: CGSize(width: viewWidth-10, height: quarterHeight))
        }
        
        public let titleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 17.0)
            label.textColor = UIColor.black.withAlphaComponent(0.85)
            return label
            }()
        
        public let subtitleLabel: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = UIColor.black.withAlphaComponent(0.7)
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 10
            return label
            }()
    }
}
