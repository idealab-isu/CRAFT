$fn = 96;

module component() {
    // Base plate
    plate_x = 40;
    plate_y = 24;
    plate_z = 10;

    // Raised boss on top face
    boss_r = 9;
    boss_h = 6;

    // Through hole in boss/plate
    hole_r = 3.2;

    // Corner mounting holes
    mount_r = 2.2;
    edge_margin_x = 6;
    edge_margin_y = 5;

    // Side tab (connected)
    tab_x = 14;
    tab_y = 12;
    tab_z = 6;

    // Small overlap to guarantee manifold union
    overlap = 0.6;

    difference() {
        union() {
            // Main body
            cube([plate_x, plate_y, plate_z], center=true);

            // Boss connected to top face of plate
            translate([0, 0, plate_z/2 + boss_h/2 - overlap])
                cylinder(h=boss_h, r=boss_r, center=true);

            // Side tab connected to right side of plate
            translate([plate_x/2 + tab_x/2 - overlap, 0, -plate_z/2 + tab_z/2])
                cube([tab_x, tab_y, tab_z], center=true);
        }

        // Central through hole (goes through boss + plate)
        cylinder(h=plate_z + boss_h + 2, r=hole_r, center=true);

        // Four mounting holes through plate
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(plate_x/2 - edge_margin_x), sy*(plate_y/2 - edge_margin_y), 0])
                cylinder(h=plate_z + 2, r=mount_r, center=true);

        // Slot in side tab (through tab thickness)
        translate([plate_x/2 + tab_x/2 - overlap, 0, -plate_z/2 + tab_z/2])
            rotate([0, 90, 0])
                cylinder(h=tab_x + 2, r=1.8, center=true);
    }
}

component();