//
//  ContentView.swift
//  simula
//
//  Created by Caio Henrique Andrade Lima on 06/04/26.
//

import SwiftUI
#if canImport(SimulaMiniGameSDK)
import SimulaMiniGameSDK
#endif

struct ContentView: View {
    var body: some View {
        #if canImport(SimulaMiniGameSDK)
        SimulaMiniGameMenuSDKView(
            configuration: .init(apiKey: "pub_eeee14c661ce47659a289db29364723a"),
            character: .init(
                charID: "char-123",
                charName: "Maya",
                charImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=512",
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
        #else
        VStack(spacing: 12) {
            Text("SimulaMiniGameSDK is not linked yet.")
                .font(.headline)
            Text("In Xcode: File > Add Package Dependencies... > Add Local... and select SimulaMiniGameSDK.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        #endif
    }
}

#Preview {
    ContentView()
}
