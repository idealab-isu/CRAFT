// T8 Leadscrew Anti-Backlash Nut Block
// T8: 8mm leadscrew, 22mm flange, MGN12 rail mount
leadscrew_d = 8;
nut_flange_d = 22;
nut_h = 15;
block_width = 40;
block_height = 12;
rail_hole_spacing = 20;  // MGN12

difference() {
    // Main block
    cube([block_width, 30, block_height], center=true);

    // Leadscrew nut pocket
    cylinder(d=nut_flange_d + 0.5, h=block_height + 1, center=true, $fn=64);

    // Leadscrew clearance
    cylinder(d=leadscrew_d + 2, h=block_height + 10, center=true, $fn=64);

    // Nut mounting holes (usually 4 on flange)
    for (i = [0:3]) {
        rotate([0, 0, i * 90 + 45])
            translate([nut_flange_d/2 - 2, 0, 0])
                cylinder(d=3.2, h=block_height + 1, center=true, $fn=32);
    }

    // MGN12 rail mounting holes
    for (x = [-1, 1]) {
        translate([x * rail_hole_spacing/2, 10, 0])
            cylinder(d=3.2, h=block_height + 1, center=true, $fn=32);
    }

    // Anti-rotation slot
    translate([0, -12, 0])
        cube([6, 8, block_height + 1], center=true);

    // Weight reduction
    for (x = [-1, 1]) {
        translate([x * 14, -5, 0])
            cylinder(d=8, h=block_height + 1, center=true, $fn=32);
    }
}
