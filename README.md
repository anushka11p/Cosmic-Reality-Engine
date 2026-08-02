# Cosmic Reality Engine

A modern real-time computer vision experience that blends hand tracking, four-dimensional geometry, procedural rendering, and cinematic visual effects. Using only two hands and a webcam, users can summon, manipulate, and collapse a dynamic hyperspace object that appears to exist within the real world.

The project combines Apple's Vision framework, Metal, Core Image, and SwiftUI to create an interactive "dimensional drift" experience inspired by science fiction interfaces and cinematic visual effects.

---

## Screenshots

### The App in Action

<img width="800" height="800" alt="Screenshot 2026-08-02 at 12 38 09 AM" src="https://github.com/user-attachments/assets/55728394-56a0-432c-b546-7a8133f64f54" />



```
/assets/screenshots/app.png
```

---

### Big Bang Event

<img width="800" height="800" alt="Screenshot 2026-08-02 at 12 39 07 AM" src="https://github.com/user-attachments/assets/40977cf9-2687-42df-8b12-5647b8d62340" />


```
/assets/screenshots/bigbang.png
```

---

## Features

* Real-time hand tracking using Apple's Vision framework
* Dynamic palm detection and gesture analysis
* Four-dimensional rotating tesseract renderer
* Crystal energy core with procedural glow
* Animated galaxy halo surrounding the object
* Orbiting dimensional fragments
* Dynamic starfield that fades into the environment
* Space transformation effect during dimensional drift
* Camera distortion using Metal and Core Image
* Interactive scaling and rotation based on hand movement
* Big Bang event triggered through a clap gesture
* Real-time rendering at interactive frame rates
* Modular SwiftUI architecture

---


## How It Works

### 1. Hand Tracking

The application uses Apple's Vision framework to detect both hands in real time. Palm positions and landmarks are continuously extracted from the camera stream.

---

### 2. Gesture Processing

The tracked landmarks are converted into palm centers and gesture states. The midpoint between both hands determines the position of the dimensional object.

The distance between the palms controls the object's scale, while the relative orientation of the hands influences its rotation.

---

### 3. Four-Dimensional Projection

Instead of rendering a traditional cube, the engine projects a tesseract (4D hypercube) into three-dimensional space using six independent rotation planes.

The projected vertices are then rendered as layered wireframes to create the illusion of higher-dimensional movement.

---

### 4. Cinematic Effects

Several procedural rendering systems enhance the illusion:

* Crystal energy core
* Galaxy halo
* Orbiting fragments
* Dynamic starfield
* Environmental darkening
* Camera lens distortion
* Big Bang collapse effect

---

## Project Structure

```
GestureFX
│
├── CameraCoordinateMapper.swift
├── CosmicCameraController.swift
├── CosmicMetalView.swift
├── ContentView.swift
│
├── EffectsEngine.swift
├── DimensionMath.swift
├── HandGeometry.swift
├── HandSkeletonOverlay.swift
│
├── CosmicDimensionView.swift
├── TesseractRenderer.swift
├── CrystalCore.swift
├── GalaxyHalo.swift
├── OrbitingFragments.swift
├── StarfieldBackground.swift
│
├── BigBangEffect.swift
├── SoundEngine.swift
│
└── Assets
```

---

## Technologies Used

* Swift
* SwiftUI
* Vision Framework
* AVFoundation
* MetalKit
* Core Image
* Core Graphics
* Combine

---

## Requirements

* macOS 15+
* Xcode 16+
* Apple Silicon Mac (recommended)
* Webcam

---

## Installation

Clone the repository.

```bash
git clone https://github.com/yourusername/Cosmic-Reality-Engine.git
```

Open the project.

```bash
cd Cosmic-Reality-Engine
open ComicEngine.xcodeproj
```

Run the application directly from Xcode.

---

## Controls

| Action              | Result                    |
| ------------------- | ------------------------- |
| Show both palms     | Summon dimensional object |
| Move hands          | Move object                |
| Move hands apart    | Increase scale             |
| Move hands together | Decrease scale             |
| Rotate hands        | Rotate tesseract           |
| Clap                | Trigger Big Bang           |

---

## Future Improvements

* Hand occlusion using segmentation
* Volumetric lighting
* Reality warp shaders
* Portal opening animation
* GPU particle simulation
* Multi-object interactions
* ARKit support
* Spatial audio
* Full six-axis gesture recognition
* RealityKit integration

---

## Inspiration

This project draws inspiration from cinematic depictions of higher-dimensional geometry, science fiction interfaces, procedural rendering, and interactive visual effects.

---

## License

This project is licensed under the MIT License.

---

## Author

**Anushka Prasad**


---

### Suggested repository structure for images

```
README.md

assets/
    screenshots/
        app.png
        bigbang.png

demo/
    demo.gif
```

A small suggestion: if you're planning to showcase this on GitHub or include it in internship applications, record a **10–15 second GIF** showing the complete sequence—normal room → hands appear → tesseract summons → rotate → scale → clap → Big Bang. A single looping GIF at the top of the README will make a much stronger first impression than several static screenshots.
