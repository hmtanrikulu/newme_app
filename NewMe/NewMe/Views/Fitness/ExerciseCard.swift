import SwiftUI

struct ExerciseCard: View {
    let exercise: ExerciseItem
    let entry: FitnessLogEntry?
    let isOpen: Bool
    let onToggleOpen: () -> Void
    let onAddSet: () -> Void
    let onUpdateSet: (Int, SetData) -> Void
    let onDeleteSet: (Int) -> Void

    private var sets: [SetData] { entry?.sets ?? [] }

    var body: some View {
        VStack(spacing: 0) {
            header
            if isOpen { table }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isOpen ? AppColor.gold.opacity(0.35) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }

    private var header: some View {
        Button(action: onToggleOpen) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppColor.textPrimary)
                    Text(exercise.muscleGroup)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.text2)
                }
                Spacer()
                if !sets.isEmpty {
                    Text("\(sets.count) set")
                        .font(.system(size: 12, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(AppColor.gold)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.4))
                    .rotationEffect(.degrees(isOpen ? 90 : 0))
                    .animation(.easeInOut(duration: 0.15), value: isOpen)
            }
            .padding(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var table: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text("SET").frame(width: 24, alignment: .leading)
                Text("KG").frame(maxWidth: .infinity)
                Text("TEKRAR").frame(maxWidth: .infinity)
                Color.clear.frame(width: 22)
            }
            .font(.system(size: 10, weight: .heavy))
            .tracking(1)
            .foregroundStyle(AppColor.text3)
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
            .padding(.top, 6)
            .overlay(
                Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5),
                alignment: .bottom
            )

            if sets.isEmpty {
                Text("Henüz set girilmedi")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.text3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .padding(.leading, 2)
            } else {
                ForEach(Array(sets.enumerated()), id: \.offset) { idx, set in
                    SetRow(
                        index: idx,
                        set: set,
                        isLast: idx == sets.count - 1,
                        onUpdate: { onUpdateSet(idx, $0) },
                        onDelete: { onDeleteSet(idx) }
                    )
                }
            }

            Button(action: onAddSet) {
                Text("+ Set Ekle")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColor.gold.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    .foregroundStyle(AppColor.gold.opacity(0.4))
                            )
                    )
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }
}

private struct SetRow: View {
    let index: Int
    let set: SetData
    let isLast: Bool
    let onUpdate: (SetData) -> Void
    let onDelete: () -> Void

    @State private var kg: Double
    @State private var reps: Double

    init(index: Int, set: SetData, isLast: Bool,
         onUpdate: @escaping (SetData) -> Void,
         onDelete: @escaping () -> Void) {
        self.index = index
        self.set = set
        self.isLast = isLast
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _kg = State(initialValue: set.kg)
        _reps = State(initialValue: Double(set.reps))
    }

    var body: some View {
        HStack(spacing: 8) {
            Text("\(index + 1)")
                .font(.system(size: 13, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(AppColor.gold)
                .frame(width: 24, alignment: .leading)
            NumberInput(value: $kg, decimals: 1, suffix: "kg")
                .onChange(of: kg) { _, newValue in
                    onUpdate(SetData(reps: Int(reps.rounded()), kg: newValue))
                }
            NumberInput(value: $reps)
                .onChange(of: reps) { _, newValue in
                    onUpdate(SetData(reps: Int(newValue.rounded()), kg: kg))
                }
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColor.text3)
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.04))
                .frame(height: 0.5)
                .opacity(isLast ? 0 : 1),
            alignment: .bottom
        )
    }
}
