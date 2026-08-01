import AVFoundation

final class SoundEngine {
    static let shared = SoundEngine()

    private var player: AVAudioPlayer?
    private var isPlaying = false

    func loadSound(named name: String, ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Could not find \(name).\(ext) in bundle")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1   // loop forever while playing
            player?.volume = 0.6
            player?.prepareToPlay()
        } catch {
            print("Failed to load sound:", error)
        }
    }

    func setActive(_ active: Bool) {
        guard let player = player else { return }
        if active && !isPlaying {
            player.play()
            isPlaying = true
        } else if !active && isPlaying {
            player.stop()
            player.currentTime = 0
            isPlaying = false
        }
    }
}
