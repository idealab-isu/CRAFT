$fn = 96;

module bearing_block(){
    // Given parameters
    bore_d = 8;                 // shaft bore diameter
    centerline_offset = 13;     // lateral offset from block center to bore center
    height_to_shaft_center = 26;
    base_flange_height = 21;
    pattern_x = 28;
    pattern_y = 45;

    // Chosen reasonable block dimensions (not specified)
    body_x = 36;
    body_y = 60;
    body_h = 48;

    flange_x = 50;
    flange_y = 70;
    flange_h = base_flange_height;

    // Mounting holes (reasonable)
    screw_d = 5.5;   // clearance for M5
    counterbore_d = 10;
    counterbore_h = 4;

    // Bore length and relief
    bore_len = body_y + 6;

    // Helper: rounded-ish block via hull of cylinders
    module rounded_block(x,y,h,r){
        hull(){
            translate([ x/2 - r,  y/2 - r, 0]) cylinder(h=h, r=r);
            translate([-x/2 + r,  y/2 - r, 0]) cylinder(h=h, r=r);
            translate([ x/2 - r, -y/2 + r, 0]) cylinder(h=h, r=r);
            translate([-x/2 + r, -y/2 + r, 0]) cylinder(h=h, r=r);
        }
    }

    module mounting_holes(){
        for (sx = [-pattern_x/2, pattern_x/2])
            for (sy = [-pattern_y/2, pattern_y/2]){
                // through hole
                translate([sx, sy, -1]) cylinder(h=flange_h + 2, d=screw_d);
                // counterbore on top of flange
                translate([sx, sy, flange_h - counterbore_h]) cylinder(h=counterbore_h + 1, d=counterbore_d);
            }
    }

    // Geometry setup: place bottom of flange at z=0; then center whole part around origin at end
    // Shaft bore center must be at z = height_to_shaft_center, and x = centerline_offset, y = 0
    z_shift = -(body_h/2); // placeholder, recentered later with translate

    difference(){
        union(){
            // Base flange
            translate([0, 0, 0])
                rounded_block(flange_x, flange_y, flange_h, 4);

            // Main body above flange (blend a bit)
            translate([0, 0, flange_h - 2])
                rounded_block(body_x, body_y, body_h - (flange_h - 2), 5);

            // Boss around bore
            boss_r = 12;
            boss_len = body_y - 12;
            translate([centerline_offset, 0, height_to_shaft_center])
                rotate([90,0,0])
                    cylinder(h=boss_len, r=boss_r, center=true);

            // Small rib from boss to base
            rib_th = 10;
            rib_y = 26;
            rib_z0 = flange_h;
            rib_z1 = height_to_shaft_center;
            hull(){
                translate([centerline_offset, 0, rib_z0])
                    rotate([90,0,0]) cylinder(h=rib_y, r=rib_th/2, center=true);
                translate([centerline_offset, 0, rib_z1])
                    rotate([90,0,0]) cylinder(h=rib_y, r=rib_th/2, center=true);
            }
        }

        // Shaft bore (through along Y)
        translate([centerline_offset, 0, height_to_shaft_center])
            rotate([90,0,0])
                cylinder(h=bore_len, d=bore_d, center=true);

        // Optional split slit for clamping (reasonable)
        slit_w = 1.5;
        slit_h = body_h;
        translate([centerline_offset + bore_d/2 + 0.5, 0, flange_h + (body_h - flange_h)/2])
            cube([slit_w, body_y + 2, slit_h], center=true);

        // Mounting holes pattern on flange
        mounting_holes();

        // Undercut to reduce material (reasonable)
        translate([0, 0, 3])
            rounded_block(flange_x - 14, flange_y - 14, flange_h - 6, 3);
    }
}

// Center near origin: compute approximate bounding extents and shift so mid is near 0
module centered_bearing_block(){
    // Use same dims as inside bearing_block for centering
    body_h = 48;
    flange_h = 21;
    total_h = flange_h + (body_h - (flange_h - 2)); // matches union placement approx
    z_center = total_h/2;
    translate([0,0,-z_center]) bearing_block();
}

centered_bearing_block();