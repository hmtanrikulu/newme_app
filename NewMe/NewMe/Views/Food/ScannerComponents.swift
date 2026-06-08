import SwiftUI
import VisionKit

// Shared scanner + nutrition grid components used by both BarcodeScannerView and AddFoodTabSheet.

// MARK: — DataScanner representable

struct DataScannerRepresentable: UIViewControllerRepresentable {
    @Binding var scannedCode: String?

    func makeCoordinator() -> Coordinator { Coordinator(scannedCode: $scannedCode) }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .accurate,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        try? vc.startScanning()
        return vc
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var scannedCode: String?

        init(scannedCode: Binding<String?>) {
            self._scannedCode = scannedCode
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case .barcode(let b) = item, let payload = b.payloadStringValue {
                    scannedCode = payload
                    dataScanner.stopScanning()
                    return
                }
            }
        }
    }
}

// MARK: — Nutrition grid

struct NutritionGrid: View {
    let kcal: Double
    let protein: Double
    let carbs: Double
    let fat: Double

    var body: some View {
        HStack(spacing: 0) {
            nutriCell(value: Int(kcal.rounded()), label: "kcal", color: AppColor.food)
            Divider().frame(height: 36)
            nutriCell(value: Int(protein.rounded()), label: "protein (g)", color: AppColor.macroProt)
            Divider().frame(height: 36)
            nutriCell(value: Int(carbs.rounded()), label: "karb (g)", color: AppColor.macroCarb)
            Divider().frame(height: 36)
            nutriCell(value: Int(fat.rounded()), label: "yağ (g)", color: AppColor.macroFat)
        }
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func nutriCell(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)").font(.headline.monospacedDigit()).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
