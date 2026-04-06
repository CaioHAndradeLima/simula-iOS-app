# SimulaMiniGameSDK

Native iOS SwiftUI SDK for Simula mini-game menu and game/ad overlay flow.

## Requirements

- iOS 16+
- Swift 5.9+

## Install (local package)

In Xcode:

1. `File` -> `Add Package Dependencies...`
2. `Add Local...`
3. Select `SimulaMiniGameSDK`
4. Add product `SimulaMiniGameSDK` to your app target

If this repository's `simula.xcodeproj` is committed with package references, consumers in this repo should not need to do these steps manually.

## Quick Start

```swift
import SwiftUI
import SimulaMiniGameSDK

struct ContentView: View {
    var body: some View {
        SimulaMiniGameMenuSDKView(
            configuration: .init(apiKey: "YOUR_API_KEY"),
            character: .init(
                charID: "char-123",
                charName: "Maya",
                charImage: "https://example.com/maya.png",
                charDescription: "AI companion"
            ),
            contextBuilder: { size in
                .init(
                    conversationID: "conv-1",
                    entryPoint: "ios-sdk",
                    messages: [.init(role: "user", content: "Let's play a game")],
                    delegateCharacter: true,
                    viewportWidth: Int(size.width),
                    viewportHeight: Int(size.height)
                )
            }
        )
    }
}
```

## Versioning

Use semantic versioning tags when publishing:

- `v1.0.0` initial stable release
- `v1.1.0` backward-compatible feature additions
- `v2.0.0` breaking API changes

## Notes

- The SDK internally handles session creation, catalog loading, game initialization, and fallback ad flow.
- Ad close is countdown-gated to align with current React behavior.
