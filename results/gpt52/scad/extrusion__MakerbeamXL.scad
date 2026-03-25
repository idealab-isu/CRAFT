$fn=64;

module extrusion_15x15(length=100, size=15) {
    translate([0,0,-length/2])
        cube([size,size,length], center=false);
}

extrusion_15x15(100,15);