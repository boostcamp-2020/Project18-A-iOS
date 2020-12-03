//
//  HistoryListViewController.swift
//  BoostPocket
//
//  Created by 송주 on 2020/12/02.
//  Copyright © 2020 BoostPocket. All rights reserved.
//

class HistoryListSectionHeader: Hashable {
    static func == (lhs: HistoryListSectionHeader, rhs: HistoryListSectionHeader) -> Bool {
        return lhs.dayNumber == rhs.dayNumber
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dayNumber)
    }
    
    var dayNumber: Int?
    var date: Date
    var amount: Double
    
    init(dayNumber: Int?, date: Date, amount: Double) {
        self.dayNumber = dayNumber
        self.date = date
        self.amount = amount
    }
}

import UIKit

class HistoryListViewController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<HistoryListSectionHeader, HistoryItemViewModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<HistoryListSectionHeader, HistoryItemViewModel>
    
    @IBOutlet weak var historyListTableView: UITableView!

    private lazy var dataSource = configureDatasource()
    private lazy var headers = setupSection(with: travelItemViewModel?.histories ?? [])
    weak var travelItemViewModel: HistoryListPresentable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        travelItemViewModel?.createHistory(id: UUID(), isIncome: true, title: "새 히스토리", memo: "ㅁㄴㅇㄹ", date: Date(), image: Data(), amount: 12000, category: .etc, isPrepare: false, isCard: true) { _ in
            print("성공")
        }
        
        travelItemViewModel?.createHistory(id: UUID(), isIncome: true, title: "새 히스토리2", memo: "ㅁㄴㅇㄹ2", date: Date(), image: Data(), amount: 14000, category: .etc, isPrepare: false, isCard: true) { _ in
            print("성공")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        travelItemViewModel?.needFetchItems()
        travelItemViewModel?.didFetch = { [weak self] fetchedHistories in
            self?.historyListTableView.reloadData()
            self?.applySnapshot(with: fetchedHistories)
        }
    }

    private func configureTableView() {
        historyListTableView.delegate = self
        historyListTableView.register(HistoryCell.getNib(), forCellReuseIdentifier: HistoryCell.identifier)
        historyListTableView.register(HistoryHeaderCell.getNib(), forHeaderFooterViewReuseIdentifier: HistoryHeaderCell.identifier)
    }
    
    private func configureDatasource() -> DataSource {
        let datasource = DataSource(tableView: historyListTableView) { (tableview, indexPath, item) -> UITableViewCell? in
            print(item.category.name)
            guard let cell = tableview.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as? HistoryCell else { return UITableViewCell() }
            cell.configure(with: item)
            
            return cell
        }
        return datasource
    }
    
    private func applySnapshot(with histories: [HistoryItemViewModel]) {
        var snapshot = Snapshot()
        snapshot.appendSections(headers)
        histories.forEach { history in
            if let section = headers.filter({ Calendar.current.isDate(history.date, inSameDayAs: $0.date) }).first {
                snapshot.appendItems([history], toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupSection(with histories: [HistoryItemViewModel]) -> [HistoryListSectionHeader] {
        var dayNumber = 1
        var days = Set<HistoryListSectionHeader>()
        histories.forEach { history in
            let amount = history.amount
            let date = history.date
            // TODO: daynumber는 현재 날짜 - travelItemViewModel의 시작 날짜 + 1, 만약 음수면 prepare로 들어감
            if let day = days.filter({ Calendar.current.isDate(date, inSameDayAs: $0.date) }).first {
                day.amount += amount
            } else {
                days.insert(HistoryListSectionHeader(dayNumber: dayNumber, date: date, amount: amount))
                dayNumber += 1
            }
        }
        var sections = [HistoryListSectionHeader](days)
        sections = sections.sorted(by: {$0.date < $1.date})
        return sections
    }
}

extension HistoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryHeaderCell.identifier) as? HistoryHeaderCell else { return UIView() }
        headerView.configure(with: headers[section].dayNumber, date: headers[section].date, amount: headers[section].amount)
        return headerView
    }
}