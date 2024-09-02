//
//  SavedSetsView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 04/01/2024.
//

import SwiftUI

struct SavedSetsView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading) {
                if firebaseManager.setsInCollectionList.isEmpty {
                    Text("You have no saved sets.")
                        .padding()
                } else {
                    Text("Sets in collection: \(firebaseManager.setsInCollectionList.count)")
                        .padding()
                    List(firebaseManager.setsInCollectionList) { item in
                        NavigationLink(destination: LegoSetDetailView(legoSet: item, firebaseManager: firebaseManager)) {
                            LegoSetSearchRowView(legoSet: item)
                        }
                    }
                }
            }
            .padding(.top)
            .onAppear {
                firebaseManager.getUserSetCollectionListFromFirebase()
            }
            .navigationTitle("Collection")
        }
    }
}
