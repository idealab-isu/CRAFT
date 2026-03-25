// Parameters (mm)
plate_L = 114.0;
plate_W = 59.5;
plate_T = 0.8;

slot_L = 30;
slot_W = 10;
slot_end_r = slot_W/2;          // ensure true obround ends
slot_center_x_from_left = 15;
slot_center_y_from_bottom = 12;

$fn = 64;

// Base plate (non-centered for unambiguous "from left/bottom" placement)
module plate_body() {
    cube([plate_L, plate_W, plate_T], center=false);
}

// Obround slot (through-cut along Z)
module obround_slot_3d() {
    // Build in XY, then extrude in Z
    linear_extrude(height = plate_T + 2, center = true)
        hull() {
            translate([-(slot_L/2 - slot_end_r), 0]) circle(r = slot_end_r);
            translate([ +(slot_L/2 - slot_end_r), 0]) circle(r = slot_end_r);
        }
}

module plate_with_slot() {
    difference() {
        plate_body();

        // Place slot by its center measured from left/bottom edges of the plate
        translate([slot_center_x_from_left, slot_center_y_from_bottom, plate_T/2])
            obround_slot_3d();
    }
}

// Final
plate_with_slot();