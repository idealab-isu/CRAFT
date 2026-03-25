// PCB parameters (mm)
length    = 24.8;   // X
width     = 14.6;   // Y
thickness = 1.0;    // Z

$fn = 64;

// Single connected solid: PCB slab, centered at origin for reliable visibility
module PCB(l=length, w=width, t=thickness) {
    color([0.0, 0.4, 0.2])
        cube([l, w, t], center=true);
}

PCB();