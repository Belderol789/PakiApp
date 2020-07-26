//
//  GraphsView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class GraphsView: UIView, Reusable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var monthlyGraph: ViewX!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var graphTable: UITableView!
    @IBOutlet weak var timeFrameLabel: UILabel!
    
    var total: Double = 0
    var yearPosts: [UserPost] = []
    var monthPosts: [UserPost] = []
    var userPosts: [UserPost] = [] {
        didSet {
            totalLabel.text = "Total: \(userPosts.count)"
            total = Double(userPosts.count)
        }
    }
    var allPakis: [String] = []
    let pakis: [Paki] = [.awesome, .good, .meh, .bad, .terrible]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXib()
    }
    
    fileprivate func setupXib() {
        Bundle.main.loadNibNamed(GraphsView.className, owner: self, options: nil)
        contentView.frame = self.bounds
        self.addSubview(contentView)
        segmentedControl.addUnderlineForSelectedSegment()
        graphTable.backgroundColor = .clear
        graphTable.register(StatsTableViewCell.nib, forCellReuseIdentifier: StatsTableViewCell.className)
        graphTable.delegate = self
        graphTable.dataSource = self
    }
    
    @IBAction func didChangeTimeFrame(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
        let isYear = sender.selectedSegmentIndex == 0
        let timeFrame = isYear ? "Year-in review" : "Monthly Review"
        timeFrameLabel.text = timeFrame
        monthlyGraph.layer.sublayers?.forEach({
            if $0.isKind(of: CAShapeLayer.self) {
                $0.removeFromSuperlayer()
            }
        })
        
        userPosts = isYear ? yearPosts : monthPosts
        updateGraphs()
    }
    
    func addAllYear(posts: [UserPost]) {
        yearPosts = posts
        userPosts = posts
        
        let currentMonth = Calendar.current.component(.month, from: Date())
        monthPosts.removeAll()
        for post in userPosts {
            let postDate = Date(timeIntervalSince1970: post.datePosted)
            let postMonth = Calendar.current.component(.month, from: postDate)
            print("CurrentMonth \(currentMonth) PostMonth \(postMonth)")
            if currentMonth == postMonth {
                monthPosts.append(post)
            }
        }
        
        timeFrameLabel.text = "Year-in progress"
        updateGraphs()
    }
    
    fileprivate func updateGraphs() {
        
        let awesome = Double(userPosts.filter({$0.pakiCase == .awesome}).count)
        let good = Double(userPosts.filter({$0.pakiCase == .good}).count)
        let meh = Double(userPosts.filter({$0.pakiCase == .meh}).count)
        let bad = Double(userPosts.filter({$0.pakiCase == .bad}).count)
        let terrible = Double(userPosts.filter({$0.pakiCase == .terrible}).count)
        
        let centerPoint = CGPoint(x: contentView.frame.width / 2 - 40, y: contentView.frame.height / 2 - 80)
        createGraphCircle(radius: 100, count: awesome, paki: .awesome)
        createGraphCircle(radius: 80, count: good, paki: .good)
        createGraphCircle(radius: 60, count: meh, paki: .meh)
        createGraphCircle(radius: 40, count: bad, paki: .bad)
        createGraphCircle(radius: 20, count: terrible, paki: .terrible)
        
        allPakis = userPosts.map({$0.paki})
        
        graphTable.reloadData()
    }
    
    func addWorldPakiCircles(allPaki: [String]) {
        timeFrameLabel.text = Date().convertToString(with: "LLLL dd, yyyy")
        segmentedControl.isHidden = true
        allPakis = allPaki
        totalLabel.text = "Total: \(allPaki.count)"
        total = Double(allPaki.count)
        
        let awesome = Double(allPakis.filter({$0 == Paki.awesome.rawValue}).count)
        let good = Double(allPakis.filter({$0 == Paki.good.rawValue}).count)
        let meh = Double(allPakis.filter({$0 == Paki.meh.rawValue}).count)
        let bad = Double(allPakis.filter({$0 == Paki.bad.rawValue}).count)
        let terrible = Double(allPakis.filter({$0 == Paki.terrible.rawValue}).count)

        createGraphCircle(radius: 100, count: awesome, paki: .awesome)
        createGraphCircle(radius: 80, count: good, paki: .good)
        createGraphCircle(radius: 60, count: meh, paki: .meh)
        createGraphCircle(radius: 40, count: bad, paki: .bad)
        createGraphCircle(radius: 20, count: terrible, paki: .terrible)

        graphTable.reloadData()
        DispatchQueue.main.async {
            let desiredOffset = CGPoint(x: 0, y: 200)
            self.scrollView.setContentOffset(desiredOffset, animated: true)
        }
    }
    
    
    func createGraphCircle(radius: CGFloat, count: Double, paki: Paki) {
        
        let centerPoint = CGPoint(x: monthlyGraph.frame.width / 2, y: monthlyGraph.frame.height / 2)
        
        let pakiColor = UIColor.getColorFor(paki: paki)
        let arc = (count * 360) / total
        let degrees = CGFloat(arc.deg2rad(arc))
        
        print("Degrees \(degrees)")

        let trackPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: .pi * 2, clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = trackPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.defaultBGColor.cgColor
        trackLayer.lineWidth = 10
        monthlyGraph.layer.addSublayer(trackLayer)
        
        if count <= 0 {
            return
        }
        
        let circularPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: degrees, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circularPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = pakiColor.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.strokeEnd = 0
        monthlyGraph.layer.addSublayer(shapeLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "strokeEndKey")
    }
}

// MARK: - UITableView
extension GraphsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pakis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPaki = pakis[indexPath.row]
        let pakiCount = allPakis.filter({$0 == currentPaki.rawValue}).count
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.className) as! StatsTableViewCell
        cell.totalCount = Int(total)
        cell.setupCell(withPaki: currentPaki, count: pakiCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = tableView.frame.height / 5
        return rowHeight
    }
    
    
}
