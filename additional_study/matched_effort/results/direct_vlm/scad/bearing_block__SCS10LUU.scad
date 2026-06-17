$fn = 96;

// Long linear bearing block for 8.0mm shaft
// Overall block size: 40.0mm x 68.0mm x 24.0mm (W x L x H)

shaft_d = 8.0;

block_w = 40.0;   // X
block_l = 68.0;   // Y
block_h = 24.0;   // Z

// Through shaft bore (Y axis)
bore_d = shaft_d + 0.4;

// Long bearing pocket cue (LM8LUU-ish)
bearing_od  = 15.2;   // pocket diameter
bearing_len = 45.4;   // pocket length

// Pocket margins
pocket_margin_y = 8.0;
bearing_len_eff = min(bearing_len, block_l - 2*pocket_margin_y);
pocket_y0 = (block_l - bearing_len_eff)/2;

// Retention lips (smaller diameter at both ends of pocket)
lip_len = 2.0;
lip_d   = bearing_od - 1.2; // creates a visible "step" / lip

// Mounting holes (4x)
hole_d = 5.2;          // M5 clearance
counterbore_d = 9.5;   // M5 socket head
counterbore_h = 5.0;

edge_x = 8.0;
edge_y = 10.0;

// Outer fillet
fillet_r = 2.0;

// Split clamp slot + clamp screw (visual/functional cue)
slot_w = 2.2;                 // slot thickness (X)
slot_z0 = 0.0;                // from bottom
slot_h = block_h - 0.0;       // full height
slot_y_margin = 6.0;
slot_len = block_l - 2*slot_y_margin;

clamp_screw_d = 4.2;          // M4 clearance
clamp_head_d  = 8.0;          // head/counterbore
clamp_head_h  = 3.5;
clamp_y = block_l/2;          // centered along length
clamp_z = block_h*0.62;       // above bore center for strength

// Grease port (small vertical hole to pocket)
grease_d = 2.2;
grease_z0 = block_h - 0.01;   // start at top surface
grease_h  = block_h;          // cut down through to pocket

module filleted_block(w,l,h,r){
    // Overall size w x l x h (minkowski adds 2r)
    minkowski(){
        cube([w-2*r, l-2*r, h-2*r], center=false);
        sphere(r=r);
    }
}

difference(){
    // Body (exact overall size)
    filleted_block(block_w, block_l, block_h, fillet_r);

    // Through shaft bore (Y axis), centered in X and Z
    translate([block_w/2, -1, block_h/2])
        rotate([90,0,0])
            cylinder(d=bore_d, h=block_l+2, center=false);

    // Long bearing pocket (larger bore section), centered along length
    translate([block_w/2, pocket_y0, block_h/2])
        rotate([90,0,0])
            cylinder(d=bearing_od, h=bearing_len_eff, center=false);

    // Retention lips at both ends of the pocket (smaller diameter sections)
    // Front lip
    translate([block_w/2, pocket_y0 - 0.01, block_h/2])
        rotate([90,0,0])
            cylinder(d=lip_d, h=lip_len + 0.02, center=false);
    // Back lip
    translate([block_w/2, pocket_y0 + bearing_len_eff - lip_len - 0.01, block_h/2])
        rotate([90,0,0])
            cylinder(d=lip_d, h=lip_len + 0.02, center=false);

    // Lead-in chamfers at both ends of shaft bore
    chamfer_h = 2.0;
    for (yy = [0, block_l - chamfer_h]){
        translate([block_w/2, yy, block_h/2])
            rotate([90,0,0])
                cylinder(d1=bore_d+2.0, d2=bore_d, h=chamfer_h, center=false);
    }

    // Mounting holes + counterbores from top
    for (x = [edge_x, block_w-edge_x])
    for (y = [edge_y, block_l-edge_y]){
        translate([x, y, -1])
            cylinder(d=hole_d, h=block_h+2, center=false);

        translate([x, y, block_h-counterbore_h])
            cylinder(d=counterbore_d, h=counterbore_h+1, center=false);
    }

    // Split clamp slot (cuts from top to bottom, intersects bore/pocket)
    // Place slot slightly to one side of bore so it creates a "split" wall
    slot_x = block_w/2 + (bearing_od/2 - 1.0) - slot_w/2; // near pocket wall
    translate([slot_x, slot_y_margin, slot_z0 - 0.01])
        cube([slot_w, slot_len, slot_h + 0.02], center=false);

    // Clamp screw across the split (X axis), with head counterbore on the right side
    // Through hole
    translate([-1, clamp_y, clamp_z])
        rotate([0,90,0])
            cylinder(d=clamp_screw_d, h=block_w+2, center=false);

    // Head counterbore (right side)
    translate([block_w - clamp_head_h, clamp_y, clamp_z])
        rotate([0,90,0])
            cylinder(d=clamp_head_d, h=clamp_head_h+1, center=false);

    // Grease port from top down into the pocket (Z axis)
    translate([block_w/2, block_l/2, grease_z0])
        cylinder(d=grease_d, h=grease_h, center=false);

    // Side lightening recesses (shallow pockets, not through) to add "bearing block" character
    recess_depth = 2.5;
    recess_h = 14.0;
    recess_z0 = (block_h - recess_h)/2;
    recess_y_margin = 8.0;
    recess_len = block_l - 2*recess_y_margin;
    recess_x0_left  = 0.0 - 0.01;
    recess_x0_right = block_w - recess_depth + 0.01;

    // Keep clear of fillets by leaving a small margin in Y and Z
    translate([recess_x0_left, recess_y_margin, recess_z0])
        cube([recess_depth+0.02, recess_len, recess_h], center=false);

    translate([recess_x0_right, recess_y_margin, recess_z0])
        cube([recess_depth+0.02, recess_len, recess_h], center=false);
}