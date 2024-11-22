//
//  PopupAlert.swift
//  Film-in
//
//  Created by Minjae Kim on 11/22/24.
//

import SwiftUI
import PopupView

protocol PopupAlertModelType {
    var phrase: LocalizedStringKey { get set }
    var normal: LocalizedStringKey { get set }
    var cancel: LocalizedStringKey? { get set }
}

struct PopupAlertModel: PopupAlertModelType {
    var phrase: LocalizedStringKey
    var normal: LocalizedStringKey
    var cancel: LocalizedStringKey?
    
    init(
        phrase: LocalizedStringKey,
        normal: LocalizedStringKey,
        cancel: LocalizedStringKey? = nil
    ) {
        self.phrase = phrase
        self.normal = normal
        self.cancel = cancel
    }
}

enum PopupAlertHeight {
    case normal
    case middle
    case custom(_ height: CGFloat)
}

extension View {
    func popupAlert<Model: PopupAlertModelType>(
        isPresented: Binding<Bool>,
        contentModel: Model,
        height: PopupAlertHeight,
        normalButtonTapped: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            PopupAlertViewModifier(
                isPresented: isPresented,
                contentModel: contentModel,
                height: height,
                normalButtonTapped: normalButtonTapped
            )
        )
    }
}

fileprivate struct PopupAlertViewModifier<Model: PopupAlertModelType>: ViewModifier {
    @Binding var isPresented: Bool
    
    private let contentModel: Model
    private let height: PopupAlertHeight
    private var normalButtonTapped: (() -> Void)?
    
    init(
        isPresented: Binding<Bool>,
        contentModel: Model,
        height: PopupAlertHeight,
        normalButtonTapped: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.contentModel = contentModel
        self.height = height
        self.normalButtonTapped = normalButtonTapped
    }
    
    func body(content: Content) -> some View {
        content
            .popup(isPresented: $isPresented) {
                PopupAlertView(
                    contentModel: contentModel,
                    heightType: height,
                    normalButtonTapped: normalButtonTapped
                )
            } customize: {
                $0
                    .closeOnTapOutside(true)
                    .backgroundColor(.appText.opacity(0.5))
            }
    }
}

struct PopupAlertView<Model: PopupAlertModelType>: View {
    private let contentModel: Model
    private let height: CGFloat
    private var normalButtonTapped: (() -> Void)?
    
    init(
        contentModel: Model,
        heightType: PopupAlertHeight,
        normalButtonTapped: ( () -> Void)? = nil
    ) {
        self.contentModel = contentModel
        self.normalButtonTapped = normalButtonTapped
        
        switch heightType {
        case .normal:
            self.height = 120
        case .middle:
            self.height = 200
        case .custom(let height):
            self.height = height
        }
    }
    
    var body: some View {
        VStack {
            Text(contentModel.phrase)
                .font(.ibmPlexMonoSemiBold(size: 20))
            
            Spacer()
            
            HStack {
                if let cancel = contentModel.cancel {
                    Button {
                    } label: {
                        Text(cancel)
                            .appButtonText()
                    }
                }
                
                Button {
                    normalButtonTapped?()
                } label: {
                    Text(contentModel.normal)
                        .appButtonText()
                }
            }
        }
        .frame(width: 300, height: height, alignment: .top)
        .padding()
        .background(.background)
    }
}
