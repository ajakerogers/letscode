// CustomTextEditor.swift
import SwiftUI

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true

        // Disable smart quotes and other automatic text features
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.spellCheckingType = .no

        textView.font = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 4
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        // Implement auto-indentation
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                let nsText = textView.text as NSString
                let currentLineRange = nsText.lineRange(for: NSRange(location: range.location, length: 0))
                let currentLine = nsText.substring(with: currentLineRange)
                let leadingWhitespace = currentLine.prefix(while: { $0 == " " || $0 == "\t" })
                let insertion = "\n" + leadingWhitespace
                textView.replace(range, withText: insertion)
                return false
            }
            return true
        }
    }
}

extension UITextView {
    func replace(_ range: NSRange, withText text: String) {
        if let textRange = self.textRange(from: self.position(from: self.beginningOfDocument, offset: range.location)!,
                                          to: self.position(from: self.beginningOfDocument, offset: NSMaxRange(range))!) {
            self.replace(textRange, withText: text)
        }
    }
}
