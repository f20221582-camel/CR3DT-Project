# Camera-Radar 3D Tracking (CR3DT) Net

## Overview
CR3DTNet is a deep learning architecture for 3D Object Detection designed to effectively fuse multimodal sensor data, specifically images (Camera) and Radar point clouds. By leveraging intermediate and late fusion techniques, the model provides robust perception capabilities in Bird's Eye View (BEV).

## Architecture Details
The model architecture extends the `CenterPoint` detector and integrates custom modules for sensor fusion:
- **Image & BEV Encoders**: Extracts image features and transforms them into BEV space utilizing a view transformer.
- **Radar Adapter**: A custom `1x1` convolution-based network that processes raw radar features to reduce noise and extract higher-quality representations before fusion.
- **Sensor Fusion**:
  - *Intermediate Fusion*: Implements stacking of camera, LiDAR (optional), and cleaned radar features.
  - *Late Fusion*: Includes a residual connection fusing radar features after the BEV encoder.
- **BEV Compressor**: Condenses the concatenated multimodal BEV features into a unified representation using convolutional layers and Instance Normalization.

## Frameworks & Dependencies
- **PyTorch**: Core deep learning framework.
- **MMDetection3D / MMCV**: Built on top of the OpenMMLab ecosystem for 3D object detection.

## Implementation Highlights
- `sourcecode.py`: Contains the `CR3DTNet` model definition, including the `radar_adapter`, multi-sensor feature extraction logic (`extract_feat`), and the forward pass for training/testing.
- Integrates gracefully with complex data loaders passing intrinsics, extrinsics, and ego-to-global transformations to align multi-view inputs.
