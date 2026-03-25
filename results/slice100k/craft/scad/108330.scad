$fn = 128;

// Target bounding box (mm): 46.19 x 40.00 x 7.00
bbox_X = 46.19;                 // point-to-point
bbox_Y = 40.00;                 // flat-to-flat
thickness_Z = 7.00;

hole_d = 10.00;
hole_offset_x = 0;
hole_offset_y = 0;

// Chevron/V-groove recessed relief on two opposing LARGE faces (top & bottom)
chevron_depth   = 1.00;         // recess depth into the face (along Z)
chevron_land_w  = 2.00;         // small flat land between the two V cuts (along Y)
chevron_span_w  = 28.00;        // total span across the face (along Y)
chevron_angle_deg = 35;         // angle of each groove arm in the face plane

// Robust boolean overlap
overlap = 1.00;                 // 1-2mm as requested

// Derived
R = bbox_X/2;                   // center to point
apothem = bbox_Y/2;             // center to flat

// Regular hex in XY with flats horizontal (top/bottom)
module hex2d() {
    polygon(points=[
        [ R, 0 ],
        [ R/2,  apothem ],
        [ -R/2, apothem ],
        [ -R, 0 ],
        [ -R/2, -apothem ],
        [ R/2,  -apothem ]
    ]);
}

module hex_prism_body() {
    linear_extrude(height=thickness_Z, center=true)
        hex2d();
}

module through_hole() {
    translate([hole_offset_x, hole_offset_y, 0])
        cylinder(d=hole_d, h=thickness_Z + 2*overlap, center=true);
}

// Chevron recess cut into a large face at z = +/- thickness_Z/2.
// Implemented as two rotated "bars" in the XY plane, extruded in Z to cut downward/upward.
// This makes the chevron visible in orthographic views (as edges/lines on the face).
module chevron_recess_on_face(face_sign=+1) {
    // face_sign: +1 = top face, -1 = bottom face
    // Cutter thickness in Z: enough to fully remove chevron_depth into the face with overlap.
    cut_h = chevron_depth + 2*overlap;

    // Place cutter so it intersects the face and cuts inward by chevron_depth.
    // For top: center slightly above the top surface; for bottom: slightly below bottom surface.
    z_center = face_sign*(thickness_Z/2 - chevron_depth/2 + overlap);

    // Arm sizing in XY
    arm_len = chevron_span_w/2;
    arm_w   = (chevron_span_w/2) + chevron_land_w; // wide enough after rotation

    // Centers of the two arms in Y so they leave a land of width chevron_land_w at Y=0.
    y_center = chevron_land_w/2 + arm_len/2;

    translate([0, 0, z_center])
        union() {
            // Upper arm
            translate([0, +y_center, 0])
                rotate([0, 0, chevron_angle_deg])
                    cube([arm_w, arm_w, cut_h], center=true);

            // Lower arm
            translate([0, -y_center, 0])
                rotate([0, 0, -chevron_angle_deg])
                    cube([arm_w, arm_w, cut_h], center=true);
        }
}

difference() {
    // Single solid base
    hex_prism_body();

    // Through hole
    through_hole();

    // Chevron recessed relief on two opposing faces (top and bottom)
    chevron_recess_on_face(+1);
    chevron_recess_on_face(-1);
}