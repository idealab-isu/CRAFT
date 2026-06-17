$fn=64;

module extrusion_10x10(length=100, size=10) {
    translate([0,0,-length/2])
        cube([size, size, length], center=true);
}

extrusion_10x10(100, 10);