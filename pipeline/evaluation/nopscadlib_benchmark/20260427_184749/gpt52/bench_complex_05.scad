$fn=64;

// Parameters
t8_major_d = 8.0;
clearance_d = 8.6;

block_l = 50;
block_w = 40;
block_h = 22;

rail_hole_spacing = 20;   // typical MGN12 carriage spacing (approx)
rail_hole_edge_y = 10;    // distance from side edge to hole line
rail_hole_d = 3.4;        // M3 clearance
rail_counterbore_d = 6.2;
rail_counterbore_h = 3.0;

nut_pocket_d = 22.2;      // pocket for T8 anti-backlash nut OD (approx)
nut_pocket_h = 12.5;

spring_pocket_d = 16.0;
spring_pocket_h = 8.0;

clamp_slot_w = 2.2;
clamp_slot_l = 30;
clamp_slot_h = block_h + 1;

clamp_bolt_d = 3.4;       // M3 clearance
clamp_bolt_head_d = 6.2;
clamp_bolt_head_h = 3.0;
clamp_bolt_offset_z = 6.5;
clamp_bolt_offset_x = 16;

mount_hole_d = 4.4;       // M4 clearance (optional side mounting)
mount_hole_spacing_z = 12;
mount_hole_offset_x = 0;
mount_hole_offset_y = 0;

module nut_block_body() {
    // Main body with slight corner relief via intersection with cylinder (soften edges)
    intersection() {
        cube([block_l, block_w, block_h], center=true);
        // Rounded envelope
        scale([1,1,1])
            cylinder(d=max(block_l, block_w)*1.05, h=block_h*1.2, center=true);
    }
}

module rail_mount_holes() {
    // Four holes on bottom face for linear rail carriage
    // Pattern: two along X, two along Y (rectangular)
    // Place near bottom, through all
    for (sx = [-1, 1])
    for (sy = [-1, 1]) {
        translate([sx*rail_hole_spacing/2, sy*(block_w/2 - rail_hole_edge_y), 0])
            cylinder(d=rail_hole_d, h=block_h+2, center=true);
        // Counterbore from bottom
        translate([sx*rail_hole_spacing/2, sy*(block_w/2 - rail_hole_edge_y), -block_h/2 + rail_counterbore_h/2])
            cylinder(d=rail_counterbore_d, h=rail_counterbore_h+0.2, center=true);
    }
}

module leadscrew_and_nut_pockets() {
    // Through hole for leadscrew
    cylinder(d=clearance_d, h=block_h+2, center=true);

    // Main nut pocket from top
    translate([0,0, block_h/2 - nut_pocket_h/2])
        cylinder(d=nut_pocket_d, h=nut_pocket_h+0.2, center=true);

    // Spring pocket above nut pocket (for anti-backlash spring space)
    translate([0,0, block_h/2 - (nut_pocket_h + spring_pocket_h/2)])
        cylinder(d=spring_pocket_d, h=spring_pocket_h+0.2, center=true);
}

module clamp_features() {
    // Clamp slot to allow tightening around nut pocket area
    translate([0, 0, 0])
        cube([clamp_slot_l, clamp_slot_w, clamp_slot_h], center=true);

    // Two clamp bolts across Y (left-right) to pinch slot
    for (sx = [-1, 1]) {
        translate([sx*clamp_bolt_offset_x/2, 0, -block_h/2 + clamp_bolt_offset_z])
            rotate([90,0,0])
                cylinder(d=clamp_bolt_d, h=block_w+2, center=true);

        // Counterbore for bolt head on +Y side
        translate([sx*clamp_bolt_offset_x/2, block_w/2 - clamp_bolt_head_h/2, -block_h/2 + clamp_bolt_offset_z])
            rotate([90,0,0])
                cylinder(d=clamp_bolt_head_d, h=clamp_bolt_head_h+0.2, center=true);
    }
}

module side_mount_holes() {
    // Optional side mounting holes through X direction (two holes along Z)
    for (sz = [-1, 1]) {
        translate([0, 0, sz*mount_hole_spacing_z/2])
            rotate([0,90,0])
                cylinder(d=mount_hole_d, h=block_l+2, center=true);
    }
}

difference() {
    union() {
        nut_block_body();

        // Add a small top boss around nut pocket for strength
        translate([0,0, block_h/2 - 6])
            cylinder(d=nut_pocket_d+8, h=8, center=true);
    }

    // Internal features
    leadscrew_and_nut_pockets();

    // Rail mount holes
    rail_mount_holes();

    // Clamp slot and bolts
    clamp_features();

    // Side mount holes (can be removed by commenting out)
    side_mount_holes();

    // Small relief chamfer-like cuts on bottom edges using cylinders
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*(block_l/2-2), sy*(block_w/2-2), -block_h/2])
            rotate([0,0,45])
                cylinder(d=6, h=6, center=true);
    }
}