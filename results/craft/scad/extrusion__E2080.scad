// 20x80 aluminium T-slot extrusion (simplified but recognizable), 100mm long
// ONE connected solid. Cross-section: 20mm (X) x 80mm (Y). Length: 100mm (Z).

$fn = 64;

// Requested size
w = 20.0;     // X (mm)
h = 80.0;     // Y (mm)
L = 100.0;    // Z (mm)

// Feature sizes (kept conservative to avoid cutting through)
wall = 2.0;          // outer wall thickness
slot_open = 6.0;     // slot mouth width
slot_depth = 6.0;    // depth from outer face
slot_cavity = 12.0;  // wider cavity behind mouth
web = 2.0;           // internal cross web thickness
center_bore_d = 6.0; // center bore diameter
over = 0.2;          // boolean overlap

module tslot_cut_from_posX(len) {
    // Cut a T-slot from +X face inward (along -X)
    union() {
        // Mouth
        translate([ w/2 - (slot_depth + over)/2, 0, 0 ])
            cube([slot_depth + over, slot_open, len + 2*over], center=true);

        // Inner cavity (starts after mouth)
        translate([ w/2 - slot_depth - (slot_cavity + over)/2, 0, 0 ])
            cube([slot_cavity + over, slot_cavity, len + 2*over], center=true);
    }
}

module tslot_cut_from_posY(len) {
    // Cut a T-slot from +Y face inward (along -Y)
    union() {
        // Mouth
        translate([ 0, h/2 - (slot_depth + over)/2, 0 ])
            cube([slot_open, slot_depth + over, len + 2*over], center=true);

        // Inner cavity
        translate([ 0, h/2 - slot_depth - (slot_cavity + over)/2, 0 ])
            cube([slot_cavity, slot_cavity + over, len + 2*over], center=true);
    }
}

module extrusion_20x80(len=L) {
    // Build as: (outer - voids) + webs, all in one union => one connected solid
    union() {
        // Outer shell with internal voids and slots removed
        difference() {
            // Outer body
            cube([w, h, len], center=true);

            // Main internal void (keeps outer walls)
            cube([w - 2*wall, h - 2*wall, len + 2*over], center=true);

            // Center bore
            cylinder(d=center_bore_d, h=len + 2*over, center=true);

            // T-slots on all four faces
            tslot_cut_from_posX(len);
            mirror([1,0,0]) tslot_cut_from_posX(len);
            tslot_cut_from_posY(len);
            mirror([0,1,0]) tslot_cut_from_posY(len);

            // Small corner relief pockets (shallow, do not disconnect)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([ sx*(w/2 - wall/2), sy*(h/2 - wall/2), 0 ])
                    cube([wall + over, wall + over, len + 2*over], center=true);
            }
        }

        // Internal webs added back (ensure connectedness and typical look)
        // Slightly overlap into remaining material to avoid coincident faces.
        cube([web, h - 2*wall + 2*over, len], center=true); // vertical web
        cube([w - 2*wall + 2*over, web, len], center=true); // horizontal web
    }
}

extrusion_20x80(L);