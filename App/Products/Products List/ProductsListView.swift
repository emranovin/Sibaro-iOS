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
    case oldest = "Oldest"
    case updated = "Updated"
    case alphabetical = "Alphabetical"
}

struct ProductsListView: View {
    
    @StateObject var viewModel: ViewModel
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    init(type: AppType) {
        self._viewModel = StateObject(wrappedValue: ViewModel(type: type))
    }
    
    var body: some View {
        Group {
            #if os(iOS)
            if horizontalSizeClass == .compact {
                normalList
            } else {
                gridList
            }
            #else
            gridList
            #endif
        }
        .overlay {
            emptyState
        }
        .searchable(text: $viewModel.search)
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
        .sheet(item: $viewModel.selectedProduct) { product in
            ProductDetailsView(product: product)
                #if os(macOS)
                .frame(minWidth: 350, idealWidth: 600, minHeight: 500, idealHeight: 650)
                #endif
        }
    }
    
    var normalList: some View {
        List(
            viewModel.products.isEmpty && viewModel.message == "" ?
            viewModel.dummyProducts :
            viewModel.products,
            id: \.id
        ) { product in
            Button {
                viewModel.selectedProduct = product
            } label: {
                ProductItemView(product: product)
                    .redacted(reason: viewModel.products.isEmpty ? .placeholder : [])
                    .shimmering(active: viewModel.products.isEmpty)
            }
            .disabled(viewModel.products.isEmpty)
            .onAppear {
                viewModel.rowDidAppear(withProduct: product)
            }
        }
        .listStyle(.plain)
    }
    
    var gridList: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 360), alignment: .top)]) {
                ForEach(
                    viewModel.products.isEmpty && viewModel.message == "" ?
                    viewModel.dummyProducts :
                    viewModel.products,
                    id: \.id
                ) { product in
                    ProductItemView(product: product)
                        .padding()
                        .redacted(reason: viewModel.products.isEmpty ? .placeholder : [])
                        .shimmering(active: viewModel.products.isEmpty)
                        .onTapGesture {
                            if !viewModel.products.isEmpty {
                                viewModel.selectedProduct = product
                            }
                        }
                        .onAppear {
                            viewModel.rowDidAppear(withProduct: product)
                        }
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
        NavigationStack {
            ProductsListView(type: .app)
                .environmentObject(i18n)
                .navigationTitle("Apps")
        }
    }
}
