//
//  BTDeviceView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 12/13/24.
//

import SwiftUI
import CoreBluetooth

struct BTDeviceView: View {
    @Environment(BTManager.self) private var btManager: BTManager
    @Binding var device: BTDevice
    
    @State private var isEditing = false
       
    var body: some View {
        if isEditing {
            TextField("Assign a device name", text: $device.displayName)
                .onSubmit {
                    isEditing = false
                    btManager.setKnown(device)
                }
        } else {
            connectionButton
                .listRowBackground(device.isConnected ? device.isStalled ?
                                   Constants.HighlightColor.stalled :
                                    Constants.HighlightColor.active :
                                    Constants.HighlightColor.inactive)
                .swipeActions(edge: .leading) { editButton }
                .swipeActions { deleteButton }
        }
        //        .popover(isPresented: $isEditing) {
        //            nameEditor
//            .presentationCompactAdaptation(.popover)
//        }
    }
    
    private var connectionButton: some View {
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
    }
    
    private var editButton: some View {
        Button("Edit") {
            isEditing = true
        }
    }
 
    private var deleteButton: some View {
        Button("Delete", role: .destructive) {
            btManager.removeDevice(device)
        }
    }
    
    private struct Constants {
        static let stallInterval: TimeInterval = -15.0
        struct HighlightColor {
            static let active = Color.blue.opacity(0.2)
            static let stalled = Color.red.opacity(0.2)
            static let inactive = Color.gray.opacity(0.2)
        }
    }

}

#Preview {
    @Previewable @State var device = BTDevice(deviceName: "Test Device", id: UUID())
    
    BTDeviceView(device: $device)
        .environment(BTManager())
}
