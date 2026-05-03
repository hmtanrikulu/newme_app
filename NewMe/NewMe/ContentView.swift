import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                Text("NewMe")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                Text("Iskelet hazır — ekranlar geliyor.")
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

#Preview {
    ContentView()
}
