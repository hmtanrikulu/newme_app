import Foundation
import SwiftData

/// One set's measurements. Field meaning depends on the parent
/// ExerciseItem.kind: weight uses reps + kg; bodyweight uses reps;
/// cardio uses minutes. Other fields stay 0.
struct SetData: Codable, Hashable {
    var reps: Int
    var kg: Double
    var minutes: Double

    init(reps: Int = 0, kg: Double = 0, minutes: Double = 0) {
        self.reps = reps
        self.kg = kg
        self.minutes = minutes
    }

    enum CodingKeys: String, CodingKey { case reps, kg, minutes }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.reps    = try c.decodeIfPresent(Int.self,    forKey: .reps)    ?? 0
        self.kg      = try c.decodeIfPresent(Double.self, forKey: .kg)      ?? 0
        self.minutes = try c.decodeIfPresent(Double.self, forKey: .minutes) ?? 0
    }
}

@Model
final class FitnessLogEntry {
    var date: Date = Date()
    var sets: [SetData] = []
    var exercise: ExerciseItem?
    var session: WorkoutSession? = nil

    init(date: Date, sets: [SetData] = [], exercise: ExerciseItem?, session: WorkoutSession? = nil) {
        self.date = Calendar.current.startOfDay(for: date)
        self.sets = sets
        self.exercise = exercise
        self.session = session
    }

    var volume: Double {
        guard exercise?.kind == .weight else { return 0 }
        return sets.reduce(0) { $0 + Double($1.reps) * $1.kg }
    }

    var totalMinutes: Double {
        guard exercise?.kind == .cardio else { return 0 }
        return sets.reduce(0) { $0 + $1.minutes }
    }

    var totalReps: Int {
        guard exercise?.kind == .bodyweight else { return 0 }
        return sets.reduce(0) { $0 + $1.reps }
    }
}
