import XCTest
@testable import SimulaMiniGameSDK

final class CatalogDecodingTests: XCTestCase {
    func testCatalogDecodesArrayShape() throws {
        let json = """
        {
          "menu_id": "menu-1",
          "catalog": [
            {
              "id": "game-1",
              "name": "Memory",
              "icon": "https://example.com/icon.png",
              "description": "desc",
              "gif_cover": "https://example.com/gif.gif"
            }
          ]
        }
        """
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(CatalogResponseDTO.self, from: data)

        XCTAssertEqual(decoded.menuID, "menu-1")
        XCTAssertEqual(decoded.games.count, 1)
        XCTAssertEqual(decoded.games.first?.id, "game-1")
    }

    func testCatalogDecodesNestedDataShape() throws {
        let json = """
        {
          "menu_id": "menu-2",
          "catalog": {
            "data": [
              {
                "id": "game-2",
                "name": "Puzzle",
                "icon": "https://example.com/icon2.png",
                "description": "desc"
              }
            ]
          }
        }
        """
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(CatalogResponseDTO.self, from: data)

        XCTAssertEqual(decoded.menuID, "menu-2")
        XCTAssertEqual(decoded.games.count, 1)
        XCTAssertEqual(decoded.games.first?.name, "Puzzle")
    }
}
