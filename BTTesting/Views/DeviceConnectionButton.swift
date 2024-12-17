//
//  DeviceConnectionButton.swift
//  BTTesting
//
//  Created by Gregory Gladish on 12/17/24.
//

import SwiftUI

struct DeviceConnectionButton: View {
    @Environment(BTManager.self) private var btManager: BTManager
    @Binding var device: BTDevice

    var body: some View {
            Button {
                device.isConnected ?
                btManager.deselectBluetoothDevice(device) :
                btManager.selectBluetoothDevice(device)
            } label: {
                Text(device.displayName)
            }
        .disabled(device.peripheral == nil)
        // TODO: could this check that the device is actually present?
        // Currently, just checks that it has been present since the app started
        .listRowBackground(device.isConnected ? device.isStalled ?
                           Constants.HighlightColor.stalled :
                            Constants.HighlightColor.active :
                            Constants.HighlightColor.inactive)

    }
    
    private struct Constants {
       struct HighlightColor {
            static let active = Color.blue.opacity(0.2)
            static let stalled = Color.red.opacity(0.2)
            static let inactive = Color.gray.opacity(0.2)
        }
    }

}

#Preview {
    @Previewable @State var device = BTDevice(deviceName: "Test Device", id: UUID())
    
    DeviceConnectionButton(device: $device)
        .environment(BTManager())
}
