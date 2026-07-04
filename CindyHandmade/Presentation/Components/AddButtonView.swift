//
//  Button.swift
//  CindyHandmade
//
//  Created by TrungTien on 3/7/26.
//

import SwiftUI

struct AddButtonView: View {
    var body: some View {
        Button {
            
        } label: {
            Image(systemName: "plus")
                .font(.title2)
        }
        .foregroundStyle(Color.white)
        .frame(width: 50, height: 50)
        .background(Color.blue)
        .clipShape(Circle())
    }
}

#Preview {
    AddButtonView()
}
