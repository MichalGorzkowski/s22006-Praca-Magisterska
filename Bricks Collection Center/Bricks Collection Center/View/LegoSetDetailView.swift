//
//  LegoSetDetailView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import SwiftUI

struct LegoSetDetailView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    let legoSet: LegoSet
    @State var isSetSaved: Bool
    @State var showingAlert = false
    @ObservedObject var viewModel: LegoSetDetailViewModel
    
    init(legoSet: LegoSet, firebaseManager: FirebaseManager) {
        self.legoSet = legoSet
        self.viewModel = LegoSetDetailViewModel()
        self._isSetSaved = State(initialValue: firebaseManager.setsInCollectionList.contains(where: { $0.setNum == legoSet.setNum }))
    }

    var body: some View {
        VStack {
            Text(legoSet.name)
                .font(.title)
                .padding()

            if let imageURL = legoSet.setImgURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding()
            }
            
            HStack (spacing: 50) {
                VStack {
                    Image("hash")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.bottom, -20)
                    Text("\(legoSet.setNum)")
                        .font(.system(size: 30))
                    Text("Set Number")
                        .font(.system(size: 15))
                }
                
                VStack {
                    Image("piece")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.bottom, -20)
                    Text("\(legoSet.numParts)")
                        .font(.system(size: 30))
                    Text("Elements")
                        .font(.system(size: 15))
                }
            }
            
            Text("Year: \(String(legoSet.year))")
                .padding()
                .font(.system(size: 15))
            
            Text("Theme: \(viewModel.themeName)")
                .padding()
                .font(.system(size: 15))

            Text("Last Modified:\n\(legoSet.lastModifiedDt)")
                .multilineTextAlignment(.center)
                .padding()
                .font(.system(size: 9))

            Spacer()
            
            Button(action: {
                if isSetSaved {
                    firebaseManager.removeSetFromCollection(legoSet: legoSet)
                } else {
                    firebaseManager.addSetToCollection(legoSet: legoSet)
                }
                isSetSaved.toggle()
                showingAlert = true
            }, label: {
                Text(isSetSaved ? "Remove from collection" : "Add to collection")
                    .foregroundColor(isSetSaved ? .red : .blue)
                    .padding()
            })
            .alert(isSetSaved ? "Set added to your collection" : "Set removed from your collection", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .onAppear {
            viewModel.loadThemeName(themeId: legoSet.themeId)
        }
    }
}
