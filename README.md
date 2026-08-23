# Camera-RADAR 3D Detection and Tracking (CR3DT)

## Abstract & Overview
This repository contains the full codebase, architectural implementation, and findings for an enhanced **Camera-RADAR 3D Detection and Tracking (CR3DT)** framework. 

While LiDAR-based systems currently set the benchmark for 3D perception accuracy in autonomous driving, they remain prohibitively expensive for mass adoption. The CR3DT model offers a cost-effective alternative by fusing semantically rich camera data with velocity-aware, robust automotive RADAR data.

Our work consists of two phases:
1. **Baseline Reproduction**: Successfully reproduced the official CR3DT baseline on the **nuScenes dataset (300GB)**, achieving an mAP of 35.1% and a NuScenes Detection Score (NDS) of 45.6% at ~11 FPS.
2. **Novel Enhancements**: Identified that the baseline's "naive concatenation" of Camera and RADAR features is suboptimal due to the "Semantic Gap" and sensor noise. We designed and implemented two novel architectural interventions: **Gated Fusion** and a **Learnable Radar Adapter**.

## Architectural Enhancements

### 1. Learnable Radar Adapter
Directly fusing raw radar point cloud features with highly abstract ResNet camera features wastes network capacity. To solve this, we introduced a lightweight sequential block (1x1 Conv -> BatchNorm -> ReLU) to process and normalize the sparse RADAR data *before* it touches the camera features. 

* **Impact**: Filters noise and aligns the radar features to a compatible latent space, making the downstream fusion significantly more effective.
* **Code Reference**: See `radar_adapter` in `cr3dt_model.py`.

### 2. Gated Fusion Mechanism
Simple concatenation treats both sensors as equally valid at all times. In real-world scenarios, radar is often noisy (ghost objects), and cameras can be obstructed (glare/darkness). 
We implemented a dynamic "Gate Layer" (a Squeeze-and-Excitation style approach) that calculates attention weights to dynamically suppress a sensor if its data is inconsistent.

* **Impact**: Allows the model to intelligently weigh the importance of Camera vs. RADAR features based on the environmental context.

## Model Pipeline (Bird's-Eye-View)
1. **Camera Stream (LSS)**: 6 surround-view images are processed via ResNet-50. Depth distributions are predicted, lifting the 2D images into a 3D frustum, which is splatted onto a BEV grid.
2. **Radar Stream (Pillarization)**: Radar sweeps are voxelized and encoded into pillar feature vectors.
3. **Fusion**: The Radar Adapter cleans the radar features, which are then fused with the Camera BEV features. A BEV Compressor unifies the representation before passing it to the detection head.

## Challenges Overcome
Deploying this complex stack on a 24GB RTX 4090 presented significant challenges:
* **VRAM Bottlenecks**: Overcame Out-of-Memory (OOM) errors by implementing Automatic Mixed Precision (AMP) training.
* **RAM Instability**: Fixed "Process Killed" errors by optimizing data loader workers and implementing aggressive pre-fetching limits for the uncompressed 300GB nuScenes dataset.

## Repository Contents
* `CR3DT/`: The full autonomous driving training framework (forked from MMDetection3D), containing all core modules, evaluation scripts, and data loaders. Note: Large 300GB datasets and checkpoints have been ignored from git to keep the repository lightweight.
* `cr3dt_model.py`: The core PyTorch implementation of our enhanced CR3DTNet architecture, showcasing the custom fusion mechanisms directly.
* `cr3dt-r50.py`: The central configuration script detailing the hyperparameters, model architecture settings, data pipelines, and evaluation metrics for the ResNet-50 backbone.
* `CR3DT_Project_Report.pdf`: The full academic report detailing mathematical intuitions, training configurations, and in-depth analysis.

---
*Developed for Internet of Things (EEE F411).*
