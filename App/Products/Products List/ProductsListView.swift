//
//  ProductsListView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI

enum SortType: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case updated = "Updated"
    case alphabetical = "Alphabetical"
}

struct ProductsListView {
    
    @StateObject var viewModel: ViewModel
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var layout: [GridItem] {
        if horizontalSizeClass == .compact {
            [GridItem(.flexible(), alignment: .top)]
        } else {
            [GridItem(.adaptive(minimum: 360), alignment: .top)]
        }
    }
    #else
    var layout = [GridItem(.adaptive(minimum: 360), alignment: .top)]
    #endif
    
    init(type: AppType) {
        self._viewModel = StateObject(wrappedValue: ViewModel(type: type))
    }
}
    
extension ProductsListView: View {
    var body: some View {
        content
            .searchable(text: $viewModel.search)
            .overlay {
                emptyState
            }
            .task {
                await viewModel.getList()
            }
            .refreshable {
                await viewModel.getList()
            }
            .toolbar {
                #if os(macOS)
                ToolbarItem {
                    Button {
                        Task {
                            await viewModel.getList()
                        }
                    } label: {
                        if viewModel.loading && !viewModel.products.isEmpty {
                            ProgressView()
                                .scaleEffect(0.5)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                    .disabled(viewModel.loading)
                }
                #endif
                ToolbarItem {
                    #if os(macOS)
                    sortPicker
                    #elseif os(iOS)
                    Menu {
                        sortPicker
                    } label: {
                        Label("Sort by", systemImage: "slider.horizontal.3")
                    }
                    #endif
                }
            }
    }
    
    var content: some View {
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(
                    viewModel.products.isEmpty && viewModel.message == "" ?
                    viewModel.dummyProducts :
                    viewModel.products,
                    id: \.id
                ) { product in
                    NavigationLink {
                        ProductDetailsView(product: product)
                    } label: {
                        ProductItemView(product: product)
                            .redacted(reason: viewModel.products.isEmpty ? .placeholder : [])
                            .shimmering(active: viewModel.products.isEmpty)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.products.isEmpty)
                }
            }
            .padding()
        }
    }
    
    var sortPicker: some View {
        Picker("Sort by", selection: $viewModel.sortType) {
            ForEach(SortType.allCases, id: \.self) { type in
                Text(type.rawValue)
            }
        }
        #if os(iOS)
        .onChange(of: viewModel.sortType) { _ in
            HapticFeedback.shared.start(.medium)
        }
        #endif
    }
    
    var emptyState: some View {
        ZStack {
            /// Failed Empty state
            if !viewModel.loading && viewModel.products.isEmpty && viewModel.message != "" {
                EmptyStateView(
                    icon: "wifi.exclamationmark",
                    showAlt: false,
                    title: viewModel.message,
                    actionTitle: "Try again"
                ) {
                    Task {
                        await viewModel.getList()
                    }
                }
            }
        }
    }
}

struct ProductsListView_Previews: PreviewProvider {
    @ObservedObject static var i18n = I18nService()
    
    static var previews: some View {
        ProductsListView(type: .app)
            .environmentObject(i18n)
            .navigationTitle("Apps")
    }
}
