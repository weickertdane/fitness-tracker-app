import SwiftUI

/**
 * Custom number pad for Apple Watch optimized input.
 */
struct NumberPadView: View {
    @Binding var value: String
    let allowDecimal: Bool
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    init(value: Binding<String>, allowDecimal: Bool = false, onDismiss: @escaping () -> Void) {
        self._value = value
        self.allowDecimal = allowDecimal
        self.onDismiss = onDismiss
    }
    
    private let numbers = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"],
        ["", ".", ""]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Current value display - centered over the "2" button
            Text(value.isEmpty ? "0" : value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Number pad grid - tighter spacing
            VStack(spacing: 2) {
                ForEach(0..<numbers.count, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<numbers[row].count, id: \.self) { col in
                            let buttonText = numbers[row][col]
                            
                            if !buttonText.isEmpty {
                                Button(action: {
                                    handleButtonTap(buttonText)
                                }) {
                                    if buttonText == "⌫" {
                                        Image(systemName: "delete.left")
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(buttonBackground(for: buttonText))
                                            .foregroundColor(buttonForeground(for: buttonText))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    } else {
                                        Text(buttonText)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(buttonBackground(for: buttonText))
                                            .foregroundColor(buttonForeground(for: buttonText))
                                            .clipShape(RoundedRectangle(cornerRadius: 5))
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(!isButtonEnabled(buttonText))
                            } else {
                                // Empty space
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .frame(height: 26)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { gesture in
                    if gesture.translation.width > 50 {
                        // Swipe right - dismiss
                        onDismiss()
                        dismiss()
                    }
                }
        )
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    onDismiss()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
        }
    }
    
    private func handleButtonTap(_ button: String) {
        switch button {
        case "⌫":
            if !value.isEmpty {
                value.removeLast()
            }
        case ".":
            if allowDecimal && !value.contains(".") {
                if value.isEmpty {
                    value = "0."
                } else {
                    value += "."
                }
            }
        default:
            // Prevent multiple leading zeros
            if value == "0" && button != "." {
                value = button
            } else {
                value += button
            }
        }
    }
    
    private func isButtonEnabled(_ button: String) -> Bool {
        switch button {
        case ".":
            return allowDecimal && !value.contains(".")
        default:
            return true
        }
    }
    
    private func buttonBackground(for button: String) -> Color {
        switch button {
        case "⌫":
            return .red.opacity(0.2)
        case ".":
            return allowDecimal ? .blue.opacity(0.2) : .gray.opacity(0.1)
        default:
            return .gray.opacity(0.2)
        }
    }
    
    private func buttonForeground(for button: String) -> Color {
        switch button {
        case "⌫":
            return .red
        case ".":
            return allowDecimal ? .blue : .gray
        default:
            return .primary
        }
    }
}

#Preview {
    @State var testValue = ""
    return NumberPadView(value: $testValue, allowDecimal: true) {
        print("Dismissed with value: \(testValue)")
    }
}
