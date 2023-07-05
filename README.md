<div align="center">
<img src=Icon\ARBUR_Icon.png width=20%/>
</div>
# ARBUR: A machine learning-based Analysis system for Relating the Behavior and USVs of Rats 
<div align="center">

<img src=Icon\ARBUR_v1.gif width=100% />

</div>
## Table of Contents
- [ARBUR: A machine learning-based Analysis system for Relating the Behavior and USVs of Rats](#arbur-a-machine-learning-based-analysis-system-for-relating-the-behavior-and-usvs-of-rats)
  - [Table of Contents](#table-of-contents)
  - [What is ARBUR？](#what-is-arbur)
  - [Running demos](#running-demos)
  - [Using ARBUR for your data](#using-arbur-for-your-data)
  - [Dependencies](#dependencies)
  - [Installation](#installation)
  - [Citation](#citation)

## What is ARBUR？
ARBUR is implemented in Matlab (The MathWorks Inc.) for analysing the behaviour and USVs of rats. It can unbiasedly cluster both non-step (continuous) and step USVs into 65 subgroups, hierarchically detect 8 types of behavior of two freely behaving rats, and locate the vocal rat in 3-D space. 

In addition to providing an easy to use app, each component can be run separately (ARBUR: USV, ARBUR: Behavior, ARBUR: SSL).


## Running demos
1) We provide a mini-dataset including stereo images (**.\DemoData\Image**), 4-channel USVs (**\DemoData\USV\USV_seq**) and the 3D coordinates of rats (**.\DemoData\3D_position\world3d.csv**)). In addition, we provided a representative dataset consisting of 4500 1-channel USVs for clustering alone (**\DemoData\USV\demo_ARBUR_USV_data.mat**).
2) From the main folder of the repository run **.\ARBUR.m** to perform USVs clustering, behaviour detection and sound source localization. <br/>
-- Each module can be run separately (**.\ARBUR_USV.m**,  **.\ARBUR_Behavior.m**, **.\ARBUR_SSL.m**).
-- All functions, models, and dependent libraries are available in the **.\Codes**
3) Run the **.\ARBUR_v1.mlapp** to see the analysis results. All the results here are obtained from **\DemoData\Results**.<br/> 
-- **\DemoData\Results\demo_USV_label.mat** is the USVs cluster result. 
-- **\DemoData\Results\demo_behavior_label.mat** is the behaviour detection result. 
-- **\DemoData\Results\demo_SSL_label.mat** is the sound source localization result. 

## Dependencies 
In-built functions of Matlab, Computer Vision Toolbox, Statistics and Machine Learning Toolbox. Code has been tested on Matlab 2021b across Windows operating systems. <br/>


## Installation
To install this toolbox, add all contents of this repository to Matlab path. 

## Citation
Tachibana R O, Kanno K, Okabe S, et al. USVSEG: A robust method for segmentation of ultrasonic vocalizations in rodents[J]. PloS one, 2020, 15(2): e0228907. <br/>
Matsumoto J, Kanno K, Kato M, et al. Acoustic camera system for measuring ultrasound communication in mice[J]. Iscience, 2022, 25(8): 104812. <br/>
Sangiamo, D. T., Warren, M. R. & Neunuebel, J. P. Ultrasonic signals associated with differ ent types of social behavior of mice. Nature neuroscience 23, 411-422 (2020). <br/>
Fonseca, A. H., Santana, G. M., Bosque Ortiz, G. M., Bampi, S. & Dietrich, M. O. Analysis of ultrasonic vocalizations from mice using com puter vision and machine learning. Elife 10,1193 e59161 (2021). <br/>

