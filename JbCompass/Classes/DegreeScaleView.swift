
//  DegreeScaleView.swift
//  CompassExample
//
//

import UIKit
import CoreMotion
import CoreLocation
import AudioToolbox

let m_pi = Double.pi / 180

public enum LocalType: String {
    case north = "正北"
    case south = "正南"
    case west = "正西"
    case east = "正东"
    case northWest = "西北"
    case southWest = "西南"
    case northEast = "东北"
    case southEast = "东南"
}

/// 刻度视图
public class DegreeScaleView: UIView {
    
    /// 定位管理器
    private lazy var sensorManager = SYSensorManager.shared
    
    /// 放大比例
    public var scale: CGFloat = 1
    
    private var localData: [String: LocalType] = [:]
    private var localArrs: [LocalType: [String]] = [:]
    public var localSelected: String? {
        didSet {
            guard let selectStr = localSelected else { return }
            for value in btnArrs.enumerated() {
                let btn = value.element.value
                if value.element.key != selectStr {
                    btn.backgroundColor = .white
                    btn.layer.borderColor = UIColor.red.cgColor
                    btn.setTitleColor(UIColor.red, for: .normal)
                } else {
                    btn.backgroundColor = .red
                    btn.layer.borderColor = UIColor.white.cgColor
                    btn.setTitleColor(UIColor.white, for: .normal)
                }
            }
        }
    }
    
    private var btnArrs: [String: UIButton] = [:]
    public var btnClickBlock: ((String) -> Void)? = nil
    
    private lazy var centerView: UIImageView = {
        let v = UIImageView(frame: bounds)
        v.image = UIImage(named: "jb-indicator.png")
        v.frame = .init(x: 0, y: 0, width: 25, height: 25)
        return v
    }()
    
    /// 背景视图
    private lazy var dialView: UIImageView = {
        let v = UIImageView(frame: bounds)
        v.image = UIImage(named: "jb-luopan.png")
        v.frame = frame
        return v
    }()
    
    /// 水平视图
    private lazy var levelView: UIView = {
        let levelView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 1.5))
        levelView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        levelView.backgroundColor = .red
        return levelView
    }()
    
    /// 垂直视图
    private lazy var verticalView: UIView = {
        let verticalView = UIView(frame: CGRect(x: 0, y: 0, width: 1.5, height: self.frame.size.height))
        verticalView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        verticalView.backgroundColor = .red
        return verticalView
    }()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        addSubview(dialView)
        addSubview(levelView)
        addSubview(verticalView)
        addSubview(centerView)
        
        centerView.center = verticalView.center
    }
    
    public func initBtn(_ text: String) -> UIButton {
        let btnWidth: CGFloat = 25.0
        let btn = UIButton()
        btn.setTitle(text.first?.uppercased(), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.layer.cornerRadius = btnWidth / 2
        btn.layer.borderWidth = 1
        
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.frame = .init(x: 0, y: 0, width: btnWidth, height: btnWidth)
        
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.red.cgColor
        
        return btn
    }
    
    public func computeDataAction(_ data: [String: LocalType]) {
        self.localData = data
        for (key, value) in data {
            let btn = initBtn(key)
            btnArrs[key] = btn
            if localArrs.first(where: { key, val in
                key == value
            }) == nil {
                localArrs[value] = []
            }
            localArrs[value]?.append(key)
            dialView.addSubview(btn)
        }
        configScaleDial()
    }
    
    public func start() {
        sensorManager.didUpdateHeadingBlock = { [weak self] theHeading, magneticHeading in
            self?.updateHeading(theHeading, magneticHeading)
        }
        sensorManager.updateDeviceMotionBlock = { [weak self] tPoint in
            let center = self?.dialView.center ?? .zero
            self?.centerView.center = .init(x: center.x + tPoint.gravity.x * 30, y: center.y + tPoint.gravity.y * 30)
        }
        sensorManager.startSensor()
        sensorManager.startGyroscope()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Update multiple times
extension DegreeScaleView {
    
    private func updateHeading(_ theHeading: CLLocationDirection, _ magneticHeading: CLLocationDirection) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction]) { [weak self] in
            guard let weakSelf = self else {
                return
            }
            var headingRotation: CGAffineTransform!
            headingRotation = CGAffineTransformRotate(CGAffineTransformIdentity, -theHeading * m_pi);
            headingRotation = CGAffineTransformScale(headingRotation, weakSelf.scale, weakSelf.scale);
            weakSelf.dialView.transform = headingRotation;
        } completion: { finished in
            
        }
    }
    
    /// 计算中心坐标
    ///
    /// - Parameters:
    ///   - center: 中心点
    ///   - angle: 角度
    ///   - scale: 刻度
    /// - Returns: CGPoint
    private func calculateTextPositon(withArcCenter center: CGPoint, andAngle angle: CGFloat, andScale scale: CGFloat) -> CGPoint {
        let x = (self.frame.size.width / 2 - 50) * scale * CGFloat(cosf(Float(angle)))
        let y = (self.frame.size.width / 2 - 50) * scale * CGFloat(sinf(Float(angle)))
        return CGPoint(x: center.x + x, y: center.y + y)
    }

}

//MARK: - Configure
extension DegreeScaleView {
    
    /// 配置刻度表
    private func configScaleDial() {
        
        /// 360度
        let degree_360: CGFloat = CGFloat.pi
        
        /// 180度
        let degree_180: CGFloat = degree_360 / 2
        
        /// 角度
        let angle: CGFloat = degree_360 / 90
        
        /// 方向数组
        let directionArray = [
            0: LocalType.north,
            1: LocalType.east,
            2: LocalType.south,
            3: LocalType.west,
            46: LocalType.northEast,
            136: LocalType.southEast,
            226: LocalType.southWest,
            316: LocalType.northWest,
        ]
        
        /// 点
        let po = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        
        //画圆环，每隔2°画一个弧线，总共180条
        for i in 0 ..< 180 {
            
            /// 开始角度
            let startAngle: CGFloat = -(degree_180 + degree_360 / 180 / 2) + angle * CGFloat(i)
            
            /// 结束角度
            let endAngle: CGFloat = startAngle + angle / 2
            
            var localType: LocalType? = nil
            
            if [46, 136, 226, 316].contains(i * 2) {
                localType = directionArray[i * 2]!
            } else if i % 45 == 0 {
                localType = directionArray[i/45]!
            }
            
            let textAngle: CGFloat = startAngle + (endAngle - startAngle) / 2
            
            if localType != nil, (localArrs[localType!]?.count ?? 0) > 0 {
                var index = 0
                let lCount = localArrs[localType!]?.count ?? 0
                let singleAngle: CGFloat = 0.14
                let tmpAngle = textAngle - CGFloat(lCount-1) * singleAngle / 2
                repeat {
                    let point: CGPoint = calculateTextPositon(withArcCenter: po, andAngle: tmpAngle + CGFloat(index) * singleAngle, andScale: 1.4)
                    let btn = btnArrs[localArrs[localType!]![index]]
                    btn?.center = .init(x: point.x, y: point.y)
                    btn?.transform = CGAffineTransformRotate(CGAffineTransformIdentity, Double(i) * 2 * m_pi + 0.08 * Double(index-lCount/2));
                    index += 1
                } while index < lCount
            }
        }
    }
}
