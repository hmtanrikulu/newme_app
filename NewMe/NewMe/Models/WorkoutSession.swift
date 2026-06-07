import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var date: Date = Date()         // normalized to startOfDay
    var startedAt: Date = Date()    // exact session start
    var finishedAt: Date? = nil
    var title: String = ""

    @Relationship(deleteRule: .nullify, inverse: \FitnessLogEntry.session)
    var entries: [FitnessLogEntry]? = []

    init(date: Date, title: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.startedAt = Date()
        self.title = title
    }

    var durationMinutes: Int {
        let end = finishedAt ?? Date()
        return max(0, Int(end.timeIntervalSince(startedAt) / 60))
    }

    var totalSets: Int {
        (entries ?? []).reduce(0) { $0 + $1.sets.count }
    }

    var movementCount: Int {
        (entries ?? []).filter { !$0.sets.isEmpty }.count
    }

    var totalVolume: Double {
        (entries ?? []).reduce(0) { $0 + $1.volume }
    }
}
