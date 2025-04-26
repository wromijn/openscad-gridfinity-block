# Gridfinity Block

## What is it?
An OpenSCAD model to create custom storage bins for the Gridfinity system. This library defines a solid block that can be customized using built-in subtraction functions to carve out specific shapes, holes, or compartments. And there are magnet holes too!

<p align="center">
<img src="https://github.com/user-attachments/assets/aae9cd4e-d49b-428c-865d-8bc6d732be17" alt="gridfinity-block visual" height="200">
</p>

## Quickstart
This creates a block that's 1x1 units and 4U high, with the [0,0,0] point being the center of the top surface. The nested sphere is subtracted from the block.

```openscad
use <openscad-gridfinity-block/gridfinity_block.scad>

$fn=128;

gridfinity_block([ 1, 1, 4 ], stacking_lip = true, center=true) {
    sphere(r=15);
};
```

## Examples and documentation
Please see the [Project wiki](https://github.com/wromijn/openscad-gridfinity-block/wiki)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

*Note: The Gridfinity system was originally conceptualized by Zack Freedman. See [https://gridfinity.xyz/](https://gridfinity.xyz/) for more information about Gridfinity.*
