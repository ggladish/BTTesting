//
//  BTDeviceListItemView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 12/13/24.
//

import SwiftUI
import CoreBluetooth

struct BTDeviceListItemView: View {
    @Environment(BTManager.self) private var btManager: BTManager
    @Binding var device: BTDevice
    
    @State private var isEditingDeviceName = false
    @State private var isDisplaying = false
       
    var body: some View {
        if isEditingDeviceName {
            TextField("Assign a device name", text: $device.displayName)
                .onSubmit {
                    isEditingDeviceName = false
                    btManager.setKnown(device)
                }
        } else {
            Text(device.displayName)
//            DeviceConnectionButton(device: $device)
//                .contentShape(Rectangle())
//                .onLongPressGesture { isEditingDeviceName = true }  // TODO: Add Haptic 
//                .swipeActions(edge: .leading) { editNameButton }  // redundant since onLongPressGesture works
//                .swipeActions(edge: .leading) { displayDetailsButton }
//                .swipeActions { deleteButton }
//                .sheet(isPresented: $isDisplaying) {
//                    DeviceDetailView(device: $device)
//                }
        }
//            .presentationCompactAdaptation(.popover)
    }
    
//    private var connectionButton: some View {
//        Button {
//            device.isConnected ?
//            btManager.deselectBluetoothDevice(device) :
//            btManager.selectBluetoothDevice(device)
//        } label: {
//            Text(device.displayName)
//        }
//        .disabled(device.peripheral == nil)
//        // TODO: could this check that the device is actually present?
//        // Currently, just checks that it has been present since the app started
//    }
    
//    private var editNameButton: some View {
//        Button("Edit") {
//            isEditingDeviceName = true
//        }
//    }
//    
//    private var displayDetailsButton: some View {
//        Button("Details",systemImage: "list.bullet.rectangle") {
//            isDisplaying = true
//        }
//    }
// 
//    private var deleteButton: some View {
//        Button("Delete", role: .destructive) {
//            btManager.removeDevice(device)
//        }
//    }
    
//    private struct Constants {
//        static let stallInterval: TimeInterval = -15.0
//        struct HighlightColor {
//            static let active = Color.blue.opacity(0.2)
//            static let stalled = Color.red.opacity(0.2)
//            static let inactive = Color.gray.opacity(0.2)
//        }
//    }

}

#Preview {
    @Previewable @State var device = BTDevice(deviceName: "Test Device", id: UUID())
    
    BTDeviceListItemView(device: $device)
        .environment(BTManager())
}
