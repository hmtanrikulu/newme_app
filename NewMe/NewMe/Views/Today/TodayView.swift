import SwiftUI
import SwiftData

struct TodayView: View {
    let activeDate: Date
    let onOpenFood: () -> Void
    let onOpenFitness: () -> Void
    let onOpenSpend: () -> Void
    let onCalendar: () -> Void
    let onSettings: () -> Void
    let onShowLogSheet: () -> Void

    @Query private var allFoodEntries: [FoodLogEntry]
    @Query private var allManualEntries: [ManualFoodEntry]
    @Query private var allFitnessEntries: [FitnessLogEntry]
    @Query private var allSpendEntries: [SpendLogEntry]
    @Query private var goalsRows: [UserGoals]

    private var goals: UserGoals { goalsRows.first ?? UserGoals() }

    // MARK: — Computed today values

    private var kcalToday: Double {
        let catalog = allFoodEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .reduce(0.0) { $0 + Double($1.quantity) * ($1.item?.kcalPerPortion ?? 0) }
        let manual = allManualEntries
            .first { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }?.kcal ?? 0
        return catalog + manual
    }

    private var proteinToday: Double {
        let catalog = allFoodEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .reduce(0.0) { $0 + Double($1.quantity) * ($1.item?.proteinPerPortion ?? 0) }
        let manual = allManualEntries
            .first { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }?.protein ?? 0
        return catalog + manual
    }

    private var spendToday: Double {
        allSpendEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .reduce(0.0) { $0 + $1.amount }
    }

    private var totalSetsToday: Int {
        allFitnessEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) }
            .reduce(0) { $0 + $1.sets.count }
    }

    private var movementsToday: Int {
        allFitnessEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: activeDate) && !$0.sets.isEmpty }
            .count
    }

    private var kcalProgress: Double {
        goals.kcal > 0 ? kcalToday / Double(goals.kcal) : 0
    }

    private var spendProgress: Double {
        goals.dailySpendLimit > 0 ? spendToday / Double(goals.dailySpendLimit) : 0
    }

    // 15 sets = full ring; any logged session shows meaningful fill
    private var fitnessProgress: Double {
        min(1.0, Double(totalSetsToday) / 15.0)
    }

    private var streak: Int {
        DailyAggregator.currentStreak(
            foodEntries: allFoodEntries,
            manualEntries: allManualEntries,
            fitnessEntries: allFitnessEntries,
            spendEntries: allSpendEntries
        )
    }

    // MARK: — Body

    var body: some View {
        VStack(spacing: 0) {
            AppHeader(
                kicker: "BUGÜN",
                title: DateFormatters.dateLabel.string(from: activeDate),
                showBackToToday: false,
                onBackToToday: nil,
                onCalendar: onCalendar,
                onSettings: onSettings
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ringsCard
                    domainCards
                    if streak >= 2 {
                        streakBadge
                    }
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .padding(.top, 54)
    }

    // MARK: — Rings

    private var ringsCard: some View {
        HStack(spacing: 0) {
            ringItem(
                progress: kcalProgress,
                color: AppColor.gold,
                valueText: "\(Int(kcalToday.rounded()))",
                unit: "kcal",
                label: "KALORİ",
                subLabel: "/ \(goals.kcal)"
            )
            Divider()
                .frame(height: 60)
                .background(AppColor.hairline)
            ringItem(
                progress: spendProgress,
                color: AppColor.info,
                valueText: "₺\(Int(spendToday.rounded()))",
                unit: "",
                label: "HARCAMA",
                subLabel: "/ ₺\(goals.dailySpendLimit)"
            )
            Divider()
                .frame(height: 60)
                .background(AppColor.hairline)
            ringItem(
                progress: fitnessProgress,
                color: AppColor.success,
                valueText: "\(totalSetsToday)",
                unit: "set",
                label: "FİTNESS",
                subLabel: movementsToday > 0 ? "\(movementsToday) eg." : "—"
            )
        }
        .padding(.vertical, 22)
        .background(RoundedRectangle(cornerRadius: 18).fill(AppColor.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColor.hairline, lineWidth: 0.5)
        )
    }

    private func ringItem(
        progress: Double,
        color: Color,
        valueText: String,
        unit: String,
        label: String,
        subLabel: String
    ) -> some View {
        VStack(spacing: 10) {
            ZStack {
                ActivityRing(progress: progress, color: color, ringWidth: 9, size: 74)
                VStack(spacing: 1) {
                    Text(valueText)
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.textPrimary)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(AppColor.text3)
                    }
                }
            }
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(0.6)
                    .foregroundStyle(AppColor.text3)
                Text(subLabel)
                    .font(.system(size: 10))
                    .monospacedDigit()
                    .foregroundStyle(color.opacity(0.65))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Domain cards

    private var domainCards: some View {
        VStack(spacing: 8) {
            TodayDomainCard(
                icon: "fork.knife",
                title: "Yemek",
                color: AppColor.gold,
                primaryText: "\(Int(kcalToday.rounded())) kcal",
                secondaryText: "Hedef: \(goals.kcal) kcal",
                progress: kcalProgress,
                onTap: onOpenFood
            )
            TodayDomainCard(
                icon: "dumbbell.fill",
                title: "Antrenman",
                color: AppColor.success,
                primaryText: totalSetsToday > 0 ? "\(totalSetsToday) set · \(movementsToday) eg." : "Henüz kayıt yok",
                secondaryText: totalSetsToday > 0 ? "Günlük protein: \(Int(proteinToday.rounded()))g" : "Antrenman ekle →",
                progress: fitnessProgress,
                onTap: onOpenFitness
            )
            TodayDomainCard(
                icon: "turkishlirasign.circle.fill",
                title: "Harcama",
                color: AppColor.info,
                primaryText: "₺\(Int(spendToday.rounded()))",
                secondaryText: "Limit: ₺\(goals.dailySpendLimit)",
                progress: spendProgress,
                onTap: onOpenSpend
            )
        }
    }

    // MARK: — Streak badge

    private var streakBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 20))
                .foregroundStyle(AppColor.gold)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak) gün streak")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                Text("Devam et, harika gidiyorsun!")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.text3)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.goldDim)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColor.gold.opacity(0.3), lineWidth: 1))
        )
    }
}
