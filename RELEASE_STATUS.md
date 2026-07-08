# Release status — bidscube_levelplay_flutter

## LevelPlay Flutter

Lightweight wrapper; wires native Bidscube LevelPlay adapters into Android/iOS builds. Load/show via Unity's official `unity_levelplay_mediation`.

## Supported formats (via native adapters)

- Banner
- Interstitial (static/image)
- Rewarded
- MREC (if LevelPlay banner/MREC flow and dashboard support it)

## Not supported

- Native LevelPlay
- Direct Bidscube ad rendering in Dart
- VAST/OpenRTB parsing in Dart

## OpenRTB 2.6

OpenRTB 2.6-style response parsing is **not implemented yet** in native Android/iOS SDKs. This Flutter package does not parse OpenRTB and does not build or POST OpenRTB bid requests.

## QA

Sibling app: `../BidscubeFlutterLevelPlayTestApp`
