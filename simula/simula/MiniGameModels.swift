import Foundation

struct MessageDTO: Codable, Sendable {
    let role: String
    let content: String
}

struct GameDTO: Codable, Sendable {
    let id: String
    let name: String
    let iconURL: String
    let description: String
    let iconFallback: String?
    let gifCover: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconURL = "icon"
        case description
        case iconFallback
        case gifCover = "gif_cover"
    }
}

struct CatalogResponseDTO: Decodable, Sendable {
    let menuID: String?
    let games: [GameDTO]

    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case catalog
        case data
    }

    enum CatalogContainer: Decodable {
        case array([GameDTO])
        case object(CatalogDataContainer)

        struct CatalogDataContainer: Decodable {
            let data: [GameDTO]
        }

        init(from decoder: Decoder) throws {
            let single = try decoder.singleValueContainer()
            if let array = try? single.decode([GameDTO].self) {
                self = .array(array)
                return
            }
            self = .object(try single.decode(CatalogDataContainer.self))
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        menuID = try container.decodeIfPresent(String.self, forKey: .menuID)

        if let catalog = try container.decodeIfPresent(CatalogContainer.self, forKey: .catalog) {
            switch catalog {
            case .array(let items):
                games = items
            case .object(let wrapped):
                games = wrapped.data
            }
        } else if let legacy = try container.decodeIfPresent([GameDTO].self, forKey: .data) {
            games = legacy
        } else {
            games = []
        }
    }
}

struct InitMinigameRequestDTO: Codable, Sendable {
    let gameType: String
    let sessionID: String
    let convID: String?
    let entryPoint: String?
    let currencyMode: Bool
    let width: Int
    let height: Int
    let charID: String?
    let charName: String?
    let charImage: String?
    let charDescription: String?
    let messages: [MessageDTO]
    let delegateChar: Bool
    let menuID: String?

    enum CodingKeys: String, CodingKey {
        case gameType = "game_type"
        case sessionID = "session_id"
        case convID = "conv_id"
        case entryPoint = "entry_point"
        case currencyMode = "currency_mode"
        case width = "w"
        case height = "h"
        case charID = "char_id"
        case charName = "char_name"
        case charImage = "char_image"
        case charDescription = "char_desc"
        case messages
        case delegateChar = "delegate_char"
        case menuID = "menu_id"
    }
}

struct MinigameResponseDTO: Decodable, Sendable {
    let adType: String
    let adInserted: Bool
    let adResponse: MinigameAdResponseDTO
}

struct MinigameAdResponseDTO: Decodable, Sendable {
    let adID: String
    let iframeURL: String

    enum CodingKeys: String, CodingKey {
        case adID = "ad_id"
        case iframeURL = "iframe_url"
    }
}

struct TrackMenuClickRequestDTO: Codable, Sendable {
    let menuID: String
    let gameName: String

    enum CodingKeys: String, CodingKey {
        case menuID = "menu_id"
        case gameName = "game_name"
    }
}

struct SessionResponseDTO: Decodable, Sendable {
    let sessionID: String

    enum CodingKeys: String, CodingKey {
        case sessionID = "sessionId"
    }
}

struct MiniGameCatalogResult: Sendable {
    let menuID: String?
    let games: [GameDTO]
}
