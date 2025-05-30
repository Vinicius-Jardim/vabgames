import SwiftUI

struct PublishersListView: View {
    @StateObject private var viewModel = PublishersViewModel()
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var studioManager = StudioOfTheDayManager.shared
    @State private var searchText = ""
    
    var filteredPublishers: [Publisher] {
        if searchText.isEmpty {
            return viewModel.publishers
        } else {
            return viewModel.publishers.filter { publisher in
                publisher.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.orange.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBarView(text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            if searchText.isEmpty {
                                StudioOfTheDayView()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                            }
                            
                            if !filteredPublishers.isEmpty {
                                ForEach(filteredPublishers) { publisher in
                                    NavigationLink(destination: PublisherDetailView(publisher: publisher)) {
                                        PublisherCardView(publisher: publisher)
                                    }
                                }
                                
                                if viewModel.hasMorePages {
                                    Button(action: {
                                        Task {
                                            await viewModel.loadMorePublishers()
                                        }
                                    }) {
                                        if viewModel.isLoading {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text("Load More")
                                                .foregroundColor(.white)
                                                .padding(.vertical, 8)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            } else {
                                EmptyStateView()
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .safeAreaInset(edge: .top) {
                    Color.clear.frame(height: 1)
                }
            }
            .navigationBarHidden(true)
            .refreshable {
                Task {
                    await studioManager.checkAndUpdateStudioOfTheDay()
                    await viewModel.refreshPublishers()
                }
            }
        }
    }
}

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
            
            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Search publishers...")
                        .foregroundColor(.white.opacity(0.7))
                }
                .foregroundColor(.white)
                .autocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct PublisherCardView: View {
    let publisher: Publisher
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: publisher.imageBackground)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(publisher.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "gamecontroller.fill")
                        .foregroundColor(.white.opacity(0.8))
                    Text("\(publisher.gamesCount) games")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.orange.opacity(0.4))
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        )
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.7))
            Text("No publishers found")
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
