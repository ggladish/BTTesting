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
    var device: BTDevice
    
    @State private var isEditing = false
    @State private var name = ""
    
    var body: some View {
        connectionButton
        .swipeActions { editButton }
        .popover(isPresented: $isEditing) {
            nameEditor
            .presentationCompactAdaptation(.popover)
        }
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
        Button {
            name = device.displayName
            isEditing = true
        } label: {
            Text("Edit")
        }
    }
    
    private var nameEditor: some View {
        VStack {
            Text("Device Name")
            TextField("Assign a device name", text: $name)
            .border(.secondary)
            .padding(.horizontal)
            updateNameButton
            .padding(.vertical, 5)
            cancelNameEditsButton
        }
    }
    
    private var updateNameButton: some View {
        Button() {
            btManager.updateName(name, for: device)
            isEditing = false
        } label: {
            ZStack {
                Text("Save")
                    .foregroundStyle(.black)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .background(Capsule().foregroundStyle(.gray))
            }
        }
    }
    
    private var cancelNameEditsButton: some View {
        Button(role: .cancel) {
            isEditing = false
        } label: {
            Text("Cancel")
                .padding(.horizontal)
                .padding(.vertical, 2)
                .background(Capsule().stroke(lineWidth: 1.0))
        }
    }
}

#Preview {
    
    BTDeviceView(device: BTDevice(deviceName: "Test Device", id: UUID()))
        .environment(BTManager())
}
