$fn = 96;

// Parameters
shaft_d = 8.0;
block_w = 40.0;   // X
block_l = 68.0;   // Y
block_h = 24.0;   // Z

// Bearing/bore
bore_clearance = 0.35;          // diameter clearance
bore_d = shaft_d + bore_clearance;
bore_z = block_h/2;             // center height

// Split clamp slot
slot_w = 2.0;                   // slot thickness
slot_x = 0;                     // centered

// Clamp screw holes (across the split, along X)
clamp_hole_d = 4.3;             // for M4 clearance
clamp_head_d = 8.2;             // counterbore for socket head
clamp_head_depth = 4.0;
clamp_nut_flat = 7.2;           // hex nut trap (M4)
clamp_nut_depth = 3.6;

clamp_y_offset = 18.0;          // from center along Y
clamp_z = block_h*0.78;         // near top

// Mounting holes (to attach block to a plate), vertical through Z
mount_hole_d = 5.3;             // for M5 clearance
mount_cbore_d = 10.0;
mount_cbore_depth = 4.0;
mount_x_offset = 14.0;
mount_y_offset = 24.0;

// Edge fillets (approximated by minkowski with small sphere)
fillet_r = 1.2;

// Helpers
module rounded_block(size=[40,68,24], r=1.2){
    // Minkowski rounding; keep renderable and not too heavy
    minkowski(){
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module hex_prism(flat=7.2, h=3.6){
    // Regular hex with given across-flats
    r = flat / (2*cos(30));
    cylinder(h=h, r=r, $fn=6, center=false);
}

module clamp_hole(ypos){
    // Through hole along X, with counterbore on +X side and nut trap on -X side
    translate([0, ypos, clamp_z]){
        // through
        rotate([0,90,0])
            cylinder(h=block_w+2, d=clamp_hole_d, center=true);

        // counterbore on +X
        translate([block_w/2 - clamp_head_depth, 0, 0])
            rotate([0,90,0])
                cylinder(h=clamp_head_depth+0.2, d=clamp_head_d, center=false);

        // nut trap on -X
        translate([-block_w/2, 0, 0])
            rotate([0,90,0])
                hex_prism(flat=clamp_nut_flat, h=clamp_nut_depth+0.2);
    }
}

module mount_hole(xpos, ypos){
    translate([xpos, ypos, 0]){
        // through Z
        cylinder(h=block_h+2, d=mount_hole_d, center=true);
        // counterbore on top
        translate([0,0, block_h/2 - mount_cbore_depth])
            cylinder(h=mount_cbore_depth+0.2, d=mount_cbore_d, center=false);
    }
}

difference(){
    // Body
    rounded_block([block_w, block_l, block_h], fillet_r);

    // Shaft bore along Y
    translate([0,0,bore_z - block_h/2])
        rotate([90,0,0])
            cylinder(h=block_l+2, d=bore_d, center=true);

    // Split slot from top down to bore
    slot_depth = block_h - (bore_z - block_h/2) - (bore_d/2) + 0.6;
    translate([slot_x - slot_w/2, -block_l/2-1, block_h/2 - slot_depth])
        cube([slot_w, block_l+2, slot_depth+2], center=false);

    // Clamp holes (two)
    clamp_hole(+clamp_y_offset);
    clamp_hole(-clamp_y_offset);

    // Mounting holes (4)
    mount_hole(+mount_x_offset, +mount_y_offset);
    mount_hole(-mount_x_offset, +mount_y_offset);
    mount_hole(+mount_x_offset, -mount_y_offset);
    mount_hole(-mount_x_offset, -mount_y_offset);

    // Lightening pockets on sides (optional, subtle)
    pocket_w = 10.0;
    pocket_h = 10.0;
    pocket_l = 44.0;
    for (sx=[-1,1]){
        translate([sx*(block_w/2 - pocket_w/2 - 2.0), 0, -block_h/2 + pocket_h/2 + 2.0])
            cube([pocket_w, pocket_l, pocket_h], center=true);
    }
}