$fn = 128;

// HT 90 straight pipe, length 250 mm (approximation)
// Common HT DN90 assumptions:
// - Outer diameter: 90 mm
// - Wall thickness: 2.7 mm
// - Straight segment length: 250 mm
// - Small chamfers on both ends

od = 90;
wall = 2.7;
id = od - 2*wall;

L = 250;          // pipe length
chamfer = 1.0;    // end chamfer length
eps = 0.05;

module straight_pipe_shell(OD, ID, len) {
    // Hollow straight pipe (open at both ends)
    difference() {
        cylinder(h=len, d=OD, center=false);
        translate([0,0,-eps]) cylinder(h=len + 2*eps, d=ID, center=false);
    }
}

module end_chamfer_cutter(OD, ID, c) {
    // Cutter that creates a chamfer on a pipe end face at z=0 (pointing +z)
    union() {
        // Outer edge chamfer
        difference() {
            cylinder(h=c+eps, d=OD + 2*c, center=false);
            translate([0,0,-eps]) cylinder(h=c+3*eps, d=OD, center=false);
        }
        // Inner edge chamfer
        difference() {
            cylinder(h=c+eps, d=ID, center=false);
            translate([0,0,-eps]) cylinder(h=c+3*eps, d=max(0.01, ID - 2*c), center=false);
        }
    }
}

module ht_90_pipe_250(OD=od, ID=id, len=L, c=chamfer) {
    // One connected solid: straight hollow pipe with chamfers on both ends
    difference() {
        straight_pipe_shell(OD, ID, len);

        // Chamfer at start (z=0)
        translate([0,0,-eps])
            end_chamfer_cutter(OD, ID, c);

        // Chamfer at end (z=len), cutter points -z
        translate([0,0,len + eps])
            mirror([0,0,1])
                end_chamfer_cutter(OD, ID, c);
    }
}

ht_90_pipe_250();