# Gridfinity Block

## What is it?
A solid block with optional stacking lip to create custom Gridfinity bins by starting with the block and then subtracting shapes from it. Carving it out, so to speak. And there are magnet holes too!

<p align="center">
<img src="https://github.com/user-attachments/assets/aae9cd4e-d49b-428c-865d-8bc6d732be17" alt="gridfinity-block visual" height="200">
</p>

## Quickstart
Create a block that's 3 units wide, 2 units deep and 6U high with the [0,0,0] point being the origin of the top surface inside the bin walls:
```openscad
use <openscad-gridfinity-block/gridfinity_block.scad>

gridfinity_block([ 3, 2, 6 ]);
```

## Examples and documentation
Please see the [Project wiki](https://github.com/wromijn/openscad-gridfinity-block/wiki)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
