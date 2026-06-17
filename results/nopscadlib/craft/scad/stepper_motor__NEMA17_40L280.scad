$fn = 96;

// Target dimensions (mm)
face_width           = 42.3;   // square front face
body_length          = 40.0;   // motor body length (behind face)
front_face_thickness = 3.0;

shaft_diameter       = 8.0;
shaft_length         = 20.0;

mount_hole_spacing   = 31.0;   // center-to-center
mount_hole_diameter  = 3.5;    // clearance
mount_hole_depth     = 6.0;    // into face/body from the front surface

// Typical NEMA17-ish details
center_boss_diameter = 22.0;
center_boss_height   = 2.0;

corner_radius        = 3.0;    // body edge rounding
overlap              = 0.6;    // overlap to ensure watertight unions/differences

// ---------- helpers ----------
module rounded_box(size=[10,10,10], r=1, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    minkowski() {
        cube([sx-2*r, sy-2*r, sz-2*r], center=center);
        sphere(r=r);
    }
}

module mount_holes() {
    // Cut from the FRONT surface (z = +front_face_thickness/2) inward by mount_hole_depth
    z_front = front_face_thickness/2;
    zc = z_front - mount_hole_depth/2; // center of the cutting cylinder
    for (x = [-mount_hole_spacing/2, mount_hole_spacing/2])
        for (y = [-mount_hole_spacing/2, mount_hole_spacing/2])
            translate([x, y, zc])
                cylinder(d=mount_hole_diameter, h=mount_hole_depth + 2*overlap, center=true);
}

module shaft_flat_cut() {
    // D-shaft flat cut
    flat_depth = 1.0;   // removed depth (radial)
    flat_len   = 10.0;  // along shaft axis

    // Shaft starts at z = front_face_thickness/2 + center_boss_height - overlap
    z_shaft_base = front_face_thickness/2 + center_boss_height - overlap;

    // Cutter intersects the shaft near its outer surface
    translate([shaft_diameter/2 - flat_depth/2, 0, z_shaft_base + flat_len/2])
        cube([flat_depth, shaft_diameter*1.3, flat_len], center=true);
}

// ---------- main motor ----------
module stepper_motor() {
    difference() {
        union() {
            // Motor body (behind face), connected with slight overlap into the face
            translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
                rounded_box([face_width, face_width, body_length], r=corner_radius, center=true);

            // Front face plate
            cube([face_width, face_width, front_face_thickness], center=true);

            // Center boss (pilot)
            translate([0, 0, front_face_thickness/2 + center_boss_height/2 - overlap])
                cylinder(d=center_boss_diameter, h=center_boss_height, center=true);

            // Shaft (protruding from front)
            translate([0, 0, front_face_thickness/2 + center_boss_height - overlap + shaft_length/2])
                cylinder(d=shaft_diameter, h=shaft_length, center=true);
        }

        // Mounting holes (31mm spacing) visible from the front
        mount_holes();

        // Shaft flat
        shaft_flat_cut();
    }
}

stepper_motor();