//
//  ContentView.swift
//  CISYNTH_App
//
//  Created by Zhonx on 22/03/2025.
//
//  Swift code in English, with "Allman style" braces.

import SwiftUI
import AppKit // For NSOpenPanel

struct ContentView: View
{
    // MARK: - Spectrogram Parameter States
    @State private var fftSize: String = "8192"
    @State private var overlap: String = "0.85"
    @State private var minFreq: String = "65"
    @State private var maxFreq: String = "16640"
    @State private var duration: String = "4.0"
    @State private var sampleRate: String = "192000"
    @State private var dynamicRangeDB: String = "60.0"
    @State private var gammaCorrection: String = "0.8"
    @State private var enableDithering: Bool = false
    @State private var contrastFactor: String = "1.9"
    @State private var enableHighBoost: Bool = true
    @State private var highBoostAlpha: String = "0.99"

    // Input/output file path states
    @State private var inputFilePath: String = ""
    @State private var outputFolderPath: String = ""

    // MARK: - Body
    var body: some View
    {
        VStack(alignment: .leading, spacing: 10)
        {
            Text("Spectrogram Settings").font(.headline)

            Group
            {
                HStack
                {
                    Text("FFT Size:")
                    TextField("8192", text: $fftSize)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Overlap (0..1):")
                    TextField("0.85", text: $overlap)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Min Frequency (Hz):")
                    TextField("65", text: $minFreq)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Max Frequency (Hz):")
                    TextField("16640", text: $maxFreq)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Duration (s):")
                    TextField("4.0", text: $duration)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Sample Rate:")
                    TextField("192000", text: $sampleRate)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Dynamic Range (dB):")
                    TextField("60.0", text: $dynamicRangeDB)
                        .frame(width: 80)
                }

                HStack
                {
                    Text("Gamma Correction:")
                    TextField("0.8", text: $gammaCorrection)
                        .frame(width: 80)
                }

                Toggle("Enable Dithering", isOn: $enableDithering)

                HStack
                {
                    Text("Contrast Factor:")
                    TextField("1.9", text: $contrastFactor)
                        .frame(width: 80)
                }

                Toggle("High Boost Filter", isOn: $enableHighBoost)

                HStack
                {
                    Text("High Boost Alpha:")
                    TextField("0.99", text: $highBoostAlpha)
                        .frame(width: 80)
                }
            }

            Divider().padding(.vertical, 5)

            Text("Input File:")
            HStack
            {
                TextField("Choose WAV file...", text: $inputFilePath)
                    .frame(minWidth: 200)
                Button("Browse...")
                {
                    selectInputFile()
                }
            }

            Text("Output Folder:")
            HStack
            {
                TextField("Choose folder...", text: $outputFolderPath)
                    .frame(minWidth: 200)
                Button("Browse...")
                {
                    selectOutputFolder()
                }
            }

            Button("Generate Spectrogram")
            {
                generateSpectrogram()
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 400)
    }

    // MARK: - File Selection
    private func selectInputFile()
    {
        let panel = NSOpenPanel()
        panel.title = "Select WAV file"
        panel.allowedContentTypes = [.audio]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK
        {
            if let url = panel.url
            {
                inputFilePath = url.path
            }
        }
    }

    private func selectOutputFolder()
    {
        let panel = NSOpenPanel()
        panel.title = "Select Output Folder"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK
        {
            if let url = panel.url
            {
                outputFolderPath = url.path
            }
        }
    }

    // MARK: - Call the C code
    private func generateSpectrogram()
    {
        // Convert Swift strings to C types.
        guard !inputFilePath.isEmpty, !outputFolderPath.isEmpty else { return }

        let outPNG = (outputFolderPath as NSString).appendingPathComponent("spectrogram.png")

        // Parse user inputs.
        var cfg = SpectrogramSettings(
            fftSize: Int32(fftSize) ?? 0,
            overlap: Double(overlap) ?? 0.0,
            minFreq: Double(minFreq) ?? 0.0,
            maxFreq: Double(maxFreq) ?? 0.0,
            duration: Double(duration) ?? 0.0,
            sampleRate: Int32(sampleRate) ?? 0,
            dynamicRangeDB: Double(dynamicRangeDB) ?? 0.0,
            gammaCorrection: Double(gammaCorrection) ?? 0.0,
            enableDithering: enableDithering ? 1 : 0,
            contrastFactor: Double(contrastFactor) ?? 0.0,
            enableHighBoost: enableHighBoost ? 1 : 0,
            highBoostAlpha: Double(highBoostAlpha) ?? 0.0
        )

        // Call the C function via the bridging header.
        let result = spectral_generator(&cfg, inputFilePath, outPNG)

        if result == 0
        {
            print("Spectrogram generated successfully at: \(outPNG)")
        }
        else
        {
            print("Error generating spectrogram. Return code: \(result)")
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
