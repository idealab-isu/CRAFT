$fn = 96;

// Long linear bearing block for 6.0mm shaft
// Overall block size: 34.0mm x 58.0mm (X x Y). Height chosen as a reasonable default.

shaft_d = 6.0;
block_x = 34.0;
block_y = 58.0;
block_z = 18.0;

corner_r = 3.0;

// Bore and reliefs
bore_clearance = 0.25;          // diameter clearance
bore_d = shaft_d + bore_clearance;

bore_center_z = block_z/2;      // centered vertically
bore_len = block_y + 2.0;       // through along Y

// Split clamp slot
slot_w = 1.6;                   // slot thickness
slot_x = block_x;               // full width
slot_z_from_top = 0.0;          // start at top surface
slot_depth = block_z - bore_center_z; // down to bore center

// Clamp screw holes (2x), across X, above bore
screw_d = 3.2;                  // M3 clearance
nut_flat = 5.7;                 // M3 hex nut across flats
nut_thick = 2.6;
screw_z = block_z - 5.0;
screw_y_offset = 14.0;

// Helper: rounded rectangle prism
module rounded_block(x, y, z, r){
    r2 = min(r, min(x,y)/2);
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

// Helper: hex prism (across flats)
module hex_prism(af, h){
    // For a regular hexagon, across flats = 2*apothem = sqrt(3)*R
    // So circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

difference(){
    // Main body
    translate([0,0,0])
        rounded_block(block_x, block_y, block_z, corner_r);

    // Shaft bore along Y
    translate([0, 0, bore_center_z])
        rotate([90,0,0])
            cylinder(d=bore_d, h=bore_len, center=true);

    // Small relief at bore entry (both ends) to ease insertion
    chamfer_d = bore_d + 2.0;
    chamfer_h = 1.2;
    for (sy = [-block_y/2, block_y/2]){
        translate([0, sy, bore_center_z])
            rotate([90,0,0])
                cylinder(d1=chamfer_d, d2=bore_d, h=chamfer_h, center=false);
    }

    // Split clamp slot from top down to bore center
    translate([0, 0, block_z - slot_depth/2])
        cube([slot_x+0.5, slot_w, slot_depth+0.2], center=true);

    // Clamp screw holes + nut traps (2 positions along Y)
    for (yy = [-screw_y_offset, screw_y_offset]){
        // Through hole across X
        translate([0, yy, screw_z])
            rotate([0,90,0])
                cylinder(d=screw_d, h=block_x+2.0, center=true);

        // Nut trap on +X side
        translate([block_x/2 - (nut_thick/2 + 0.6), yy, screw_z])
            rotate([0,90,0])
                hex_prism(nut_flat, nut_thick + 1.2);

        // Screw head clearance on -X side (simple counterbore)
        head_d = 6.2;
        head_h = 2.8;
        translate([-block_x/2 + head_h/2 + 0.6, yy, screw_z])
            rotate([0,90,0])
                cylinder(d=head_d, h=head_h + 1.2, center=true);
    }

    // Lightening pockets on sides (optional, keeps strength around bore)
    pocket_margin_x = 4.0;
    pocket_margin_y = 6.0;
    pocket_z = 6.0;
    pocket_z_pos = 3.0;

    for (sx = [-1, 1]){
        translate([sx*(block_x/2 - pocket_margin_x/2), 0, pocket_z_pos + pocket_z/2])
            cube([block_x - 2*pocket_margin_x, block_y - 2*pocket_margin_y, pocket_z], center=true);
    }
}