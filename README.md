# Viso

**Viso** is a mobile information-measurement system (iOS app) for recognizing objects in images and generating human-readable explanations. It uses Apple’s **Vision** framework for on-device object detection and **FoundationModels** (Core ML) to generate GPT-style text descriptions — all running fully offline.

## 🧠 Features

- Load images from camera or photo library
- Detect multiple objects using the Vision framework
- Generate natural language explanations using FoundationModels
- Export results (object labels and confidence scores) to CSV
- Entirely offline — no internet required
- Built with The Composable Architecture (TCA)

## 📱 Interface Overview

- **Main screen**: View analyzed images and top predictions
- **Result screen**: Tap an image to view a generated explanation
- **Export**: One-tap CSV export with all object data
- Smooth navigation, iOS-native UX following Human Interface Guidelines

## 🛠 Technology Stack

- Swift 5.9 / Swift 6
- [Vision Framework](https://developer.apple.com/documentation/vision/)
- [FoundationModels](https://developer.apple.com/machine-learning/)
- [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture)
- SwiftUI & UIKit
- Local CSV export module

## 📂 Example CSV Output

```csv
ID,Observation,Confidence
E9D4732F...,table,0.87
E9D4732F...,vegetable,0.76
E9D4732F...,salad,0.72
````

Each row represents an object detected in an image with its confidence score.

## 📦 Installation (for developers)

1. Clone the repository:

   ```bash
   git clone https://github.com/jaroshevskii/Viso.git
   ```

2. Open the project in Xcode:

   ```bash
   open Viso.xcodeproj
   ```

3. Build and run on a physical iOS device (iOS 26+ recommended)

> ⚠️ **Note**: FoundationModels require Apple Silicon or A17+ for local inference

## 🧪 Sample Result

Given an image of a salad on a wooden table:

**Detected objects:**

* `structure` (0.93)
* `wood_processed` (0.93)
* `food` (0.76)
* `salad` (0.69)

**Generated explanation:**

> "The image shows a wooden table with a vegetable-based dish, likely a salad, and accompanying kitchen utensils."

## 📃 License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE.md) file for details.

## 👨‍💻 Author

Developed as part of a bachelor qualification project by
**Sasha Jaroshevskii** – [github.com/jaroshevskii](https://github.com/jaroshevskii)
