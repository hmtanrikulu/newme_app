import SwiftUI
import SwiftData

@main
struct NewMeApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([
            FoodItem.self,
            ExerciseItem.self,
            FoodLogEntry.self,
            FitnessLogEntry.self,
            WorkoutSession.self,
            SpendLogEntry.self,
            UserGoals.self,
            ManualFoodEntry.self,
        ])
        do {
            let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color(red: 0.40, green: 0.32, blue: 0.85))
                .task {
                    SeedData.seedIfNeeded(container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
