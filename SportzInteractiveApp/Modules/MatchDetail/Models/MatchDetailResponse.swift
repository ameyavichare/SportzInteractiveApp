//
//  MatchDetailResponse.swift
//  SportzInteractiveApp
//
//  Created by Ameya Vichare on 27/03/21.
//

import Foundation

struct MatchDetailResponse: Codable {
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("MatchDetailResponse")

    var homeTeam: Team?
    var awayTeam: Team?
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "homeTeam"
        case awayTeam = "awayTeam"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(homeTeam, forKey: .homeTeam)
        try container.encode(awayTeam, forKey: .awayTeam)
    }
    
    init(homeTeam: Team?, awayTeam: Team?) {
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
    }

    private enum TopLevelKeys: String, CodingKey {
        case teams = "Teams"
        case matchDetail = "Matchdetail"
    }
    
    private enum MatchDetailKeys: String, CodingKey {
        case homeTeam = "Team_Home"
        case awayTeam = "Team_Away"
    }
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        
        let storedContainer = try decoder.container(keyedBy: CodingKeys.self)

        if storedContainer.allKeys.count == 0 {
            
            let container = try decoder.container(keyedBy: TopLevelKeys.self)
            let matchDetailContainer = try container.nestedContainer(keyedBy: MatchDetailKeys.self, forKey: .matchDetail)
            let homeTeamId = try matchDetailContainer.decode(String.self, forKey: MatchDetailKeys.homeTeam)
            let awayTeamId = try matchDetailContainer.decode(String.self, forKey: MatchDetailKeys.awayTeam)

            let teamContainer = try container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .teams)
            //Assign the home team & away team
            for key in teamContainer.allKeys {
                if key.stringValue == homeTeamId {
                    homeTeam = try teamContainer.decode(Team.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
                }
                else if key.stringValue == awayTeamId {
                    awayTeam = try teamContainer.decode(Team.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
                }
            }
        }
        else {
            homeTeam = try storedContainer.decode(Team.self, forKey: .homeTeam)
            awayTeam = try storedContainer.decode(Team.self, forKey: .awayTeam)
        }
    }
}

struct Team: Codable {

    var id: String = ""
    var fullName: String = ""
    var shortName: String = ""
    var players: [Player] = []
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case fullName = "fullName"
        case shortName = "shortName"
        case players = "players"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(shortName, forKey: .shortName)
        try container.encode(players, forKey: .players)
    }

    private enum TopLevelKeys: String, CodingKey {
        case fullName = "Name_Full"
        case shortName = "Name_Short"
        case players = "Players"
    }

    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        
        let storedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        if storedContainer.allKeys.count == 0 {
            let container = try decoder.container(keyedBy: TopLevelKeys.self)
            fullName = try container.decode(String.self, forKey: .fullName)
            shortName = try container.decode(String.self, forKey: .shortName)

            //get the id using the coding path
            container.codingPath.indices.contains(0) ? (id = container.codingPath[0].stringValue) : (id = "")

            let playerContainer = try container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .players)
            players = try playerContainer.allKeys.map {
                try playerContainer.decode(Player.self, forKey: $0)
            }
        }
        else {
            
            id = try storedContainer.decode(String.self, forKey: .id)
            fullName = try storedContainer.decode(String.self, forKey: .fullName)
            shortName = try storedContainer.decode(String.self, forKey: .shortName)
            players = try storedContainer.decode([Player].self, forKey: .players)
        }
    }
}

enum PlayerType: String, Codable {

    case normal
    case wicketKeeper
    case captain
}

struct Player: Codable {

    var position: String = ""
    var fullName: String = ""
    var type: [PlayerType] = []
    
    enum CodingKeys: String, CodingKey {
        case position = "position"
        case fullName = "fullName"
        case type = "type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position, forKey: .position)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(type, forKey: .type)
    }

    private enum TopLevelKeys: String, CodingKey {

        case position = "Position"
        case fullName = "Name_Full"
        case Iskeeper = "Iskeeper"
        case Iscaptain = "Iscaptain"
    }

    init(from decoder: Decoder) throws {
        
        let storedContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        if storedContainer.allKeys.count == 0 {
            
            let container = try decoder.container(keyedBy: TopLevelKeys.self)
            position = try container.decode(String.self, forKey: .position)
            fullName = try container.decode(String.self, forKey: .fullName)

            //append player type if player is wk or c or else append normal
            if let wk = try container.decodeIfPresent(Bool.self, forKey: .Iskeeper) {
                if wk {
                    type.append(.wicketKeeper)
                }
            }

            if let captain = try container.decodeIfPresent(Bool.self, forKey: .Iscaptain) {
                if captain {
                    type.append(.captain)
                }
            }

            if type.count == 0 {
                type.append(.normal)
            }
        }
        else {
            
            position = try storedContainer.decode(String.self, forKey: .position)
            fullName = try storedContainer.decode(String.self, forKey: .fullName)
            type = try storedContainer.decode([PlayerType].self, forKey: .type)
        }
    }
}
