# Firefly Algorithm for Economic Dispatch

## Overview
This project implements the **Firefly Algorithm (FA)** to solve a **15-generator Economic Dispatch (ED) problem**. The goal is to **minimize generation costs** while satisfying generator capacity and power balance constraints.

## Features
- Economic dispatch optimization using nature-inspired Firefly Algorithm.
- Generator constraints including minimum and maximum power limits.
- Consideration of B-losses matrix for realistic system modeling.
- Simulation and visualization of cost convergence and optimal generator outputs.
- Easy-to-run MATLAB scripts.

## Methodology
1. Define generator cost coefficients and constraints.
2. Initialize a population of fireflies with random solutions.
3. Evaluate fitness based on generation cost.
4. Update positions of fireflies based on brightness and attractiveness.
5. Iterate until convergence or maximum iterations.
6. Output optimal power distribution and total cost.

## Tools & Technologies
- MATLAB R2023a (or compatible version)
- Scripts for initialization, algorithm, and result plotting.

## Usage
1. Open MATLAB and add project folder to path.
2. Run `Firefly_ED.m` script to execute the optimization.
3. Results will include optimal generator outputs, total cost, and convergence plots.

## Conclusion
The Firefly Algorithm successfully optimizes power generation allocation for multi-generator systems, providing **efficient, cost-effective solutions**. Future improvements may include multi-objective optimization or integration with real-time dispatch systems.
