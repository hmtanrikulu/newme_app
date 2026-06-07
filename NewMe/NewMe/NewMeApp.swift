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
                // Warm amber accent — the single brand color; everything else is system-adaptive
                .tint(Color(red: 0.80, green: 0.67, blue: 0.38))
                .task {
                    SeedData.seedIfNeeded(container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
