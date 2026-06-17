$fn = 64;

// Simple 10x10mm aluminium extrusion (square bar), 100mm long.
// Length along Z, centered at origin.
module aluminium_extrusion_1010(len=100, size=10) {
    cube([size, size, len], center=true);
}

aluminium_extrusion_1010(len=100, size=10);