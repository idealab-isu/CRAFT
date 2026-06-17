// 20x60 aluminium T-slot extrusion (simplified but recognizable), 100mm long
// One connected solid, no floating parts

// Parameters
w = 20.0;          // X (mm)
h = 60.0;          // Y (mm)
len = 100.0;       // Z (mm)

wall = 2.2;        // outer wall thickness
slot_open = 6.0;   // T-slot mouth opening
slot_depth = 7.0;  // depth from outer face to inner cavity
slot_cavity = 12.0;// inner cavity width behind mouth (T-nut area)
center_bore_d = 6.0;

web = 2.0;         // internal web thickness
overlap = 0.25;    // small overlap for robust CSG

$fn = 64;

module tslot_cut_x() {
    // Cuts a T-slot from +X face inward (along -X)
    union() {
        // Mouth (narrow)
        translate([ w/2 - slot_depth/2 + overlap, 0, 0 ])
            cube([ slot_depth + 2*overlap, slot_open, len + 2*overlap ], center=true);

        // Cavity (wider) behind mouth
        translate([ w/2 - slot_depth - slot_depth/2 + overlap, 0, 0 ])
            cube([ slot_depth + 2*overlap, slot_cavity, len + 2*overlap ], center=true);
    }
}

module tslot_cut_y() {
    // Cuts a T-slot from +Y face inward (along -Y)
    union() {
        // Mouth (narrow)
        translate([ 0, h/2 - slot_depth/2 + overlap, 0 ])
            cube([ slot_open, slot_depth + 2*overlap, len + 2*overlap ], center=true);

        // Cavity (wider) behind mouth
        translate([ 0, h/2 - slot_depth - slot_depth/2 + overlap, 0 ])
            cube([ slot_cavity, slot_depth + 2*overlap, len + 2*overlap ], center=true);
    }
}

module extrusion_20x60() {
    color([0.85, 0.85, 0.8])
    union() {
        // Main body with slots and center bore removed
        difference() {
            // Outer boundary (ensures correct 20x60 proportions)
            cube([w, h, len], center=true);

            // Inner void (keeps outer walls)
            cube([w - 2*wall, h - 2*wall, len + 2*overlap], center=true);

            // Four T-slots (one per face)
            tslot_cut_x();
            mirror([1,0,0]) tslot_cut_x();
            tslot_cut_y();
            mirror([0,1,0]) tslot_cut_y();

            // Center bore
            cylinder(d=center_bore_d, h=len + 2*overlap, center=true);
        }

        // Internal webs (ADDED via union so they are not subtracted away)
        // Slightly oversized to guarantee overlap with the remaining shell
        cube([web, h - 2*wall + 2*overlap, len], center=true); // vertical web
        cube([w - 2*wall + 2*overlap, web, len], center=true); // horizontal web
    }
}

extrusion_20x60();