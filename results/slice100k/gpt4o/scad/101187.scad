module obround_slot(length, width, height, slot_length, slot_width, slot_offset_x, slot_offset_y) {
    difference() {
        cube([length, width, height], center = true);
        translate([slot_offset_x, slot_offset_y, 0])
            rotate([0, 90, 0])
            cylinder(h = height + 1, r = slot_width / 2, $fn = 64);
        translate([slot_offset_x - slot_length / 2, slot_offset_y, 0])
            cube([slot_length, slot_width, height + 1], center = true);
    }
}

translate([0, 0, -0.4])
    obround_slot(114.0, 59.5, 0.8, 20.0, 10.0, 47.0, 24.75);