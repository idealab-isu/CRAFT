$fn=64;

module extrusion_30x30(length=100, size=30) {
    translate([0,0,-length/2])
        cube([size, size, length], center=false);
}

extrusion_30x30(100, 30);