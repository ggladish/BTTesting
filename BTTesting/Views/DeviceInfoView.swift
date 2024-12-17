//
//  DeviceInfoView.swift
//  BTTesting
//
//  Created by Gregory Gladish on 12/16/24.
//

import SwiftUI

struct DeviceInfoView: View {
    var devInfo: DeviceInformation
    
    var body: some View {
        Section {
            manufacturer
            model
            serial
            hardware
            software
            firmware
            sysID
            pnpID
            medID
            ieeeData
        } header: {
            Text("Device Information")
        }
    }
    
    private var manufacturer: some View {
        HStack {
            Text("Manufacturer:")
            Spacer()
            Text(devInfo.manufacturerName ?? "Unknown")
        }
    }
    
    private var model: some View {
        HStack {
            Text("Model Number:")
            Spacer()
            Text(devInfo.modelNumber ?? "Unknown")
        }
    }
    
    private var serial: some View {
        HStack {
            Text("Serial Number:")
            Spacer()
            Text(devInfo.serialNumber ?? "Unknown")
        }
    }
    
    private var hardware: some View {
        Group {
            if let hardwareRevision = devInfo.hardwareRevision {
                HStack {
                    Text("Hardware Revision:")
                    Spacer()
                    Text(hardwareRevision)
                }

            }
        }
    }
    
    private var software: some View {
        Group {
            if let softwareRevision = devInfo.softwareRevision {
                HStack {
                    Text("Software Revision:")
                    Spacer()
                    Text(softwareRevision)
                }
            }
        }
    }
    
    private var firmware: some View {
        Group {
            if let firmwareRevision = devInfo.firmwareRevision {
                HStack {
                    Text("Firmware Revision:")
                    Spacer()
                    Text(firmwareRevision)
                }
            }
        }
    }
    
    private var sysID: some View {
        Group {
            if !devInfo.systemID.isEmpty {
                HStack {
                    Text("System ID:")
                    Spacer()
                    Text(intArrayAsString(devInfo.systemID))
                }
            }
        }
    }
    
    private var pnpID: some View {
        Group {
            if !devInfo.pnpID.isEmpty {
                HStack {
                    Text("PnP ID:")
                    Spacer()
                    Text(intArrayAsString(devInfo.pnpID))
                }
            }
        }
    }
    
    private var medID: some View {
        Group {
            if !devInfo.medicalDeviceUDI.isEmpty {
                HStack {
                    Text("Medical Device UID:")
                    Spacer()
                    Text(intArrayAsString(devInfo.medicalDeviceUDI))
                }
            }
        }
    }
    
    private var ieeeData: some View {
        // TODO: This should probably get a VStack of items instead
        // or something that represents the underlying data better
        Group {
            if !devInfo.ieeeeDataList.isEmpty{
                HStack {
                    Text("IEEE Certification List:")
                    Spacer()
                    Text(intArrayAsString(devInfo.ieeeeDataList))
                }
            }
        }
    }
    
    private func intArrayAsString(_ ints: [UInt8]) -> String {
        ints.reduce("") { $0 + String(" 0X") + String($1,radix: 16,uppercase: true)}
    }

}

#Preview {
    
    let devInfo = DeviceInformation(manufacturerName: "XRD Rocketry", modelNumber: "0001", serialNumber: "1000", hardwareRevision: "1.0", firmwareRevision: "1.0", softwareRevision: "1.2", systemID: [0xff,0x01,0xa3], pnpID: [0x01,0x00, 0x01,0x1f, 0x3b], medicalDeviceUDI: [0x00,0x01,0x02], ieeeeDataList: [0x01,0x02,0x03])

    Form {
        DeviceInfoView(devInfo: devInfo)
    }
}
