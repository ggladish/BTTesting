//
//  ScanButtonView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 10/5/24.
//

import SwiftUI

struct ScanButtonView: View {
    var isScanning: Bool
    
    var body: some View {
        isScanning ?
        Text("Scanning") :
        Text("Not Scanning")
    }
}

#Preview {
    ScanButtonView(isScanning: true)
}
