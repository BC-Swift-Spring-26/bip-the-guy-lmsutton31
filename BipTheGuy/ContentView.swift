//
//  ContentView.swift
//  BipTheGuy
//
//  Created by Luke Sutton on 2/9/26.
//

import SwiftUI
import AVFAudio
import PhotosUI

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer!
    @State private var isFullSize = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var bipImage = Image("clown")
    
    var body: some View {
        VStack {
            
            Spacer()
            
            bipImage
                .resizable()
                .scaledToFit()
                .scaleEffect(isFullSize ? 1.0 : 0.9)
                .onTapGesture {
                    playSound(soundName: "punchSound")
                    isFullSize = false // will shrink to 90%
                    withAnimation (.spring(response: 0.3, dampingFraction: 0.3)) {
                        isFullSize = true
                    }
                }
            
            
            Spacer()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.fill.on.rectangle.fill")
                        .imageScale(.large)
                        .symbolRenderingMode(.hierarchical)
                    Text("Photo Library")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    // Liquid Glass-inspired look using system material
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .hoverEffect(.highlight)
                .accessibilityLabel(Text("Open Photo Library"))
            }
            .buttonStyle(.plain)
            .onChange(of: selectedPhoto) {
                Task {
                    guard let selectedImage = try? await selectedPhoto?.loadTransferable(type: Image.self) else {
                        print("ERROR: Could not get Image from loadTransferable")
                        return
                    }
                    bipImage = selectedImage
                }
            }
            
        }
        .padding()
    }
    
    func playSound(soundName: String){
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.stop()
        }
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 Error \(error.localizedDescription) creating audioPlayer")
        }
    }
}

#Preview {
    ContentView()
}

