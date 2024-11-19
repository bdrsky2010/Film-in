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
    @StateObject private var viewModel: DateSetupViewModel
    @State private var displayedComponents: DatePicker<Label>.Components = [.date]
    @Binding var isPresented: Bool
    
    init(
        viewModel: DateSetupViewModel,
        isPresented: Binding<Bool>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isPresented = isPresented
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
                Text("done")
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
                isPresented.toggle()
            }
        }
        .popup(isPresented: $viewModel.output.isDone) {
            VStack {
                Text("saveRequestPhrase")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                
                Spacer()
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("cancel")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app) 
                    }
                    
                    Button {
                        viewModel.action(.wantOrWatched)
                    } label: {
                        Text("save")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                }
            }
            .frame(width: 300, height: 100, alignment: .top)
            .padding()
            .background(.background)
        } customize: {
            $0
                .closeOnTapOutside(true)
                .backgroundColor(.appText.opacity(0.5))
        }
        .popup(isPresented: $viewModel.output.isError) {
            VStack {
                Text("notificationRequestPhrase")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                
                Spacer()
                
                HStack {
                    Button {
                        
                    } label: {
                        Text("cancel")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                    
                    Button {
                        viewModel.action(.moveToSetting)
                    } label: {
                        Text("move")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                }
            }
            .frame(width: 300, height: 200, alignment: .top)
            .padding()
            .background(.background)
        } customize: {
            $0
                .closeOnTapOutside(true)
                .backgroundColor(.appText.opacity(0.5))
        }
    }
}

//#Preview {
//    DateSetupView(viewModel: DateSetupViewModel(dateSetupService: DefaultDateSetupService(localNotificationManager: DefaultLocalNotificationManager.shared, databaseRepository: RealmRepository.shared), movie: (123, "", "", ""), type: .want), isPresented: .constant(true))
//}
