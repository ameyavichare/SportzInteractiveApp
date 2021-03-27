//
//  PlayerListViewModel.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import Foundation

//parent
class PlayerListViewModel {
    
    private var playerViewModels: [PlayerViewModel] = []
    private var teamName: String = ""
    
    init(vm: [PlayerViewModel], teamName: String) {
        self.playerViewModels = vm
        self.teamName = teamName
    }
}

extension PlayerListViewModel {
    
    var numberOfSections: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        
        return self.playerViewModels.count
    }
    
    func vmAtIndex(_ index: Int) -> PlayerViewModel {
        
        return self.playerViewModels[index]
    }
    
    var displayTitle: String {
        return self.teamName
    }
}

//child

struct PlayerViewModel {
    
    private var player: Player
}

extension PlayerViewModel {
    
    init(_ player: Player) {
        self.player = player
    }
}

extension PlayerViewModel {
    
    var displayString: String {
        
        var displayStr = self.player.fullName
        
        if player.type.contains(.captain) {
            
            displayStr += " (c)"
        }
        if player.type.contains(.wicketKeeper) {
            
            displayStr += " (wk)"
        }
        
        return displayStr
    }
}
