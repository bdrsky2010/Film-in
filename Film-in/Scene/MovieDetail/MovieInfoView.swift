//
//  MovieInfoView.swift
//  Film-in
//
//  Created by Minjae Kim on 9/27/24.
//

import SwiftUI
import Kingfisher
import PopupView

struct MovieInfoView: View {
    @StateObject private var viewModel: MovieInfoViewModel
    
    @State private var isFullOverview: Bool
    
    let posterSize: CGSize
    
    init(viewModel: MovieInfoViewModel, isFullOverview: Bool = false, posterSize: CGSize) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._isFullOverview = State(wrappedValue: isFullOverview)
        self.posterSize = posterSize
    }
    
    var body: some View {
        ScrollView {
            if !viewModel.output.networkConnect {
                NotConnectView(viewModel: viewModel)
            } else {
                HStack(alignment: .lastTextBaseline) {
                    Text(viewModel.output.movieDetail.title)
                        .font(.ibmPlexMonoSemiBold(size: 30))
                        .foregroundStyle(.appText)
                    Spacer()
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.yellow)
                    Text("\(viewModel.output.movieDetail.rating.formatted())")
                        .font(.system(size: 30))
                        .foregroundStyle(.appText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .lastTextBaseline) {
                    Text(viewModel.output.movieDetail.releaseDate.replacingOccurrences(of: "-", with: "."))
                    Text("\(viewModel.output.movieDetail.runtime / 60)h \(viewModel.output.movieDetail.runtime % 60)m")
                        .padding(.leading, 8)
                }
                .font(.ibmPlexMonoSemiBold(size: 16))
                .foregroundStyle(.appText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
                HStack {
                    Button {
                        
                    } label: {
                        Text("WANT")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                    
                    Button {
                        
                    } label: {
                        Text("WATHCED")
                            .font(.ibmPlexMonoSemiBold(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(uiColor: .app).opacity(0.3))
                            .foregroundStyle(.app)
                    }
                }
                
                InfoHeader(title: "줄거리")
                    .padding(.top)
                Text(viewModel.output.movieDetail.overview)
                    .font(.ibmPlexMonoMedium(size: 18))
                    .foregroundStyle(.appText)
                    .lineLimit(isFullOverview ? nil : 4)
                    .multilineTextAlignment(.leading)
                    .padding(4)
                
                Button {
                    withAnimation(.easeInOut) {
                        isFullOverview.toggle()
                    }
                } label: {
                    Image(systemName: isFullOverview ? "chevron.up" : "chevron.down")
                        .resizable()
                        .frame(width: 20, height: 12)
                        .foregroundStyle(.app)
                }
                .padding()
                
                InfoHeader(title: "배우/제작진")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Button {
                                
                            } label: {
                                VStack {
                                    Circle()
                                        .frame(width: 90, height: 90)
                                        .tint(.appText)
                                    Text("Joy (voice)")
                                        .font(.ibmPlexMonoRegular(size: 16))
                                        .foregroundStyle(.appText)
                                        .frame(width: 90)
                                    Text("이름이름이름이름이름이름")
                                        .font(.ibmPlexMonoRegular(size: 16))
                                        .foregroundStyle(.appText)
                                        .frame(width: 90)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                InfoHeader(title: "장르")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Text("장르장르")
                                .font(.ibmPlexMonoMedium(size: 20))
                                .foregroundStyle(.app)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .overlay {
                                    Rectangle()
                                        .fill(Color(uiColor: .app).opacity(0.1))
                                }
                        }
                    }
                }
                .padding(.vertical, 8)
                
                InfoHeader(title: "유사한 영화")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .frame(
                                    width: posterSize.width * 0.5,
                                    height: posterSize.height * 0.5
                                )
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                InfoHeader(title: "배경화면")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .frame(
                                    width: posterSize.height * 0.4 * 1.778,
                                    height: posterSize.height * 0.4
                                )
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                InfoHeader(title: "포스터")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .frame(
                                    width: posterSize.width * 0.5,
                                    height: posterSize.height * 0.5
                                )
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 8)
                
                InfoHeader(title: "동영상")
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 12) {
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .frame(
                                    width: posterSize.width * 0.5,
                                    height: posterSize.height * 0.5
                                )
                                .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .padding(.top, 24)
        .task {
            viewModel.action(.viewOnTask)
        }
        .popup(isPresented: $viewModel.output.isShowAlert) {
            VStack {
                Text("apiRequestError")
                    .font(.ibmPlexMonoSemiBold(size: 20))
                    .padding(.top)
                Button {
                    viewModel.action(.refresh)
                } label: {
                    Text("refresh")
                        .font(.ibmPlexMonoMedium(size: 20))
                        .underline()
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 4)
            }
            .frame(maxWidth: .infinity)
            .background(.red)
        } customize: {
            $0
                .type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: true))
                .animation(.bouncy)
                .position(.top)
                .dragToDismiss(true)
        }
    }
}

fileprivate struct NotConnectView: View {
    @ObservedObject var viewModel: MovieInfoViewModel
    
    var body: some View {
        VStack {
            Text("notConnectInternet")
                .font(.ibmPlexMonoSemiBold(size: 20))
                .foregroundStyle(.appText)
            Button {
                withAnimation {
                    viewModel.action(.refresh)
                }
            } label: {
                Text("refresh")
                    .font(.ibmPlexMonoMedium(size: 20))
                    .underline()
                    .foregroundStyle(.app)
            }
        }
    }
}

fileprivate struct InfoHeader: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .font(.ibmPlexMonoSemiBold(size: 24))
            .foregroundStyle(.appText)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    @Namespace var namespace
    return MovieDetailView(offset: .constant(0), showDetailView: .constant(true), namespace: namespace, movie: .init(_id: 1022789, title: "인사이드 아웃 2", poster: "/x2BHx02jMbvpKjMvbf8XxJkYwHJ.jpg"), size: CGSize(width: 275.09999999999997, height: 412.65))
}
