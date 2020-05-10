//
//  GraphsView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/10/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

class GraphsView: UIView, Reusable {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var monthlyGraph: ViewX!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var graphTable: UITableView!
    
    var total: Double = 0
    var userPosts: [UserPost] = []
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
    }
    
    
    func addAllMonthPakiCircles(posts: [UserPost]) {
        userPosts = posts
        total = Double(posts.count)
        let awesome = Double(posts.filter({$0.pakiCase == .awesome}).count)
        let good = Double(posts.filter({$0.pakiCase == .good}).count)
        let meh = Double(posts.filter({$0.pakiCase == .meh}).count)
        let bad = Double(posts.filter({$0.pakiCase == .bad}).count)
        let terrible = Double(posts.filter({$0.pakiCase == .terrible}).count)
        
        createGraphCircle(radius: 100, count: awesome, paki: .awesome)
        createGraphCircle(radius: 80, count: good, paki: .good)
        createGraphCircle(radius: 60, count: meh, paki: .meh)
        createGraphCircle(radius: 40, count: bad, paki: .bad)
        createGraphCircle(radius: 20, count: terrible, paki: .terrible)
        
        graphTable.reloadData()
    }
    
    func createGraphCircle(radius: CGFloat, count: Double, paki: Paki) {
        
        if count <= 0 {
            return
        }
        
        let pakiColor = UIColor.getColorFor(paki: paki)
        let arc = (count * 360) / total
        let degrees = CGFloat(arc.deg2rad(arc))

        let centerPoint = CGPoint(x: contentView.frame.width / 2 - 40, y: contentView.frame.height / 2 - 80)
        
        let trackPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: .pi * 2, clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = trackPath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.defaultBGColor.cgColor
        trackLayer.lineWidth = 10
        monthlyGraph.layer.addSublayer(trackLayer)
        
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
        let pakiCount = userPosts.filter({$0.paki == currentPaki.rawValue}).count
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.className) as! StatsTableViewCell
        cell.totalCount = userPosts.count
        cell.setupCell(withPaki: currentPaki, count: pakiCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = tableView.frame.height / 5
        return rowHeight
    }
    
    
}
