//
//  PlayerListViewController.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import UIKit

class PlayerListViewController: UIViewController {
    
    private var tableView: UITableView!
    private var vm: PlayerListViewModel!
    
    init(vm: PlayerListViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.title = vm.displayTitle
        self.vm = vm
        self.setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupTableView() {
        self.tableView = UITableView(frame: CGRect(x: 0, y: 10, width: self.view.frame.size.width, height:self.view.frame.size.height))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "playerCell")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.view.addSubview(self.tableView)
    }
}

extension PlayerListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.vm.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playerCell", for: indexPath)
        let playerItem = self.vm.vmAtIndex(indexPath.row)
        cell.textLabel?.text = playerItem.displayString
        return cell
    }
}
