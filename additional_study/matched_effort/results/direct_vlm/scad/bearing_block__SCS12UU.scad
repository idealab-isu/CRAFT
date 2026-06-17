$fn=96;

// Linear bearing block for 8.0mm shaft
// Block size: 42.0mm x 36.0mm (X x Y)

shaft_d = 8.0;
block_x = 42.0;
block_y = 36.0;
block_z = 18.0;

bore_clearance = 0.35;          // clearance on diameter
bore_d = shaft_d + bore_clearance;

split_slot_w = 2.0;             // clamp split width

mount_hole_d = 5.2;             // M5 clearance
mount_countersink_d = 9.5;      // shallow counterbore
mount_countersink_h = 2.5;

clamp_screw_d = 5.2;            // M5 clearance
clamp_nut_flat = 8.2;           // M5 nut across flats (slightly loose)
clamp_nut_thick = 4.2;

edge_fillet_r = 2.0;

module rounded_block(x,y,z,r){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(r=r, h=z);
        }
    }
}

module hex_prism(af, h){
    // Regular hex with across-flats = af; circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(r=R, h=h, $fn=6);
}

difference(){
    // Body (exact plan size: block_x x block_y)
    rounded_block(block_x, block_y, block_z, edge_fillet_r);

    // Shaft bore along X axis, centered in Y and Z
    translate([0, 0, block_z/2])
        rotate([0,90,0])
            cylinder(d=bore_d, h=block_x + 2, center=true);

    // Split clamp slot: from top face down past bore center, centered on Y=0 plane
    // Use non-centered cube so it starts at top surface (z=block_z) and cuts downward.
    slot_top_z = block_z;
    slot_bottom_z = block_z/2 - 0.5;                 // slightly below bore center for full split
    slot_h = slot_top_z - slot_bottom_z;
    translate([0, 0, slot_bottom_z])
        cube([block_x + 2, split_slot_w, slot_h + 0.2], center=false);

    // Clamp screw holes (two), along Y axis, near top, crossing the split
    clamp_z = block_z*0.72;
    clamp_x_off = block_x*0.22;
    for (sx=[-1,1]){
        translate([sx*clamp_x_off, 0, clamp_z])
            rotate([90,0,0])
                cylinder(d=clamp_screw_d, h=block_y + 2, center=true);

        // Nut trap on negative Y side, connected to the screw hole
        nut_y_center = -block_y/2 + (clamp_nut_thick/2) + 0.6;
        translate([sx*clamp_x_off, nut_y_center, clamp_z])
            rotate([90,0,0])
                hex_prism(clamp_nut_flat, clamp_nut_thick + 0.8);
    }

    // Mounting holes (4) from bottom up with shallow counterbore
    mount_x_off = block_x*0.32;
    mount_y_off = block_y*0.30;
    for (sx=[-1,1], sy=[-1,1]){
        // Through hole
        translate([sx*mount_x_off, sy*mount_y_off, -1])
            cylinder(d=mount_hole_d, h=block_z + 2);

        // Counterbore from bottom
        translate([sx*mount_x_off, sy*mount_y_off, 0])
            cylinder(d=mount_countersink_d, h=mount_countersink_h);
    }

    // Side relief pockets (kept shallow; do not break outer silhouette)
    pocket_d = 18;
    pocket_depth = 3.0;
    for (sy=[-1,1]){
        translate([0, sy*(block_y/2 - pocket_depth/2), block_z/2])
            rotate([90,0,0])
                cylinder(d=pocket_d, h=pocket_depth + 0.2, center=true);
    }
}