import Foundation
import SwiftData

enum SeedData {
    private static let didSeedKey = "newme.didSeed.v1"
    private static let didMigratePer100Key = "newme.didMigratePer100.v1"

    /// Insert the prototype's default catalog + goals on first launch.
    /// CloudKit may sync remote data later; flag prevents duplicate seeds.
    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        let defaults = UserDefaults.standard
        migrateToPer100IfNeeded(context, defaults: defaults)
        guard !defaults.bool(forKey: didSeedKey) else { return }

        // Goals — singleton
        if (try? context.fetch(FetchDescriptor<UserGoals>()))?.isEmpty ?? true {
            context.insert(UserGoals())
        }

        // Foods — macro values are per 100 g (canonical). servingSize = portion in `unit`,
        // gramsPerUnit = grams in one unit (1 for g/ml; user-set for adet/dilim).
        let foods: [FoodItem] = [
            .init(name: "Yumurta",       kcalPerServing: 155, protein: 13,   carbs: 1.1, fat: 11,  unit: "adet",  gramsPerUnit: 50,  servingSize: 1,   sortOrder: 0),
            .init(name: "Ekmek",         kcalPerServing: 265, protein: 9,    carbs: 49,  fat: 3.2, unit: "dilim", gramsPerUnit: 30,  servingSize: 1,   sortOrder: 1),
            .init(name: "Yoğurt",        kcalPerServing: 60,  protein: 4,    carbs: 5,   fat: 3,   unit: "g",     gramsPerUnit: 1,   servingSize: 100, sortOrder: 2),
            .init(name: "Tavuk göğsü",   kcalPerServing: 165, protein: 31,   carbs: 0,   fat: 3.6, unit: "g",     gramsPerUnit: 1,   servingSize: 100, sortOrder: 3),
            .init(name: "Pirinç",        kcalPerServing: 130, protein: 2.7,  carbs: 28,  fat: 0.3, unit: "g",     gramsPerUnit: 1,   servingSize: 100, sortOrder: 4),
            .init(name: "Yulaf sütü",    kcalPerServing: 50,  protein: 1,    carbs: 7,   fat: 1.5, unit: "ml",    gramsPerUnit: 1,   servingSize: 100, sortOrder: 5),
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
            // Newly seeded data is already in per-100g form — skip the migration.
            defaults.set(true, forKey: didMigratePer100Key)
        } catch {
            print("SeedData save failed: \(error)")
        }
    }

    /// Convert any pre-existing FoodItem rows from per-portion semantics to per-100g.
    /// Why: macro fields used to mean "per 1 serving (servingSize unit)"; they now mean
    /// "per 100 g". This rewrites old values so historical log totals stay numerically
    /// identical: kcalLog = quantity × portionGrams/100 × per100g, with portionGrams =
    /// servingSize × gramsPerUnit.
    @MainActor
    private static func migrateToPer100IfNeeded(_ context: ModelContext, defaults: UserDefaults) {
        guard !defaults.bool(forKey: didMigratePer100Key) else { return }
        guard let foods = try? context.fetch(FetchDescriptor<FoodItem>()) else { return }

        for food in foods {
            let serving = food.servingSize == 0 ? 1 : food.servingSize
            switch food.unit {
            case "g", "ml":
                // Old values were per `serving` units of g/ml. Rescale to per-100.
                let factor = 100.0 / serving
                food.kcalPerServing *= factor
                food.protein        *= factor
                food.carbs          *= factor
                food.fat             *= factor
                food.gramsPerUnit = 1
            default:
                // adet / dilim: real grams-per-unit unknown. Pick gramsPerUnit so the
                // existing per-portion totals are preserved: portionGrams = 100, which
                // makes portionFactor = 1 and per-portion macros == stored values.
                food.gramsPerUnit = 100.0 / serving
            }
        }

        do {
            try context.save()
            defaults.set(true, forKey: didMigratePer100Key)
        } catch {
            print("Per-100g migration save failed: \(error)")
        }
    }
}
