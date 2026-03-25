$fn=96;

module heatshrink_sleeve(length=50, id=6, wall=0.6) {
    od = id + 2*wall;
    difference() {
        cylinder(h=length, d=od, center=true);
        cylinder(h=length+0.2, d=id, center=true);
    }
}

module heatshrink_sleeve_textured(length=50, id=6, wall=0.6, ribs=36, rib_depth=0.15) {
    od = id + 2*wall;
    difference() {
        union() {
            difference() {
                cylinder(h=length, d=od, center=true);
                cylinder(h=length+0.2, d=id, center=true);
            }
        }
        for (i = [0:ribs-1]) {
            rotate([0,0, i*360/ribs])
                translate([od/2 - rib_depth/2, 0, 0])
                    cube([rib_depth, 0.6, length+0.4], center=true);
        }
    }
}

heatshrink_sleeve_textured(length=60, id=8, wall=0.8, ribs=48, rib_depth=0.18);