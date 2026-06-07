import Foundation
import SwiftData

enum SeedData {
    private static let didSeedKey = "newme.didSeed.v1"
    private static let didMigratePer100Key = "newme.didMigratePer100.v1"
    private static let didImportGarantiKey = "newme.didImportGaranti.v1"

    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        let defaults = UserDefaults.standard
        migrateToPer100IfNeeded(context, defaults: defaults)
        importGarantiStatements(context, defaults: defaults)
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

    // MARK: — Garanti BBVA Ekstre İthalatı (Mart–Mayıs 2026)

    @MainActor
    static func importGarantiStatements(_ context: ModelContext, defaults: UserDefaults = .standard) {
        guard !defaults.bool(forKey: didImportGarantiKey) else { return }

        // (dateString "yyyy-MM-dd", amount, category)
        let transactions: [(String, Double, SpendCategory)] = [

            // ── ŞUBAT / MART 2026 ──
            ("2026-02-27", 1500.00, .food),    ("2026-02-27", 1800.00, .food),
            ("2026-02-27",  105.00, .food),    ("2026-02-28",   80.40, .market),
            ("2026-02-28",   80.00, .fuel),    ("2026-02-28",  420.00, .food),
            ("2026-03-01",  570.65, .market),  ("2026-03-01",  312.35, .market),
            ("2026-03-01",  170.00, .food),    ("2026-03-02", 4166.68, .other),
            ("2026-03-02", 2004.00, .other),   ("2026-03-03", 1000.00, .fuel),
            ("2026-03-03",   56.45, .market),  ("2026-03-03",  370.00, .food),
            ("2026-03-03",  770.00, .food),    ("2026-03-04",  419.95, .market),
            ("2026-03-04",   71.14, .market),  ("2026-03-04",  360.00, .food),
            ("2026-03-05",  225.00, .fuel),    ("2026-03-05",  120.00, .fuel),
            ("2026-03-05",  360.00, .food),    ("2026-03-05",  560.00, .food),
            ("2026-03-05",  120.00, .other),   ("2026-03-05",  105.00, .other),
            ("2026-03-06",  300.48, .market),  ("2026-03-06",  375.00, .market),
            ("2026-03-06", 1000.00, .fuel),    ("2026-03-06",  325.00, .fuel),
            ("2026-03-06",   80.00, .other),   ("2026-03-06", 1499.87, .other),
            ("2026-03-07",  250.00, .food),    ("2026-03-07",  887.50, .food),
            ("2026-03-07",  590.00, .food),    ("2026-03-07",  340.00, .food),
            ("2026-03-08",  175.00, .fuel),    ("2026-03-08",  240.00, .food),
            ("2026-03-08",  800.00, .food),    ("2026-03-08",  800.00, .food),
            ("2026-03-09",  240.00, .food),    ("2026-03-09",  510.00, .food),
            ("2026-03-09",  460.00, .food),    ("2026-03-09", 1750.00, .entertainment),
            ("2026-03-09", 1122.71, .other),   ("2026-03-09", 1250.00, .other),
            ("2026-03-09", 42336.00, .entertainment), ("2026-03-09", 302.40, .food),
            ("2026-03-10",  105.00, .other),   ("2026-03-11", 1000.00, .fuel),
            ("2026-03-11",  195.00, .fuel),    ("2026-03-11",  244.40, .market),
            ("2026-03-11", 1779.64, .market),  ("2026-03-11",  145.00, .food),
            ("2026-03-12",  260.00, .other),   ("2026-03-12",  230.00, .other),
            ("2026-03-13",   62.00, .market),  ("2026-03-13", 1100.00, .food),
            ("2026-03-13",  827.50, .food),    ("2026-03-13",  220.00, .food),
            ("2026-03-13",  293.26, .market),  ("2026-03-13",  230.00, .market),
            ("2026-03-13",  500.00, .fuel),    ("2026-03-13", 1855.62, .clothing),
            ("2026-03-13",  124.99, .entertainment), ("2026-03-13", 220.00, .other),
            ("2026-03-14", 1000.00, .fuel),    ("2026-03-14",  190.00, .food),
            ("2026-03-14", 1205.00, .other),   ("2026-03-14",  302.40, .food),
            ("2026-03-15",  345.00, .food),    ("2026-03-15",  625.00, .food),
            ("2026-03-15",  105.00, .other),   ("2026-03-16",  882.31, .market),
            ("2026-03-16",  295.00, .food),    ("2026-03-16",  159.00, .other),
            ("2026-03-17",  425.00, .food),    ("2026-03-17",  163.43, .market),
            ("2026-03-17",  470.00, .other),   ("2026-03-18", 1020.00, .food),
            ("2026-03-18",  505.00, .food),    ("2026-03-18",  215.00, .fuel),
            ("2026-03-18", 1000.00, .fuel),    ("2026-03-18",  108.00, .other),
            ("2026-03-18",  180.00, .other),   ("2026-03-19", 1092.79, .market),
            ("2026-03-20", 3000.00, .entertainment), ("2026-03-20", 430.00, .food),
            ("2026-03-20",  160.00, .food),    ("2026-03-20",  105.00, .other),
            ("2026-03-21", 1397.88, .market),  ("2026-03-21",  135.00, .food),
            ("2026-03-21",  170.00, .food),    ("2026-03-21",  250.00, .food),
            ("2026-03-22",   60.00, .other),   ("2026-03-22",  340.11, .other),
            ("2026-03-22", 1320.00, .food),    ("2026-03-23",  320.00, .food),
            ("2026-03-23",  170.00, .food),    ("2026-03-23",  250.00, .other),
            ("2026-03-24", 3239.20, .entertainment), ("2026-03-25", 720.00, .food),
            ("2026-03-25",  250.00, .other),   ("2026-03-25", 3091.58, .other),
            ("2026-03-25",  105.00, .other),   ("2026-03-26",  412.95, .market),
            ("2026-03-26", 1666.00, .food),    ("2026-03-26",   84.00, .food),
            ("2026-03-26", 1695.94, .market),  ("2026-03-26", 1000.00, .fuel),
            ("2026-03-26",  450.00, .other),   ("2026-03-26",  999.00, .other),
            ("2026-03-27",  250.00, .food),    ("2026-03-27",  320.00, .food),
            ("2026-03-27",  360.00, .food),    ("2026-03-28",  395.00, .food),
            ("2026-03-28",  955.00, .food),    ("2026-03-28",  260.00, .other),
            ("2026-03-28",  220.00, .other),   ("2026-03-28",  140.00, .food),
            ("2026-03-29",  340.00, .food),    ("2026-03-29",  180.00, .food),
            ("2026-03-30",  220.85, .market),  ("2026-03-30", 2000.00, .other),
            ("2026-03-30", 1101.03, .other),   ("2026-03-30",  109.19, .market),
            ("2026-03-31",  105.00, .fuel),    ("2026-03-31",  230.00, .food),
            ("2026-03-31",  637.37, .food),    ("2026-03-31",  105.00, .other),

            // ── NİSAN 2026 ──
            ("2026-04-01",  250.00, .food),    ("2026-04-01",  395.00, .food),
            ("2026-04-01",  130.00, .food),    ("2026-04-01",  250.00, .other),
            ("2026-04-01",   60.00, .other),   ("2026-04-02", 4166.66, .other),
            ("2026-04-03",  105.00, .market),  ("2026-04-03",   60.85, .market),
            ("2026-04-03", 1126.68, .clothing),("2026-04-03", 1465.67, .market),
            ("2026-04-03",  920.00, .food),    ("2026-04-03",  350.00, .food),
            ("2026-04-03",  385.20, .other),   ("2026-04-03",  300.00, .other),
            ("2026-04-04", 2490.00, .clothing),("2026-04-05",  125.14, .market),
            ("2026-04-05", 2960.00, .fuel),    ("2026-04-05",  250.00, .food),
            ("2026-04-05",  200.94, .market),  ("2026-04-05",  119.95, .market),
            ("2026-04-06",   67.00, .food),    ("2026-04-07",  390.00, .food),
            ("2026-04-07",  250.00, .other),   ("2026-04-07",  250.00, .other),
            ("2026-04-08",   49.00, .market),  ("2026-04-08",  205.85, .market),
            ("2026-04-08",   80.00, .food),    ("2026-04-09",  231.80, .market),
            ("2026-04-09",   78.44, .market),  ("2026-04-09",  360.00, .food),
            ("2026-04-10",   83.90, .market),  ("2026-04-10", 3100.80, .other),
            ("2026-04-11",  760.00, .food),    ("2026-04-11",  550.00, .food),
            ("2026-04-11", 3140.00, .food),    ("2026-04-11",  679.15, .other),
            ("2026-04-11", 1561.50, .other),   ("2026-04-11",  260.00, .other),
            ("2026-04-12",  641.96, .market),  ("2026-04-12",  960.00, .food),
            ("2026-04-12",  200.00, .food),    ("2026-04-13",  175.39, .market),
            ("2026-04-13",  492.50, .market),  ("2026-04-13",  320.00, .food),
            ("2026-04-13",  160.00, .food),    ("2026-04-13", 1855.62, .other),
            ("2026-04-13",  306.00, .other),   ("2026-04-13",  540.00, .other),
            ("2026-04-14",  124.99, .entertainment), ("2026-04-14", 250.00, .food),
            ("2026-04-15",  560.00, .other),   ("2026-04-15",   65.00, .market),
            ("2026-04-16",  382.75, .market),  ("2026-04-16",  115.00, .market),
            ("2026-04-16", 1559.57, .market),  ("2026-04-17",  350.00, .food),
            ("2026-04-17",  170.00, .food),    ("2026-04-17",  680.00, .food),
            ("2026-04-17",   60.00, .food),    ("2026-04-18",  810.00, .food),
            ("2026-04-18",   50.00, .food),    ("2026-04-19",  566.15, .market),
            ("2026-04-19", 2900.00, .fuel),    ("2026-04-19",  350.00, .food),
            ("2026-04-19",  270.00, .food),    ("2026-04-20",  280.00, .other),
            ("2026-04-20",  150.00, .food),    ("2026-04-20",  184.34, .other),
            ("2026-04-22",  115.00, .market),  ("2026-04-22",  260.00, .food),
            ("2026-04-22",  292.00, .entertainment), ("2026-04-23", 146.95, .market),
            ("2026-04-23",  185.00, .fuel),    ("2026-04-23",  460.00, .food),
            ("2026-04-23",  275.00, .food),    ("2026-04-23", 1000.00, .fuel),
            ("2026-04-23",  200.00, .other),   ("2026-04-24", 1516.00, .market),
            ("2026-04-24",  105.00, .market),  ("2026-04-24", 3000.00, .fuel),
            ("2026-04-24",  200.00, .food),    ("2026-04-24",  640.00, .other),
            ("2026-04-25", 7320.00, .food),    ("2026-04-26",  404.37, .market),
            ("2026-04-26",   65.00, .fuel),    ("2026-04-26",   75.00, .fuel),
            ("2026-04-26", 2630.47, .fuel),    ("2026-04-26",  245.00, .food),
            ("2026-04-26",  150.00, .food),    ("2026-04-26",  100.00, .food),
            ("2026-04-27",   50.00, .market),  ("2026-04-27",   72.90, .market),
            ("2026-04-27",  280.00, .other),   ("2026-04-28",  590.00, .food),
            ("2026-04-28",  225.00, .food),    ("2026-04-29",  510.00, .food),
            ("2026-04-29",  115.00, .food),    ("2026-04-30", 3239.20, .entertainment),
            ("2026-04-30",   32.99, .other),   ("2026-04-30", 1114.99, .other),

            // ── MAYIS 2026 ──
            ("2026-05-01",  620.97, .market),  ("2026-05-01",  170.00, .food),
            ("2026-05-01",  130.00, .food),    ("2026-05-02",  730.00, .food),
            ("2026-05-02", 4166.66, .other),   ("2026-05-03", 1126.66, .clothing),
            ("2026-05-03",  360.00, .food),    ("2026-05-03",  135.00, .food),
            ("2026-05-03",  210.00, .food),    ("2026-05-04",  100.10, .market),
            ("2026-05-04", 2912.70, .fuel),    ("2026-05-05", 1260.00, .food),
            ("2026-05-06", 3347.49, .other),   ("2026-05-06", 3347.49, .other),
            ("2026-05-06",  275.00, .food),    ("2026-05-06", 5321.98, .other),
            ("2026-05-06", 6507.69, .other),   ("2026-05-07",   19.38, .market),
            ("2026-05-08",   54.90, .market),  ("2026-05-09",  990.00, .food),
            ("2026-05-09",   50.00, .food),    ("2026-05-09", 2639.20, .other),
            ("2026-05-09",  490.00, .market),  ("2026-05-10", 1394.00, .other),
            ("2026-05-10",  400.00, .food),    ("2026-05-10", 2316.00, .food),
            ("2026-05-11",   77.25, .market),  ("2026-05-12",  130.05, .market),
            ("2026-05-12",   48.50, .market),  ("2026-05-13",  495.00, .other),
            ("2026-05-13",  395.00, .food),    ("2026-05-13",  320.00, .food),
            ("2026-05-13",  570.00, .food),    ("2026-05-14",  121.69, .market),
            ("2026-05-15",  280.00, .food),    ("2026-05-15", 2176.54, .other),
            ("2026-05-15",  244.00, .other),   ("2026-05-16",  540.00, .food),
            ("2026-05-16",  450.00, .food),    ("2026-05-16",  221.00, .market),
            ("2026-05-16",  918.59, .other),   ("2026-05-17",  433.94, .other),
            ("2026-05-17", 1403.65, .other),   ("2026-05-17",  164.30, .market),
            ("2026-05-18",  417.26, .market),  ("2026-05-18", 2000.00, .fuel),
            ("2026-05-18",  185.00, .food),    ("2026-05-19",  400.00, .food),
            ("2026-05-20",   85.00, .market),  ("2026-05-20",  649.99, .food),
            ("2026-05-20",   80.00, .market),  ("2026-05-20", 1500.56, .other),
            ("2026-05-20", 1777.76, .other),   ("2026-05-20", 4410.86, .other),
            ("2026-05-21",  420.00, .food),    ("2026-05-21",  850.00, .food),
            ("2026-05-21",  921.70, .other),   ("2026-05-22",  245.00, .food),
            ("2026-05-22",  750.00, .food),    ("2026-05-22",  230.00, .food),
            ("2026-05-22",  250.00, .food),    ("2026-05-23",   60.00, .market),
            ("2026-05-23",   75.90, .market),  ("2026-05-23",  190.00, .market),
            ("2026-05-23",  180.00, .food),    ("2026-05-23",  320.00, .food),
            ("2026-05-23",  505.00, .food),    ("2026-05-23", 2000.00, .other),
            ("2026-05-24",   42.50, .market),  ("2026-05-24",  170.00, .food),
            ("2026-05-24",  655.00, .food),    ("2026-05-24",  270.00, .food),
            ("2026-05-25",  150.00, .fuel),    ("2026-05-25",  445.00, .food),
            ("2026-05-25", 3500.00, .other),   ("2026-05-25",  140.00, .other),
            ("2026-05-26",  119.14, .market),  ("2026-05-26",  585.00, .food),
            ("2026-05-26",  340.00, .food),    ("2026-05-26",  190.00, .food),
            ("2026-05-26",  310.00, .food),    ("2026-05-26",  210.00, .food),
            ("2026-05-26", 1020.00, .food),    ("2026-05-26",  300.00, .other),
            ("2026-05-27",  275.00, .food),    ("2026-05-28", 3239.20, .entertainment),
            ("2026-05-28",   60.00, .market),  ("2026-05-28",   75.90, .market),
            ("2026-05-28",   90.00, .food),    ("2026-05-28",   80.00, .fuel),
            ("2026-05-28",  540.00, .food),    ("2026-05-28",  210.00, .food),
            ("2026-05-29",  907.24, .market),  ("2026-05-29", 1000.00, .fuel),
            ("2026-05-30",  810.00, .food),    ("2026-05-30",  250.00, .food),
        ]

        for (dateStr, amount, category) in transactions {
            context.insert(SpendLogEntry(date: iso(dateStr), category: category, amount: amount))
        }

        do {
            try context.save()
            defaults.set(true, forKey: didImportGarantiKey)
        } catch {
            print("Garanti import save failed: \(error)")
        }
    }

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "Europe/Istanbul")
        return f
    }()

    private static func iso(_ s: String) -> Date {
        isoFormatter.date(from: s) ?? Date()
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
