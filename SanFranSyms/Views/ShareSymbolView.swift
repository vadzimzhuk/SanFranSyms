//
//  ShareSymbolView.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 16.06.22.
//

import SwiftUI

var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }

struct ShareSymbolView: View {
    let model: ViewModel

    @State var showShareSheet: Bool = false
    @State var showShareSwiftUICode: Bool = false
    @State var showShareUIKitCode: Bool = false

    var body: some View {
        VStack {
            HStack {
                if model.mode != .palette {
                    Image(systemName: model.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 100)
                        .symbolRenderingMode(model.mode.systemMode)
                        .foregroundColor(model.primaryColor)
                        .background(model.backgroundColor)
                } else {
                    Image(systemName: model.symbolName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.all, 100)
                        .symbolRenderingMode(model.mode.systemMode)
                        .foregroundStyle(model.secondaryColor, model.primaryColor)
                        .background(model.backgroundColor)
                }
            }
            .padding(.all, 25)

            Button {
                    showShareSheet = true
            } label: {
                Text("Image")
                    .font(.headline)
                    .padding()
            }
            .sheet(isPresented: $showShareSheet,
                   content: { ActivityViewController(itemsToShare: [model.sharedImageFile], servicesToShareItem: []) })

            Button {
                showShareSwiftUICode = true
            } label: {
                Text("SwiftUI code")
                    .font(.headline)
                    .padding()
            }
            .sheet(isPresented: $showShareSwiftUICode,
                   content: { ActivityViewController(itemsToShare: [model.sharedSwiftUICode], servicesToShareItem: []) })

            Button {
                showShareUIKitCode = true
            } label: {
                Text("UIKit code")
                    .font(.headline)
                    .padding()
            }
            .sheet(isPresented: $showShareUIKitCode,
                   content: { ActivityViewController(itemsToShare: [model.sharedUIKitCode], servicesToShareItem: []) })
        }
    }
}

struct ShareSymbolView_Previews: PreviewProvider {
    static var previews: some View {
        ShareSymbolView(model: .init(name: "square.and.arrow.up", mode: .palette, primaryColor: .teal, secondaryColor: .pink, backgroundColor: .gray))
    }
}

extension ShareSymbolView {
    class ViewModel {
        var symbolName: String
        var mode: AppSymbolRenderingMode
        var primaryColor: Color
        var secondaryColor: Color
        var backgroundColor: Color

        init(name: String, mode: AppSymbolRenderingMode, primaryColor: Color, secondaryColor: Color, backgroundColor: Color) {
            self.symbolName = name
            self.mode = mode
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
            self.backgroundColor = backgroundColor
        }

        var sharedImageFile: UIImage {
            let image = UIImage(systemName: symbolName)!

            let config: UIImage.SymbolConfiguration
            switch mode {
                case .palette:
                    config = UIImage.SymbolConfiguration(paletteColors: [UIColor(secondaryColor), UIColor(primaryColor)])
                case .multicolor:
                    config = UIImage.SymbolConfiguration(hierarchicalColor: UIColor(primaryColor))
                case .hierarchical:
                    config = UIImage.SymbolConfiguration(hierarchicalColor: UIColor(primaryColor))
                case .monochrome:
                    config = UIImage.SymbolConfiguration(hierarchicalColor: UIColor(primaryColor))

            }

            return image.applyingSymbolConfiguration(config)!
        }

        var sharedUIKitCode: String {
            switch mode {
                case .palette:
                    return "UIImage(systemName: \"\(symbolName)\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(paletteColors: [UIColor(\(secondaryColor)), UIColor(\(primaryColor))]))!"
                case .multicolor:
                    return "UIImage(systemName: \"\(symbolName)\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(\(primaryColor))))!"
                case .hierarchical:
                    return "UIImage(systemName: \"\(symbolName)\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(\(primaryColor))))!"
                case .monochrome:
                    return "UIImage(systemName: \"\(symbolName)\")!.applyingSymbolConfiguration(UIImage.SymbolConfiguration(hierarchicalColor: UIColor(\(primaryColor)))!"
            }
        }

        var sharedSwiftUICode: String {
            if mode != .palette {
                return """
Image(systemName: \"\(symbolName)\")
    .symbolRenderingMode(.\(mode))
    .foregroundColor(.\(primaryColor))
"""
            } else {
                return """
Image(systemName: symbolName)
    .symbolRenderingMode(.\(mode))
    .foregroundStyle(.\(secondaryColor), .\(primaryColor))
"""
            }
        }
    }
}

// MARK: -
struct ActivityViewController: UIViewControllerRepresentable {
    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

//
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
