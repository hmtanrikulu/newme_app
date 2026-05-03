import Foundation
import SwiftData

@Model
final class ExerciseItem {
    var name: String = ""
    var muscleGroup: String = "Diğer"
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \FitnessLogEntry.exercise)
    var logEntries: [FitnessLogEntry]? = []

    init(name: String, muscleGroup: String = "Diğer", sortOrder: Int = 0) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.sortOrder = sortOrder
    }
}
