//
//  ProductsListView.swift
//  Sibaro
//
//  Created by Armin on 8/13/23.
//

import SwiftUI
import Shimmer

enum SortType: String, CaseIterable {
    case newest = "Newest"
    case updated = "Updated"
    case alphabetical = "Alphabetical"
    
    func asProductOrderProperty() -> Product.OrderProperty {
        switch self {
        case .newest:
            return .createdAt
        case .updated:
            return .updatedAt
        case .alphabetical:
            return .title
        }
    }
}

struct ProductsListView {
    
    @StateObject var viewModel: ViewModel
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var layout: [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), alignment: .top)]
        } else {
            return [GridItem(.adaptive(minimum: 360), alignment: .top)]
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
            .onReceive(viewModel.$search.debounce(for: .seconds(2), scheduler: DispatchQueue.main), perform: { searchQuery in
                viewModel.searchFor(query: searchQuery)
            })
            .onSubmit(of: .search, {
                print("submit")
            })
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
                    .onAppear {
                        viewModel.rowDidAppear(withProduct: product)
                    }
                }
                
                if !viewModel.products.isEmpty {
                    infiniteListFooterView
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
    
    var infiniteListFooterView: some View {
        VStack(spacing: 0) {
            if viewModel.loading {
                HStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.8)
                        .frame(alignment: .center)
                }.frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 0) {
                    Group {
                        Text("loading failed")
                        #if os(macOS)
                        Text("click to retry")
                        #else
                        Text("tap to retry")
                        #endif
                    }.frame(maxWidth: .infinity, alignment: .center)
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                }.clipped()
                    .onTapGesture {
                    viewModel.retryLoadingPage()
                }
            }
        }.id(UUID())
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        
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
