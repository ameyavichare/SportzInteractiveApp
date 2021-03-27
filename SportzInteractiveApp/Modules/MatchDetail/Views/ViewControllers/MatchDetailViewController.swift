//
//  MatchDetailViewController.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import UIKit
import Combine
import Parchment

class MatchDetailViewController: UIViewController {
    
    //MARK:- Properties
    private var vm: MatchDetailViewModel!
    private var cancellables: Set<AnyCancellable> = []
    private var margin: CGFloat = 20
    
    ///Paging view properties
    private var pagingViewController: PagingViewController!
    private var viewControllers: [UIViewController] = []
    
    //MARK:- Overriding Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupVM()
        self.bindVM()
        self.setupUI()
    }
    
    //MARK:- Binding
    private func bindVM() {
        self.vm.$matchDataSource.sink { [weak self] (matchDataSource) in
            guard let self = self else { return }
            if let source = matchDataSource {
                self.viewControllers.append(PlayerListViewController(vm: source.homeTeamDatasource))
                self.viewControllers.append(PlayerListViewController(vm: source.awayTeamDatasource))
                self.setupParchment()
            }
        }
        .store(in: &cancellables)
    }
    
    //MARK:- Setup Methods
    
    private func setupUI() {
        self.navigationItem.title = self.vm.navigationTitle
        self.view.backgroundColor = .white
    }
    
    private func setupVM() {
        self.vm = MatchDetailViewModel()
        self.vm.viewDidLoad()
    }
    
    private func setupParchment() {
        pagingViewController = PagingViewController(viewControllers: viewControllers)
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        self.layoutParchment()
    }
    
    private func layoutParchment() {
        self.pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pagingViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: margin).isActive = true
        self.pagingViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -margin).isActive = true
        self.pagingViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: margin).isActive = true
        self.pagingViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -margin).isActive = true
    }
}
