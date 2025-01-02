//
//  DeviceDetailView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 12/16/24.
//

import SwiftUI

struct DeviceDetailView: View {
    @Environment(BTManager.self) private var btManager: BTManager
    @Binding var device: BTDevice
    
    // Things we might want to display or indicate
//    private(set) var connectRequested = false
//    var stallTimer: Timer?
//    var isStalled: Bool = true
//    var deviceType = DeviceType.unknown

    @State private var isEditing = false

    var body: some View {
        Form {
            editableDisplayName
            DeviceInfoView(devInfo: device.deviceInformation)
            lastPacketSection
            forgetDeviceButton
        }
        .onAppear {
            if device.deviceInformation.isEmpty {
                btManager.requestDeviceInformation(for: device)
            }
        }
    }
    
    private var editableDisplayName: some View {
        Section("Device Name") {
            if isEditing {
                TextField("Assign a device name", text: $device.displayName)
                    .onSubmit {
                        isEditing = false
                        btManager.setKnown(device)
                    }
            } else {
                DeviceConnectionButton(device: $device)
                    .sensoryFeedback(.start, trigger: isEditing) // TODO: Figure out why haptic isn't happening
                    .onLongPressGesture { isEditing = true }
            }
        }
    }
    
    private var lastPacketSection: some View {
        Section("Last Packet") {
            HStack {
                Text("Packet Time:")
                Spacer()
                Text(device.lastPacketDate?.formatted() ?? "None")
            }
            Text(device.lastPacket ?? "").lineLimit(2)
        }
    }
    
    private var forgetDeviceButton: some View {
        Button("Forget", role: .destructive) {
            btManager.removeDevice(device)
            // TODO: also navigate back
        }
    }
 
    
}

#Preview {
    @Previewable @State var device = BTDevice(deviceName: "Test Device", id: UUID())
    
    DeviceDetailView(device: $device)
        .environment(BTManager())

}
