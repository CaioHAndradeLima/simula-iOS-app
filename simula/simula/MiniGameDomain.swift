import Foundation

struct MiniGame: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let iconURL: String
    let description: String
    let iconFallback: String?
    let gifCover: String?
}

struct MiniGameCharacterContext: Sendable {
    let charID: String
    let charName: String
    let charImage: String
    let charDescription: String?
}

struct MiniGameLaunchContext: Sendable {
    let conversationID: String?
    let entryPoint: String?
    let messages: [MessageDTO]
    let delegateCharacter: Bool
    let viewportWidth: Int
    let viewportHeight: Int
}

struct MiniGameLaunchResult: Sendable {
    let gameIframeURL: String
    let adID: String
}

extension GameDTO {
    func toDomain() -> MiniGame {
        MiniGame(
            id: id,
            name: name,
            iconURL: iconURL,
            description: description,
            iconFallback: iconFallback,
            gifCover: gifCover
        )
    }
}
