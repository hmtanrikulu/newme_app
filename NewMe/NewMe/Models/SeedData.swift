import Foundation
import SwiftData

enum SeedData {
    private static let didSeedKey = "newme.didSeed.v1"

    /// Insert the prototype's default catalog + goals on first launch.
    /// CloudKit may sync remote data later; flag prevents duplicate seeds.
    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: didSeedKey) else { return }

        // Goals — singleton
        if (try? context.fetch(FetchDescriptor<UserGoals>()))?.isEmpty ?? true {
            context.insert(UserGoals())
        }

        // Foods
        let foods: [FoodItem] = [
            .init(name: "Yumurta",       kcalPerServing: 78,  protein: 6,    carbs: 0.6, fat: 5,   unit: "adet",  servingSize: 1,   sortOrder: 0),
            .init(name: "Ekmek",         kcalPerServing: 80,  protein: 3,    carbs: 15,  fat: 1,   unit: "dilim", servingSize: 1,   sortOrder: 1),
            .init(name: "Yoğurt",        kcalPerServing: 60,  protein: 4,    carbs: 5,   fat: 3,   unit: "g",     servingSize: 100, sortOrder: 2),
            .init(name: "Tavuk göğsü",   kcalPerServing: 165, protein: 31,   carbs: 0,   fat: 3.6, unit: "g",     servingSize: 100, sortOrder: 3),
            .init(name: "Pirinç",        kcalPerServing: 130, protein: 2.7,  carbs: 28,  fat: 0.3, unit: "g",     servingSize: 100, sortOrder: 4),
            .init(name: "Yulaf sütü",    kcalPerServing: 50,  protein: 1,    carbs: 7,   fat: 1.5, unit: "ml",    servingSize: 100, sortOrder: 5),
        ]
        foods.forEach(context.insert)

        // Exercises
        let exercises: [ExerciseItem] = [
            .init(name: "Bench Press",     muscleGroup: "Göğüs", sortOrder: 0),
            .init(name: "Squat",           muscleGroup: "Bacak", sortOrder: 1),
            .init(name: "Deadlift",        muscleGroup: "Sırt",  sortOrder: 2),
            .init(name: "Pull Up",         muscleGroup: "Sırt",  sortOrder: 3),
            .init(name: "Push Ups",        muscleGroup: "Göğüs", sortOrder: 4),
            .init(name: "Shoulder Press",  muscleGroup: "Omuz",  sortOrder: 5),
            .init(name: "Bicep Curl",      muscleGroup: "Kol",   sortOrder: 6),
            .init(name: "Plank",           muscleGroup: "Core",  sortOrder: 7),
        ]
        exercises.forEach(context.insert)

        do {
            try context.save()
            defaults.set(true, forKey: didSeedKey)
        } catch {
            print("SeedData save failed: \(error)")
        }
    }
}
