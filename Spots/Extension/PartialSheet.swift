//
//  Created on 2021/11/25
//

import SwiftUI

extension View {
    func partialSheet<Sheet: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder sheet: @escaping () -> Sheet,
        onEnd: @escaping () -> ()
    ) -> some View {
        // Use background to avoid whiteout
        return self
            .background(
                PartialSheetSheetViewController(
                    sheet: sheet(),
                    isPresented: isPresented,
                    onClose: onEnd
                )
            )
    }
}

private struct PartialSheetSheetViewController<Sheet: View>: UIViewControllerRepresentable {
    var sheet: Sheet
    @Binding var isPresented: Bool
    var onClose: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(
        _ viewController: UIViewController,
        context: Context
    ) {
        if isPresented {
            let sheetController = CustomHostingController(rootView: sheet)
            sheetController.presentationController!.delegate = context.coordinator
            viewController.present(sheetController, animated: true)
        } else {
            viewController.dismiss(animated: true) { onClose() }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        var parent: PartialSheetSheetViewController
        
        init(parent: PartialSheetSheetViewController) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }
    }
    
    class CustomHostingController<Content: View>: UIHostingController<Content> {
        override func viewDidLoad() {
            super.viewDidLoad()
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 15
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }
    }
}
