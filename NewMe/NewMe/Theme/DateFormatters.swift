import Foundation

enum DateFormatters {
    /// "3 Mayıs Pazar"
    static let dateLabel: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM EEEE"
        return f
    }()

    /// "3 Mayıs"
    static let monthDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM"
        return f
    }()

    /// "Mayıs 2026"
    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    /// "Pzt, Sal, Çar..."
    static let weekdayShort: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "EEE"
        return f
    }()

    /// "₺1.234"
    static let lira: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.numberStyle = .currency
        f.currencyCode = "TRY"
        f.maximumFractionDigits = 0
        return f
    }()

    /// Header kicker for the active log date.
    /// Today → "BUGÜN"; yesterday → "DÜN"; else → "GÜNLÜK".
    static func kicker(for date: Date, today: Date = .now) -> String {
        let cal = Calendar.current
        if cal.isDate(date, inSameDayAs: today) { return "BUGÜN" }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: today)),
           cal.isDate(date, inSameDayAs: yesterday) { return "DÜN" }
        return "GÜNLÜK"
    }
}
