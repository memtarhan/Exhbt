//
//  CategoryCell.swift
//  Exhbt
//
//  Created by Steven Worrall on 6/1/20.
//  Copyright © 2020 Exhbt LLC. All rights reserved.
//

import SnapKit

class NewsfeedCategoryCell: UICollectionViewCell {
    
    public let selectedBorder = CAShapeLayer()

    var category: ChallengeCategories? {
        didSet {
            guard let unwrappedString = category?.rawValue else { return }
            self.label.text = unwrappedString
            
            let imageName = unwrappedString + "Category"
            if let temp = UIImage(named: imageName) {
                self.imageView.image = temp
            }
        }
    }
    
    var centerBlurView: Bool = false {
        didSet {
            if centerBlurView {
                blurViewCenterConstraint?.update(offset: 0)
            }
        }
    }
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var blurViewCenterConstraint: Constraint?
    
    private let label: UILabel = {
        let temp = Label(title: "", fontSize: 14, weight: .boldItalic)
        temp.textColor = .white
        temp.backgroundColor = .clear
        temp.textAlignment = .center
        return temp
    }()
    private let imageView: UIImageView = {
        let temp = UIImageView()
        temp.contentMode = .scaleAspectFill
        temp.layer.masksToBounds = true
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let width = rect.size.width
        let height = rect.size.height
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let offset: CGFloat = 10
        
        let pointA = CGPoint(x: bounds.maxX/2, y: bounds.minY)
        let pointB = CGPoint(x: bounds.maxX, y: bounds.minY)
        let pointC = CGPoint(x: bounds.maxX - offset, y: bounds.maxY)
        let pointD = CGPoint(x: bounds.minX, y: bounds.maxY)
        let pointE = CGPoint(x: bounds.minX + offset, y: bounds.minY)
        
        let topImagePath = [pointA, pointB, pointC, pointD, pointE]

        let imageView = self.imageView
        imageView.frame = frame
        addMask(view: imageView, points: topImagePath)
    }
    
    func addMask(view:UIView, points:[CGPoint]){
        
        let maskPath = CGMutablePath()
        
        maskPath.move(to: points[0])
        maskPath.addArc(tangent1End: points[1], tangent2End: points[2], radius: 5)
        maskPath.addArc(tangent1End: points[2], tangent2End: points[3], radius: 5)
        maskPath.addArc(tangent1End: points[3], tangent2End: points[4], radius: 5)
        maskPath.addArc(tangent1End: points[4], tangent2End: points[0], radius: 5)
        maskPath.closeSubpath()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath
        view.layer.mask = maskLayer
        
        self.selectedBorder.path = maskLayer.path
        self.selectedBorder.fillColor = UIColor.clear.cgColor
        self.selectedBorder.strokeColor = UIColor.EXRed().cgColor
        self.selectedBorder.lineWidth = 3
        self.selectedBorder.frame = view.bounds
        view.layer.addSublayer(self.selectedBorder)
    }
    
    func setupViews() {
        self.backgroundColor = .clear
        self.layer.masksToBounds = true
        
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.imageView.addSubview(self.blurView)
        self.blurView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            blurViewCenterConstraint = make.centerY.equalToSuperview().offset(-40).constraint
            make.height.equalTo(18)
        }
        
        self.blurView.contentView.addSubview(self.label)
        self.label.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    public func transformSelected() {
        if centerBlurView {
            self.imageView.layer.addSublayer(self.selectedBorder)
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            self.imageView.layer.addSublayer(self.selectedBorder)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    public func transformUnselected() {
        if centerBlurView {
            self.selectedBorder.removeFromSuperlayer()
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
            
            self.selectedBorder.removeFromSuperlayer()
        }
    }
}
