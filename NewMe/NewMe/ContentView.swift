import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            FoodItem.self, ExerciseItem.self,
            FoodLogEntry.self, FitnessLogEntry.self,
            SpendLogEntry.self, UserGoals.self,
        ], inMemory: true)
}
