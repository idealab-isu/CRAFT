$fn=96;

// Long linear bearing block for 6.0mm shaft
// Overall block size: 34.0mm (X) x 58.0mm (Y) x 18.0mm (Z)

shaft_d = 6.0;

// Block dimensions
block_w = 34.0;   // X
block_l = 58.0;   // Y
block_h = 18.0;   // Z

// Shaft channel (linear bore along Y)
bore_clearance = 0.25;                 // diameter clearance
bore_d = shaft_d + bore_clearance;     // verifiable 6mm interface
bore_center_z = block_h/2;

// Clamp split slot (opens to top, runs full length)
slot_w = 1.6;                          // X thickness
slot_end_margin = 6.0;                // keep material at ends (Y)
slot_top_skin = 0.0;                  // open to top
slot_bottom_skin = 2.0;               // leave bottom skin

// Mounting holes (4x)
mount_hole_d = 4.2;                   // M4 clearance
mount_counterbore_d = 8.2;            // socket head counterbore
mount_counterbore_depth = 4.0;

mount_x_offset = 6.0;                 // from each side
mount_y_offset = 8.0;                 // from each end

// Side relief pockets (to resemble long bearing block profile)
pocket_depth = 6.0;                   // from top down
pocket_wall = 3.0;                    // wall thickness around pockets
pocket_corner_r = 3.0;

// Helpers
module rounded_rect_2d(w,l,r){
    r2 = min(r, min(w,l)/2);
    hull(){
        translate([ w/2 - r2,  l/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  l/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -l/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -l/2 + r2]) circle(r=r2);
    }
}

module counterbored_hole(hole_d, cb_d, cb_depth, h){
    cylinder(d=hole_d, h=h+0.2, center=false);
    translate([0,0,h-cb_depth]) cylinder(d=cb_d, h=cb_depth+0.2, center=false);
}

module bearing_block(){
    difference(){
        // Main body
        linear_extrude(height=block_h)
            rounded_rect_2d(block_w, block_l, r=2.5);

        // Linear shaft bore along Y (clearly a channel through the length)
        translate([0,0,bore_center_z])
            rotate([90,0,0])
                cylinder(d=bore_d, h=block_l+0.6, center=true);

        // Clamp split slot: open to top, runs along Y, intersects bore
        slot_len = block_l - 2*slot_end_margin;
        slot_h = block_h - slot_bottom_skin - slot_top_skin;
        translate([0, 0, slot_bottom_skin + slot_h/2])
            cube([slot_w, slot_len, slot_h+0.2], center=true);

        // Mounting holes (4)
        for (sx = [-1, 1], sy = [-1, 1]){
            x = sx*(block_w/2 - mount_x_offset);
            y = sy*(block_l/2 - mount_y_offset);
            translate([x,y,0])
                counterbored_hole(mount_hole_d, mount_counterbore_d, mount_counterbore_depth, block_h);
        }

        // Two long top relief pockets (left/right), leaving a center web around the bore
        // Pocket width per side (keeps center web and outer walls)
        pocket_w = (block_w - 2*pocket_wall) / 2 - pocket_wall/2;
        pocket_l = block_l - 2*pocket_wall;

        // Left pocket
        translate([-(block_w/2 - pocket_wall) / 2, 0, block_h - pocket_depth])
            linear_extrude(height=pocket_depth+0.2)
                rounded_rect_2d(pocket_w, pocket_l, pocket_corner_r);

        // Right pocket
        translate([ (block_w/2 - pocket_wall) / 2, 0, block_h - pocket_depth])
            linear_extrude(height=pocket_depth+0.2)
                rounded_rect_2d(pocket_w, pocket_l, pocket_corner_r);

        // Small end chamfers on bore entry (helps visually confirm channel)
        chamfer_d = bore_d + 2.0;
        chamfer_h = 1.2;
        for (sy = [-1, 1]){
            translate([0, sy*(block_l/2 - chamfer_h/2), bore_center_z])
                rotate([90,0,0])
                    cylinder(d1=chamfer_d, d2=bore_d, h=chamfer_h+0.2, center=true);
        }
    }
}

bearing_block();