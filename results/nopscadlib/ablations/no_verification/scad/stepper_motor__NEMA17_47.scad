$fn = 96;

// Target dimensions (mm)
face_width          = 42.3;   // X
face_height         = 42.3;   // Y
body_length         = 47.0;   // Z (depth)

shaft_diameter      = 5.0;
shaft_length        = 24.0;

mount_hole_spacing  = 31.0;
mount_hole_diameter = 3.5;

front_face_thickness = 3.0;
rear_cap_thickness   = 3.0;

boss_diameter       = 22.0;
boss_thickness      = 2.0;

corner_radius       = 2.0;

// Small overlap to guarantee connectivity / avoid coplanar artifacts
overlap = 0.6;

// Optional details
grill_width = 28;
grill_height = 28;
grill_hole_diameter = 3;
grill_hole_count_x = 4;
grill_hole_count_y = 4;

d_flat_depth  = 0.6;
d_flat_length = 16;

// ---------- Helpers ----------
module rounded_box_xy(size=[10,10,10], r=1, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, sx/2, sy/2);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        linear_extrude(height=sz, center=true)
            offset(r=rr)
                square([sx-2*rr, sy-2*rr], center=true);
}

module grill_holes(z_center, h) {
    for (ix = [0:grill_hole_count_x-1])
        for (iy = [0:grill_hole_count_y-1]) {
            x = -(grill_width/2)  + (grill_width/grill_hole_count_x )*(ix+0.5);
            y = -(grill_height/2) + (grill_height/grill_hole_count_y)*(iy+0.5);
            translate([x, y, z_center])
                cylinder(d=grill_hole_diameter, h=h, center=true);
        }
}

module mount_holes(z_center, h) {
    for (xsgn = [-1, 1])
        for (ysgn = [-1, 1])
            translate([xsgn*mount_hole_spacing/2, ysgn*mount_hole_spacing/2, z_center])
                cylinder(d=mount_hole_diameter, h=h, center=true);
}

// ---------- Motor ----------
module motor() {
    // Coordinate system:
    // X = left/right, Y = up/down, Z = front/back (shaft points +Z)

    // Place the body so the FRONT face is at Z=0 and the BACK is at Z=-body_length
    z_body_center = -body_length/2;

    // Feature centers (all derived from dimensions)
    z_front_plate_center = 0 - front_face_thickness/2;
    z_rear_cap_center    = -body_length + rear_cap_thickness/2;

    z_boss_center  = 0 + boss_thickness/2 - overlap; // overlaps into front plate/body
    z_shaft_center = 0 + boss_thickness - overlap + shaft_length/2;

    difference() {
        union() {
            // Main body (full depth visible in side/top views)
            translate([0, 0, z_body_center])
                rounded_box_xy([face_width, face_height, body_length], r=corner_radius, center=true);

            // Front face plate (slight overlap into body)
            translate([0, 0, z_front_plate_center - overlap/2])
                rounded_box_xy([face_width, face_height, front_face_thickness + overlap], r=corner_radius, center=true);

            // Rear cap (slight overlap into body)
            translate([0, 0, z_rear_cap_center + overlap/2])
                rounded_box_xy([face_width, face_height, rear_cap_thickness + overlap], r=corner_radius, center=true);

            // Front boss (overlaps into front plate/body)
            translate([0, 0, z_boss_center])
                cylinder(d=boss_diameter, h=boss_thickness + overlap, center=true);

            // Shaft (centered on face; visible in front/back views as a circle)
            translate([0, 0, z_shaft_center])
                cylinder(d=shaft_diameter, h=shaft_length + overlap, center=true);
        }

        // Mounting holes through front plate + boss only (not through whole body)
        mount_hole_h = front_face_thickness + boss_thickness + 2*overlap;
        mount_hole_z = 0 + (boss_thickness - front_face_thickness)/2 - overlap/2;
        mount_holes(mount_hole_z, mount_hole_h);

        // Rear grill holes through rear cap only
        grill_hole_h = rear_cap_thickness + 2*overlap;
        grill_hole_z = -body_length + rear_cap_thickness/2;
        grill_holes(grill_hole_z, grill_hole_h);

        // D-flat on shaft near the tip (subtract a slab)
        z_flat_center = (0 + boss_thickness - overlap) + shaft_length - d_flat_length/2;
        translate([shaft_diameter/2 - d_flat_depth/2, 0, z_flat_center])
            cube([shaft_diameter + 2, shaft_diameter + 2, d_flat_length], center=true);
    }
}

motor();