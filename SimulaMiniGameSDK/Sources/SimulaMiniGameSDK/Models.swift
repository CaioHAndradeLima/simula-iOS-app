import Foundation

public struct SimulaMiniGameConfiguration: Sendable {
    public let apiKey: String
    public let baseURL: URL
    public let devMode: Bool
    public let primaryUserID: String?

    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://simula-api-701226639755.us-central1.run.app")!,
        devMode: Bool = false,
        primaryUserID: String? = nil
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.devMode = devMode
        self.primaryUserID = primaryUserID
    }
}

public struct MiniGameCharacterContext: Sendable {
    public let charID: String
    public let charName: String
    public let charImage: String
    public let charDescription: String?

    public init(charID: String, charName: String, charImage: String, charDescription: String? = nil) {
        self.charID = charID
        self.charName = charName
        self.charImage = charImage
        self.charDescription = charDescription
    }
}

public struct MiniGameMessage: Codable, Sendable {
    public let role: String
    public let content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct MiniGameLaunchContext: Sendable {
    public let conversationID: String?
    public let entryPoint: String?
    public let messages: [MiniGameMessage]
    public let delegateCharacter: Bool
    public let viewportWidth: Int
    public let viewportHeight: Int

    public init(
        conversationID: String? = nil,
        entryPoint: String? = nil,
        messages: [MiniGameMessage] = [],
        delegateCharacter: Bool = true,
        viewportWidth: Int,
        viewportHeight: Int
    ) {
        self.conversationID = conversationID
        self.entryPoint = entryPoint
        self.messages = messages
        self.delegateCharacter = delegateCharacter
        self.viewportWidth = viewportWidth
        self.viewportHeight = viewportHeight
    }
}

public struct MiniGame: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let iconURL: String
    public let description: String
    public let iconFallback: String?
    public let gifCover: String?
}

public enum MiniGameMenuLifecycleState: Equatable, Sendable {
    case idle
    case menuLoading
    case menuLoaded
    case menuEmpty
    case menuError(String)
    case gameLoading
    case gameShowing
    case adShowing
}

public struct SimulaMiniGameCallbacks {
    public let onGameOpen: ((MiniGame) -> Void)?
    public let onGameClose: ((MiniGame) -> Void)?
    public let onError: ((String) -> Void)?

    public init(
        onGameOpen: ((MiniGame) -> Void)? = nil,
        onGameClose: ((MiniGame) -> Void)? = nil,
        onError: ((String) -> Void)? = nil
    ) {
        self.onGameOpen = onGameOpen
        self.onGameClose = onGameClose
        self.onError = onError
    }
}

struct GameDTO: Codable, Sendable {
    let id: String
    let name: String
    let iconURL: String
    let description: String
    let iconFallback: String?
    let gifCover: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, iconFallback
        case iconURL = "icon"
        case gifCover = "gif_cover"
    }
}

struct CatalogResponseDTO: Decodable, Sendable {
    let menuID: String?
    let games: [GameDTO]

    enum CodingKeys: String, CodingKey { case menuID = "menu_id", catalog, data }

    enum CatalogContainer: Decodable {
        case array([GameDTO])
        case object(CatalogDataContainer)
        struct CatalogDataContainer: Decodable { let data: [GameDTO] }

        init(from decoder: Decoder) throws {
            let c = try decoder.singleValueContainer()
            if let arr = try? c.decode([GameDTO].self) { self = .array(arr); return }
            self = .object(try c.decode(CatalogDataContainer.self))
        }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        menuID = try c.decodeIfPresent(String.self, forKey: .menuID)
        if let catalog = try c.decodeIfPresent(CatalogContainer.self, forKey: .catalog) {
            switch catalog {
            case .array(let items): games = items
            case .object(let wrapped): games = wrapped.data
            }
        } else {
            games = try c.decodeIfPresent([GameDTO].self, forKey: .data) ?? []
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
    let messages: [MiniGameMessage]
    let delegateChar: Bool
    let menuID: String?

    enum CodingKeys: String, CodingKey {
        case gameType = "game_type", sessionID = "session_id", convID = "conv_id"
        case entryPoint = "entry_point", currencyMode = "currency_mode"
        case width = "w", height = "h", charID = "char_id", charName = "char_name"
        case charImage = "char_image", charDescription = "char_desc"
        case messages, delegateChar = "delegate_char", menuID = "menu_id"
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
    enum CodingKeys: String, CodingKey { case adID = "ad_id", iframeURL = "iframe_url" }
}

struct SessionResponseDTO: Decodable, Sendable {
    let sessionID: String
    enum CodingKeys: String, CodingKey { case sessionID = "sessionId" }
}

struct TrackMenuClickRequestDTO: Codable, Sendable {
    let menuID: String
    let gameName: String
    enum CodingKeys: String, CodingKey { case menuID = "menu_id", gameName = "game_name" }
}

extension GameDTO {
    func toDomain() -> MiniGame {
        MiniGame(id: id, name: name, iconURL: iconURL, description: description, iconFallback: iconFallback, gifCover: gifCover)
    }
}
