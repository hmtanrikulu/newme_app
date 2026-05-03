import Foundation
import SwiftData

struct SetData: Codable, Hashable {
    var reps: Int
    var kg: Double
}

@Model
final class FitnessLogEntry {
    var date: Date = Date()
    var sets: [SetData] = []
    var exercise: ExerciseItem?

    init(date: Date, sets: [SetData] = [], exercise: ExerciseItem?) {
        self.date = Calendar.current.startOfDay(for: date)
        self.sets = sets
        self.exercise = exercise
    }

    var volume: Double {
        sets.reduce(0) { $0 + Double($1.reps) * $1.kg }
    }
}
