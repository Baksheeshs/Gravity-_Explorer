import AVFoundation
import SwiftUI

// MARK: - App-Wide Audio Synthesizer
class AudioManager: ObservableObject {
    nonisolated(unsafe) static let shared = AudioManager() // Singleton
    
    private var engine: AVAudioEngine
    private var sourceNode: AVAudioSourceNode?
    
    // Synthesis state for ambient
    nonisolated(unsafe) var time: Float = 0
    nonisolated(unsafe) let sampleRate: Double = 44100.0
    
    // SFX players
    private var collisionPlayer: AVAudioPlayerNode?
    private var mergePlayer: AVAudioPlayerNode?
    private var sfxFormat: AVAudioFormat?
    
    init() {
        engine = AVAudioEngine()
        setupSynthesizer()
        setupSFXPlayers()
    }
    
    // MARK: - Ambient Space Drone
    
    private func setupSynthesizer() {
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let dt = Float(1.0 / self.sampleRate)
            
            for frame in 0..<Int(frameCount) {
                // 1. Deep Sub Bass sine wave (around 50 Hz)
                let subFreq: Float = 55.0
                let subOsc = sin(2.0 * .pi * subFreq * self.time) * 0.4
                
                // 2. Slow detuned overtone (around 110 Hz) with an LFO on amplitude
                let overtoneFreq: Float = 111.0
                let lfo = (sin(2.0 * .pi * 0.1 * self.time) + 1.0) / 2.0
                let overtoneOsc = sin(2.0 * .pi * overtoneFreq * self.time) * 0.15 * lfo
                
                // Mix signals
                let sample = subOsc + overtoneOsc
                
                // Write to all channels
                for buffer in ablPointer {
                    let ptr: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    ptr[frame] = sample
                }
                
                self.time += dt
                if self.time > 1000.0 { self.time -= 1000.0 }
            }
            return noErr
        }
        
        guard let sourceNode = sourceNode else { return }
        
        let mainMixer = engine.mainMixerNode
        let format = mainMixer.inputFormat(forBus: 0)
        
        engine.attach(sourceNode)
        
        // Low-pass EQ for "space" feeling
        let eqNode = AVAudioUnitEQ(numberOfBands: 1)
        eqNode.bands[0].filterType = .lowPass
        eqNode.bands[0].frequency = 400.0
        eqNode.bands[0].bypass = false
        engine.attach(eqNode)
        
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.largeHall)
        reverbNode.wetDryMix = 60
        engine.attach(reverbNode)
        
        // Route: Source -> EQ -> Reverb -> Mixer
        engine.connect(sourceNode, to: eqNode, format: format)
        engine.connect(eqNode, to: reverbNode, format: format)
        engine.connect(reverbNode, to: mainMixer, format: format)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    // MARK: - SFX Players Setup
    
    private func setupSFXPlayers() {
        collisionPlayer = AVAudioPlayerNode()
        mergePlayer = AVAudioPlayerNode()
        
        guard let collisionPlayer = collisionPlayer,
              let mergePlayer = mergePlayer else { return }
        
        engine.attach(collisionPlayer)
        engine.attach(mergePlayer)
        
        // Use a known-good format for SFX buffers (mono float, device sample rate)
        let deviceSR = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let rate = deviceSR > 0 ? deviceSR : sampleRate
        sfxFormat = AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1)!
        
        let mainMixer = engine.mainMixerNode
        // Connect players using the mono SFX format — the engine auto-converts to mixer format
        engine.connect(collisionPlayer, to: mainMixer, format: sfxFormat)
        engine.connect(mergePlayer, to: mainMixer, format: sfxFormat)
    }
    
    // MARK: - Synthesized Collision Sound (Short Explosive Boom)
    
    func playCollisionSound() {
        if !engine.isRunning { playSpaceAmbient() }
        guard let player = collisionPlayer else { return }
        playSynthBuffer(player: player, generator: Self.generateCollisionBuffer)
    }
    
    // MARK: - Synthesized Merge Sound (Deeper Rumble)
    
    func playMergeSound() {
        if !engine.isRunning { playSpaceAmbient() }
        guard let player = mergePlayer else { return }
        playSynthBuffer(player: player, generator: Self.generateMergeBuffer)
    }
    
    // MARK: - Buffer Generation Helpers
    
    private func playSynthBuffer(player: AVAudioPlayerNode, generator: (AVAudioFormat) -> AVAudioPCMBuffer?) {
        guard let fmt = sfxFormat, let buffer = generator(fmt) else { return }
        player.stop()
        player.scheduleBuffer(buffer, completionHandler: nil)
        player.play()
    }
    
    /// Generates a short explosive boom: white noise burst + descending sine sweep
    static func generateCollisionBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sr = format.sampleRate
        let duration: Double = 0.4
        let frameCount = AVAudioFrameCount(sr * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        
        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData else { return nil }
        let channels = Int(format.channelCount)
        
        let dt = Float(1.0 / sr)
        var t: Float = 0
        
        for i in 0..<Int(frameCount) {
            let progress = Float(i) / Float(frameCount)
            let envelope = exp(-progress * 8.0) * (1.0 - exp(-progress * 200.0))
            let freq = 200.0 - progress * 160.0
            let sine = sin(2.0 * .pi * freq * t)
            let noise = Float.random(in: -1...1) * exp(-progress * 12.0)
            let sample = (sine * 0.7 + noise * 0.5) * envelope * 0.8
            
            for ch in 0..<channels {
                channelData[ch][i] = sample
            }
            t += dt
        }
        
        return buffer
    }
    
    /// Generates a deeper, longer rumble for planet merges
    static func generateMergeBuffer(format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sr = format.sampleRate
        let duration: Double = 0.8
        let frameCount = AVAudioFrameCount(sr * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        
        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData else { return nil }
        let channels = Int(format.channelCount)
        
        let dt = Float(1.0 / sr)
        var t: Float = 0
        
        for i in 0..<Int(frameCount) {
            let progress = Float(i) / Float(frameCount)
            let envelope = exp(-progress * 4.0) * (1.0 - exp(-progress * 100.0))
            let freq = 100.0 - progress * 75.0
            let sine = sin(2.0 * .pi * freq * t)
            let subSine = sin(2.0 * .pi * (freq * 0.5) * t) * 0.4
            let noise = Float.random(in: -1...1) * exp(-progress * 6.0) * 0.3
            let sample = (sine * 0.6 + subSine + noise) * envelope * 0.7
            
            for ch in 0..<channels {
                channelData[ch][i] = sample
            }
            t += dt
        }
        
        return buffer
    }
    
    // MARK: - Playback Controls
    
    func playSpaceAmbient() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Engine failed to start: \(error)")
        }
    }
    
    func stop() {
        engine.pause()
    }
}
