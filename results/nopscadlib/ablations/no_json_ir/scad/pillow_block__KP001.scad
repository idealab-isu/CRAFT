$fn = 96;

// Parameters (mm)
shaft_diameter = 12.0;

base_length = 71.0;
base_width  = 56.0;
base_thickness = 10.0;

mounting_hole_diameter = 6.0;
mounting_hole_offset_x = 20.0;
mounting_hole_offset_y = 15.0;

housing_outer_d = 44.0;     // outer "bearing boss" diameter
housing_len_y   = 34.0;     // length of boss along Y (across base width)
pedestal_h      = 18.0;     // height of pedestal above base
cap_h           = 8.0;      // top cap thickness

bearing_seat_d     = 30.0;  // counterbore/seat diameter
bearing_seat_depth = 8.0;   // counterbore depth from each side

// Small overlap to ensure watertight unions
ov = 0.6;

module pillow_block_bearing_unit() {
    difference() {
        // ONE connected solid
        union() {
            base_block();
            pedestal_and_boss();
            top_cap();
        }

        // Subtractions
        mounting_holes_cut();
        shaft_bore_cut();
        bearing_seat_cut();
    }
}

module base_block() {
    // Base footprint is clearly 71 x 56
    translate([-base_length/2, -base_width/2, 0])
        cube([base_length, base_width, base_thickness], center=false);
}

module pedestal_and_boss() {
    // Pedestal: a block that supports the cylindrical boss, connected to base
    pedestal_len = base_length * 0.62; // proportioned, but derived from base_length
    pedestal_w   = base_width  * 0.78; // proportioned, but derived from base_width

    translate([-pedestal_len/2, -pedestal_w/2, base_thickness - ov])
        cube([pedestal_len, pedestal_w, pedestal_h + ov], center=false);

    // Cylindrical boss (bearing housing) sitting on pedestal
    boss_zc = base_thickness + pedestal_h + housing_outer_d/2 - ov;

    translate([0, 0, boss_zc])
        rotate([90, 0, 0])
            cylinder(h=housing_len_y, d=housing_outer_d, center=true);
}

module top_cap() {
    // A simple cap block on top of the boss to resemble pillow block housing form
    cap_len = base_length * 0.52;
    cap_w   = housing_len_y;
    cap_z0  = base_thickness + pedestal_h + housing_outer_d - ov;

    translate([-cap_len/2, -cap_w/2, cap_z0])
        cube([cap_len, cap_w, cap_h], center=false);
}

module mounting_holes_cut() {
    // Through holes in base (visible from top/bottom)
    for (x = [-mounting_hole_offset_x, mounting_hole_offset_x])
        for (y = [-mounting_hole_offset_y, mounting_hole_offset_y])
            translate([x, y, -ov])
                cylinder(h=base_thickness + 2*ov, d=mounting_hole_diameter, center=false);
}

module shaft_bore_cut() {
    // Shaft bore through the boss along Y axis
    boss_zc = base_thickness + pedestal_h + housing_outer_d/2 - ov;

    translate([0, 0, boss_zc])
        rotate([90, 0, 0])
            cylinder(h=housing_len_y + 2*ov, d=shaft_diameter, center=true);
}

module bearing_seat_cut() {
    // Counterbore/seat from both sides (typical insert bearing seat look)
    boss_zc = base_thickness + pedestal_h + housing_outer_d/2 - ov;

    // Left side seat
    translate([0, -(housing_len_y/2 - bearing_seat_depth/2), boss_zc])
        rotate([90, 0, 0])
            cylinder(h=bearing_seat_depth + 2*ov, d=bearing_seat_d, center=true);

    // Right side seat
    translate([0,  (housing_len_y/2 - bearing_seat_depth/2), boss_zc])
        rotate([90, 0, 0])
            cylinder(h=bearing_seat_depth + 2*ov, d=bearing_seat_d, center=true);
}

// Render
pillow_block_bearing_unit();