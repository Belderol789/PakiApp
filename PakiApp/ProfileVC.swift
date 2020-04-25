//
//  ProfileVC.swift
//  Paki
//
//  Created by Kem Belderol on 4/22/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit
import BubbleTransition
import Charts

class ProfileVC: UIViewController {
    // IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var gridViewContainer: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var statsTableView: UITableView!
    // Constraints
    // Variables
    let testPaki: [Paki] = [.awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good, .awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good, .awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good, .awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good, .awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good, .awesome, .bad, .meh, .awesome, .bad, .meh, .none, .terrible, .terrible, .awesome, .bad, .meh, .none, .good, .good, .meh, .good, .terrible, .terrible, .awesome, .bad, .meh, .meh, .none, .good]
    
    var pakis: [Paki] = [.awesome, .good, .meh, .bad, .terrible]
    
    var pakiViews: [String: ViewX] = [:]
    var selectedPaki: ViewX?
    var startingPoint: CGPoint = CGPoint.zero
    var gridTimer: Timer?
    
    var chartData: [String: Int] = [:]
    var numberOfPakiEntries = [PieChartDataEntry]()
    
    let transition = BubbleTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGridViews()
        addChartViews()
        totalLabel.text = "Total: \(testPaki.count)"
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let width = view.frame.width
        if sender.selectedSegmentIndex == 0 {
            scrollView.scrollToPreviousItem(width: width)
        } else {
            scrollView.scrollToNextItem(width: width)
        }
    }
    
    func addChartViews() {
        let awesomeEntry = setupDateEntry(paki: .awesome)
        let goodEntry = setupDateEntry(paki: .good)
        let mehEntry = setupDateEntry(paki: .meh)
        let badEntry = setupDateEntry(paki: .bad)
        let terribleEntry = setupDateEntry(paki: .terrible)
        let noneEntry = setupDateEntry(paki: .none)
        
        numberOfPakiEntries = [awesomeEntry, goodEntry, mehEntry, badEntry, terribleEntry, noneEntry]
        
        let chartDataSet = PieChartDataSet(entries: numberOfPakiEntries)
        
        let pakiColors = [UIColor.getColorFor(paki: .awesome),
                          UIColor.getColorFor(paki: .good),
                          UIColor.getColorFor(paki: .meh),
                          UIColor.getColorFor(paki: .bad),
                          UIColor.getColorFor(paki: .terrible),
                          UIColor.tertiarySystemGroupedBackground]
        chartDataSet.colors = pakiColors
        chartDataSet.valueTextColor = .label
        chartDataSet.label = "Pakis"
        let chartData = PieChartData(dataSet: chartDataSet)

        pieChart.data = chartData
        pieChart.holeColor = .systemBackground
        pieChart.legend.textColor = .label
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .percent
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        statsTableView.backgroundColor = .clear
        statsTableView.register(StatsTableViewCell.nib, forCellReuseIdentifier: StatsTableViewCell.className)
        statsTableView.delegate = self
        statsTableView.dataSource = self
    }
    
    fileprivate func setupDateEntry(paki: Paki) -> PieChartDataEntry {
        let dataEntry = PieChartDataEntry(value: 0)
        
        let value = testPaki.filter({$0 == paki}).count
        dataEntry.value = Double(value)/Double(testPaki.count)

        return dataEntry
    }
    
    func addGridViews() {
        let width = view.frame.width / 10
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        for paki in testPaki {
            if x == 10 {
                x = 0
                y += 1
            }
            
            let pakiView = PakiView()
            pakiView.setupView(with: paki)
            pakiView.frame = CGRect(x: x * width, y: y * width, width: width, height: width)
            gridViewContainer.addSubview(pakiView)
            
            let key = "\(Int(x))\(Int(y))"
            pakiViews[key] = pakiView
            
            x += 1
        }
        
        gridViewContainer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:))))
        gridViewContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:))))
    }
    
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        let width = view.frame.width / 10
        let location = gesture.location(in: gridViewContainer)
        
        let x = Int(location.x / width)
        let y = Int(location.y / width)
        let key = "\(x)\(y)"
        
        if let pakiView = pakiViews[key] {
            self.selectedPaki = pakiView
            presentCalendarVC()
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        let width = view.frame.width / 10
        let location = gesture.location(in: gridViewContainer)
        
        let x = Int(location.x / width)
        let y = Int(location.y / width)
        
        let key = "\(x)\(y)"
        if let pakiView = pakiViews[key] {
            
            self.gridTimer?.invalidate()
            self.gridTimer = nil
            
            if selectedPaki != pakiView {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.selectedPaki?.layer.transform = CATransform3DIdentity
                    self.selectedPaki?.layer.borderColor = UIColor.systemBackground.cgColor
                }, completion: nil)
            }
            
            selectedPaki = pakiView
            
            gridViewContainer.bringSubviewToFront(pakiView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                pakiView.layer.transform = CATransform3DMakeScale(3, 3, 3)
                pakiView.layer.borderColor = UIColor.label.cgColor
            }, completion: { (_) in
                
            })
            
            if gesture.state == .ended {
                UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    pakiView.layer.transform = CATransform3DIdentity
                    pakiView.layer.borderColor = UIColor.systemBackground.cgColor
                }, completion: { (_) in
                    self.gridTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                        timer.invalidate()
                        self.gridTimer?.invalidate()
                        self.presentCalendarVC()
                    })
                })
            }
            
        }
    }
    
    fileprivate func presentCalendarVC() {
        let calendarVC = self.storyboard?.instantiateViewController(identifier: CalendarVC.className) as! CalendarVC
        calendarVC.testPakis = testPaki
        calendarVC.transitioningDelegate = self
        calendarVC.modalPresentationStyle = .custom
        self.present(calendarVC, animated: true, completion: nil)
    }
    
    func pakiViewCenterPoint() -> CGPoint? {
        let frameRelativeToVC = gridViewContainer.convert(selectedPaki!.frame.origin, from: self.view)
        print("Frame \(frameRelativeToVC)")
        return frameRelativeToVC
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate
extension ProfileVC: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = self.pakiViewCenterPoint() ?? startingPoint
        transition.bubbleColor = .systemBackground
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = startingPoint
        transition.bubbleColor = .systemBackground
        return transition
    }
}

// MARK: - UITableView
extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pakis.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentPaki = pakis[indexPath.row]
        let pakiCount = testPaki.filter({$0 == currentPaki}).count
        
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.className) as! StatsTableViewCell
        cell.totalCount = testPaki.count
        cell.setupCell(withPaki: currentPaki, count: pakiCount)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = tableView.frame.height / 5
        return rowHeight
    }
    
    
}
