import Foundation
import SwiftData

enum ExerciseKind: String, CaseIterable, Codable, Identifiable {
    case weight, bodyweight, cardio
    var id: String { rawValue }

    var label: String {
        switch self {
        case .weight:     return "Ağırlık"
        case .bodyweight: return "Vücut ağırlığı"
        case .cardio:     return "Kardiyo"
        }
    }

    var systemImage: String {
        switch self {
        case .weight:     return "dumbbell.fill"
        case .bodyweight: return "figure.strengthtraining.functional"
        case .cardio:     return "figure.run"
        }
    }

    /// Whether the exercise tracks per-muscle-group categorization.
    /// Cardio doesn't really fit a muscle group; we hide that picker.
    var hasMuscleGroup: Bool {
        switch self {
        case .weight, .bodyweight: return true
        case .cardio:              return false
        }
    }
}

@Model
final class ExerciseItem {
    var name: String = ""
    var muscleGroup: String = "Diğer"
    /// Stored as raw string for SwiftData/CloudKit compatibility.
    /// Defaults to "weight" so existing rows pre-migration stay sensible.
    var kindRaw: String = ExerciseKind.weight.rawValue
    var sortOrder: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \FitnessLogEntry.exercise)
    var logEntries: [FitnessLogEntry]? = []

    var kind: ExerciseKind {
        get { ExerciseKind(rawValue: kindRaw) ?? .weight }
        set { kindRaw = newValue.rawValue }
    }

    init(
        name: String,
        muscleGroup: String = "Diğer",
        kind: ExerciseKind = .weight,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.kindRaw = kind.rawValue
        self.sortOrder = sortOrder
    }
}
