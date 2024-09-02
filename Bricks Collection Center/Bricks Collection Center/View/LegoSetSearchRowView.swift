//
//  LegoSetSearchRowView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import SwiftUI

struct LegoSetSearchRowView: View {
    let legoSet: LegoSet

    var body: some View {
        VStack(alignment: .leading) {
            Text(legoSet.name)
                .font(.headline)
            Text("Set Number: \(legoSet.setNum)")
            Text("Year: \(String(legoSet.year))")

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
        }
        .padding()
    }
}
