//
//  ReportView.swift
//  PakiApp
//
//  Created by Kem Belderol on 5/17/20.
//  Copyright © 2020 Krats. All rights reserved.
//

import UIKit

struct Report: Equatable {
    let report: String
    let color: Paki
    let imageName: String
}

protocol ReportViewProtocol: class {
    func didSubmitReportUser(post: UserPost)
}

class ReportView: UIView, Reusable {
    
    @IBOutlet weak var containerView: ViewX!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reportButton: ButtonX!
    
    weak var delegate: ReportViewProtocol?
    var reportedPost: UserPost!
    var selectedReport: Report?
    
    var reports: [Report] = [Report(report: "Spam/Bot Account", color: .good, imageName: "report-bot"),
                             Report(report: "Abusive Content", color: .terrible, imageName: "report-abusive"),
                             Report(report: "Inappropriate Text", color: .bad, imageName: "report-inappropriate"),
                             Report(report: "Asking private information", color: .meh, imageName: "report-privacy")]
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupXib() {
        self.alpha = 0
        reportButton.backgroundColor = UIColor.systemPink
        containerView.backgroundColor = UIColor.defaultBGColor
        tableView.backgroundColor = .clear
        tableView.register(ReportTableViewCell.nib, forCellReuseIdentifier: ReportTableViewCell.className)
        tableView.delegate = self
        tableView.dataSource = self
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1
        }) { (_) in
        }
    }
    
    @IBAction func didTapReport(_ sender: ButtonX) {
        self.delegate?.didSubmitReportUser(post: reportedPost)
        self.removeFromSuperview()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
}

extension ReportView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = tableView.frame.size.height / CGFloat(reports.count)
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReport = reports[indexPath.row]
        reportButton.backgroundColor = .systemPink
        reportButton.isUserInteractionEnabled = true
        tableView.reloadData()
    }
    
}

extension ReportView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let report = reports[indexPath.row]
        let reportCell = tableView.dequeueReusableCell(withIdentifier: ReportTableViewCell.className, for: indexPath) as! ReportTableViewCell
        reportCell.setupCell(report: report)
        
        if selectedReport == report {
            reportCell.containerView.layer.shadowRadius = 0
            reportCell.containerView.layer.shadowColor = UIColor.systemPink.cgColor
        } else {
            reportCell.containerView.layer.shadowRadius = 3
            reportCell.containerView.layer.shadowColor = UIColor.black.cgColor
        }
        
        return reportCell
    }

}
