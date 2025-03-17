# Gridfinity Block

## What is it?
A solid block with optional stacking lip to create custom Gridfinity bins by starting with the block and then subtracting shapes from it. Carving it out, so to speak. And there are magnet holes too!

<p align="center">
<img src="https://github.com/user-attachments/assets/aae9cd4e-d49b-428c-865d-8bc6d732be17" alt="gridfinity-block visual" height="200">
</p>

## Quickstart
Useless block that demonstrates the library. It creates a block that's 1 unit wide, 2 units deep and 6U high, with the [0,0,0] point being the bottom-left of the top surface inside the bin walls. Then it adds a square hole with a cube inside it and 2 round holes.

```openscad
use <openscad-gridfinity-block/gridfinity_block.scad>;

$fn=128;

gridfinity_block([ 1, 2, 6 ], stacking_lip = true) {
    gb_square_hole( [ 0, 0 ], [ $inner_width, 20 ], depth = 20) {
        cube( [ $inner_width, $inner_length / 2, $inner_height / 2 ]);
    };
    gb_round_hole( [ 10, $inner_length / 2 ], 15, depth = $inner_height);
    gb_round_hole( [ 29, $inner_length / 2 ], 15, depth = 10);
};
```

## Examples and documentation
Please see the [Project wiki](https://github.com/wromijn/openscad-gridfinity-block/wiki)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
