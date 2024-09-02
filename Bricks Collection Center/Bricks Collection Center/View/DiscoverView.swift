//
//  DiscoverView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var viewModel: DiscoverViewModel
    @EnvironmentObject var firebaseManager: FirebaseManager

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    viewModel.refreshRecommendations()
                }) {
                    Text("Proponuj")
                        .font(.headline)
                        .foregroundColor(viewModel.isLoading ? .white : .white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(viewModel.isLoading)
                
                if viewModel.currentPage > 0 && viewModel.currentPage < viewModel.totalPages {
                    Text("Ładowanie: \(viewModel.progressPercentage)%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    ProgressView(value: Float(viewModel.currentPage) / Float(viewModel.totalPages))
                        .padding()
                }
                
                if !viewModel.isLoading && viewModel.filteredLegoSets.isEmpty {
                    Text("Brak rekomendacji, kliknij przycisk 'Proponuj'")
                        .padding()
                        .foregroundColor(.gray)
                    
                    Spacer()
                } else {
                    List(viewModel.filteredLegoSets, id: \.legoSet.setNum) { scoredLegoSet in
                        NavigationLink(destination: LegoSetDetailView(legoSet: scoredLegoSet.legoSet, firebaseManager: firebaseManager)) {
                            VStack(alignment: .leading) {
                                Text(scoredLegoSet.legoSet.name)
                                    .font(.headline)
                                Text("Dopasowanie: \(Int(scoredLegoSet.totalScore))%")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Discover")
        }
    }
}
