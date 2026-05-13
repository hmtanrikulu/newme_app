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
            SpendLogEntry.self,
            UserGoals.self,
            ManualFoodEntry.self,
        ])
        do {
            // .automatic picks up the iCloud container declared in entitlements;
            // SwiftData falls back to local-only when CloudKit is unreachable.
            let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("ModelContainer init failed: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .task {
                    SeedData.seedIfNeeded(container.mainContext)
                }
        }
        .modelContainer(container)
    }
}
