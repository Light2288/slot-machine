//
//  LogoView.swift
//  Slot Machine
//
//  Created by Davide Aliti on 05/09/22.
//

import SwiftUI

struct LogoView: View {
    // MARK: - Properties
    
    // MARK: - Body
    var body: some View {
        Image("gfx-slot-machine")
            .resizable()
            .scaledToFit()
            .frame(minWidth: 256, idealWidth: 300, maxWidth: 320, minHeight: 112, idealHeight: 130, maxHeight: 140, alignment: .center)
            .padding(.horizontal)
            .layoutPriority(1)
            .modifier(ShadowModifier())
    }
}

// MARK: - Preview
struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
