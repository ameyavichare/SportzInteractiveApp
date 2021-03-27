//
//  MatchDetailViewModel.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import Foundation
import Combine

class MatchDetailDataSource {
    
    private(set) var homeTeamDatasource: PlayerListViewModel
    private(set) var awayTeamDatasource: PlayerListViewModel
    
    init(_ homeTeamDatasource: PlayerListViewModel, awayTeamDatasource: PlayerListViewModel) {
        self.homeTeamDatasource = homeTeamDatasource
        self.awayTeamDatasource = awayTeamDatasource
    }
}

class MatchDetailViewModel: ObservableObject {
    
    private(set) var navigationTitle = "Match Detail"
    private var cancellables: Set<AnyCancellable> = []
    private var response: MatchDetailResponse?
    @Published private(set) var matchDataSource: MatchDetailDataSource?
}

extension MatchDetailViewModel {
    
    //VC'S view has loaded
    func viewDidLoad() {
       
        let storedData = self.loadMatchData()
        
        //Check if data is already there, if not call api
        if let data = storedData {
            
            self.response = data
            self.prepareDatasource()
        }
        else {
            
            self.getMatchDetailData()
        }
    }
    
    private func getMatchDetailData() {
        guard let url = URL(string: WebServiceConstants.baseUrl + WebServiceConstants.matchDetailApi) else { return }
        let resource = Resource<MatchDetailResponse>(url: url)
        
        WebService.shared.load(resource)
            .sink { (_) in } receiveValue: { [weak self] (response) in
                self?.response = response
                self?.prepareDatasource()
                self?.storeMatchData()
            }
            .store(in: &cancellables)
    }
}

//MARK:- Datasource preparation
extension MatchDetailViewModel {
    
    private func prepareDatasource() {
        
        guard let response = self.response, let homeTeam = response.homeTeam, let awayTeam = response.awayTeam else { return }
        //sorting based on position
        let sortedHomeTeam = homeTeam.players.sorted { (Int($0.position) ?? 0) < (Int($1.position) ?? 0) }
        let sortedAwayTeam = awayTeam.players.sorted { (Int($0.position) ?? 0) < (Int($1.position) ?? 0) }
        let homeTeamDataSource = PlayerListViewModel(vm: (sortedHomeTeam.map { PlayerViewModel($0) }), teamName: homeTeam.fullName)
        let awayTeamDataSource = PlayerListViewModel(vm: (sortedAwayTeam.map { PlayerViewModel($0) }), teamName: awayTeam.fullName)
        self.matchDataSource = MatchDetailDataSource(homeTeamDataSource, awayTeamDatasource: awayTeamDataSource)
    }
}

//MARK:- Data persistance
extension MatchDetailViewModel {
    
    private func storeMatchData() {
        
        guard let response = self.response else { return }
        do {
            let data = try PropertyListEncoder().encode(response)
            let archivedData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            try archivedData.write(to: MatchDetailResponse.ArchiveURL)
        } catch {
            print("Save Failed.")
        }
    }
    
    private func loadMatchData() -> MatchDetailResponse? {
        
        guard let nsData = NSData(contentsOf: MatchDetailResponse.ArchiveURL) else { return nil }
        do {
            let data = Data(referencing:nsData)
            if let response = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? MatchDetailResponse {
            return response
        }
        } catch {
            print("No file found.")
            return nil
        }
        return nil
    }
}
