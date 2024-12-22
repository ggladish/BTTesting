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
        NavigationStack {
            Form {
                bluetoothScanState
                displayBluetoothDevices
            }
            .navigationDestination(for: BTDevice.self) { device in
                if let index = bluetoothManager.index(of: device) {
                    DeviceDetailView(device: $bluetoothManager.availableBTDevices[index])
                }
            }
       }
        .refreshable {
            bluetoothManager.startBluetoothScan()
        }
        .padding()
        .environment(bluetoothManager)
    }
    
    private var bluetoothScanState: some View {
            ScanButtonView(isScanning: bluetoothManager.isScanning )
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
                if let index = bluetoothManager.index(of: device) {
                    NavigationLink(value: device) {
                        BTDeviceListItemView(device: $bluetoothManager.availableBTDevices[index])
                    }
                }
            }
        }
    }
    
    private var unknownDeviceSection: some View {
        Section("Unnown Devices") {
            ForEach (bluetoothManager.unknownDevices) { device in
                if let index = bluetoothManager.index(of: device) {
                    NavigationLink(value: device) {
                        BTDeviceListItemView(device: $bluetoothManager.availableBTDevices[index])
                    }
                }
            }
        }
    }
    
}

#Preview {
    BluetoothTesterView()
}
