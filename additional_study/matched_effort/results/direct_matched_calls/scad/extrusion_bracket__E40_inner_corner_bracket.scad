$fn = 64;

size = [38, 31, 8.5];   // overall bounding box (X,Y,Z)
wall = 3;               // leg thickness
hole_d = 5.2;           // clearance for M5
csk_d = 9.5;            // counterbore diameter
csk_h = 3.0;            // counterbore depth
fillet_r = 2.0;         // inner corner relief

module extrusion_bracket(sz=[38,31,8.5], t=3, hd=5.2, cbd=9.5, cbh=3.0, r=2.0) {
    x = sz[0]; y = sz[1]; z = sz[2];

    difference() {
        // L-bracket body
        union() {
            // base leg (along X)
            cube([x, t, z], center=false);
            // side leg (along Y)
            cube([t, y, z], center=false);
        }

        // inner corner relief (quarter-cylinder cut)
        translate([t, t, 0])
            cylinder(h=z+0.2, r=r, center=false);

        // Hole in base leg (through Z), centered in base leg area
        translate([x/2, t/2, -0.1]) {
            cylinder(h=z+0.2, d=hd, center=false);
            // counterbore from top
            translate([0,0,z-cbh])
                cylinder(h=cbh+0.2, d=cbd, center=false);
        }

        // Hole in side leg (through Z), centered in side leg area
        translate([t/2, y/2, -0.1]) {
            cylinder(h=z+0.2, d=hd, center=false);
            // counterbore from top
            translate([0,0,z-cbh])
                cylinder(h=cbh+0.2, d=cbd, center=false);
        }
    }
}

extrusion_bracket(size, wall, hole_d, csk_d, csk_h, fillet_r);