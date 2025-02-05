//
//  DateSetupView.swift
//  Film-in
//
//  Created by Minjae Kim on 10/1/24.
//

import SwiftUI
import PopupView

enum DateSetupType {
    case want
    case watched
}

struct DateSetupView: View {
    @EnvironmentObject var coordinator: Coordinator
    
    @StateObject private var viewModel: DateSetupViewModel
    
    @State private var displayedComponents: DatePicker<Label>.Components = [.date]
    
    init(
        viewModel: DateSetupViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if viewModel.type == .want {
                DatePicker(
                    "",
                    selection: $viewModel.output.selection,
                    in: Date()...,
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.graphical)
                .tint(.app)
                
                Toggle("pushAlarm".localized, isOn: $viewModel.output.isAlarm)
                    .tint(.app)
                    .foregroundStyle(.appText)
                    .font(.ibmPlexMonoSemiBold(size: 20))
            } else {
                DatePicker(
                    "",
                    selection: $viewModel.output.selection,
                    in: ...Date(),
                    displayedComponents: displayedComponents
                )
                .datePickerStyle(.graphical)
                .tint(.app)
            }
            
            Button {
                viewModel.action(.done)
            } label: {
                Text(R.Phrase.done)
                    .font(.ibmPlexMonoSemiBold(size: 20))
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(uiColor: .app).opacity(0.3))
                    .foregroundStyle(.app)
            }
            .padding(.vertical)
        }
        .padding()
        .presentationCornerRadius(0)
        .presentationDetents([viewModel.type == .want ? .height(550) : .height(500)])
        .presentationDragIndicator(.visible)
        .valueChanged(value: viewModel.output.isAlarm) { newValue in
            displayedComponents = newValue ? [.date, .hourAndMinute] : [.date]
            if newValue {
                viewModel.action(.requestPermission)
            }
        }
        .valueChanged(value: viewModel.output.isSuccess) { newValue in
            if newValue {
                coordinator.dismissSheet()
            }
        }
        .popupAlert(
            isPresented: $viewModel.output.isDone,
            contentModel: PopupAlertModel(
                phrase: R.Phrase.saveRequest,
                normal: R.Phrase.save,
                cancel: R.Phrase.cancel
            ),
            heightType: .normal
        ) {
            viewModel.action(.wantOrWatched)
        }
        .popupAlert(
            isPresented: $viewModel.output.isError,
            contentModel: PopupAlertModel(
                phrase: R.Phrase.notificationRequest,
                normal: R.Phrase.move,
                cancel: R.Phrase.cancel
            ),
            heightType: .middle
        ) {
            viewModel.action(.moveToSetting)
        }
    }
}
