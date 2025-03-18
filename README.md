# Gridfinity Block

## What is it?
A solid block with optional stacking lip to create custom Gridfinity bins by starting with the block and then subtracting shapes from it. Carving it out, so to speak. And there are magnet holes too!

<p align="center">
<img src="https://github.com/user-attachments/assets/aae9cd4e-d49b-428c-865d-8bc6d732be17" alt="gridfinity-block visual" height="200">
</p>

## Quickstart
This creates a block that's 1x1 units and 4U high, with the [0,0,0] point being the center of the top surface. The nested sphere is subtracted from the block.

```openscad
use <openscad-gridfinity-block/gridfinity_block.scad>;

$fn=128;

gridfinity_block([ 1, 1, 4 ], stacking_lip = true, center=true) {
    sphere(r=15);
};
```

## Examples and documentation
Please see the [Project wiki](https://github.com/wromijn/openscad-gridfinity-block/wiki)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
