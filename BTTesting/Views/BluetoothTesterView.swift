//
//  BluetoothTesterView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 9/30/24.
//

import SwiftUI

struct BluetoothTesterView: View {
    @State var bluetoothManager = BTManager()
    
    var body: some View {
        VStack {
            bluetoothScanControlButton
            displayBluetoothDevices
        }
        .padding()
        .environment(bluetoothManager)
    }
    
    private var bluetoothScanControlButton: some View {
        Button {
            bluetoothManager.isScanning ?
            bluetoothManager.endBluetoothScan() :
            bluetoothManager.startBluetoothScan()
        } label: {
            ScanButtonView(isScanning: bluetoothManager.isScanning )
        }
    }
    
    private var displayBluetoothDevices: some View {
        List {
            knownDeviceSection
            unknownDeviceSection
        }
    }
    
    private var knownDeviceSection: some View {
        Section("Known Devices") {
            ForEach (bluetoothManager.knownDevices) { device in
                BTDeviceView(device: device)
                    .listRowBackground(device.isConnected ?
                                       Constants.HighlightColor.active :
                                        Constants.HighlightColor.inactive)
            }
        }
    }
    
    private var unknownDeviceSection: some View {
        Section("Unnown Devices") {
            ForEach (bluetoothManager.unknownDevices) { device in
                BTDeviceView(device: device)
                    .listRowBackground(device.isConnected ?
                                       Constants.HighlightColor.active :
                                        Constants.HighlightColor.inactive)
            }
        }
    }
    
    private struct Constants {
        struct HighlightColor {
            static let active = Color.blue.opacity(0.2)
            static let inactive = Color.gray.opacity(0.2)
        }
    }
}

#Preview {
    BluetoothTesterView()
}
