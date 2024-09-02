//
//  SearchView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import SwiftUI
import Foundation

struct SearchView: View {
    @State private var legoSets: LegoSetList?
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    TextField("LEGO Set Name", text: $searchText)
                        .padding(.leading)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        let rebrickableAPIClient = RebrickableAPIClient()
                        rebrickableAPIClient.searchLegoSetsByName(searchText: searchText) { result in
                            switch result {
                            case .success(let legoSetList):
                                self.legoSets = legoSetList
                                print(legoSets as Any)
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                    }) {
                        Text("Search")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 33)
                            .frame(maxWidth: 100)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.trailing)
                    }
                }
                .padding(.top)
                
                List {
                    ForEach(legoSets?.results ?? []) { legoSet in
                        NavigationLink(destination: LegoSetDetailView(legoSet: legoSet, firebaseManager: FirebaseManager())) {
                            LegoSetSearchRowView(legoSet: legoSet)
                        }
                    }
                }
                
                /*List(legoSets?.results ?? []) { legoSet in
                                VStack(alignment: .leading) {
                                    Text(legoSet.name)
                                        .font(.headline)
                                    Text("Set Number: \(legoSet.setNum)")
                                    Text("Year: \(legoSet.year)")

                                    if let imageURL = legoSet.setImgURL {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 100, height: 100)
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 100, height: 100)
                                            case .empty:
                                                ProgressView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }

                                    Text("Last Modified: \(legoSet.lastModifiedDt)")
                                }
                                .padding()
                            }
                 */
            }
            .navigationTitle("Search")
        }
        
        
        
        
    }
}

#Preview {
    SearchView()
}
