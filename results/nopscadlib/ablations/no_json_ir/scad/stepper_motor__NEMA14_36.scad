$fn = 96;

// Target dimensions (mm)
face_w        = 35.2;   // square face width
body_len      = 36.0;   // motor body length (front face to back)
shaft_d       = 5.0;    // shaft diameter
mount_spacing = 26.0;   // mounting hole spacing (center-to-center)

// Reasonable defaults for typical stepper features
corner_r      = 2.0;    // body corner radius
flange_t      = 2.0;    // front flange thickness
flange_over   = 1.2;    // flange overhang beyond face
boss_d        = 22.0;   // front pilot/boss diameter
boss_h        = 2.0;    // boss height
shaft_len     = 20.0;   // shaft protrusion length
hole_d        = 3.0;    // mounting hole diameter
hole_depth    = flange_t + boss_h + 2; // ensure holes cut through front features
eps           = 0.2;    // overlap to guarantee watertight unions/differences

module rounded_box_xy(size=[10,10,10], r=1, center=true) {
    // Rounded rectangle extruded in Z
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

module stepper_motor() {
    face_z = 0;                 // front face plane at z=0
    body_center_z = -(body_len/2);

    flange_w = face_w + 2*flange_over;

    difference() {
        union() {
            // Main body (behind the face)
            translate([0,0,body_center_z])
                rounded_box_xy([face_w, face_w, body_len], r=corner_r, center=true);

            // Front flange (slightly larger square plate)
            translate([0,0, -(flange_t/2) + eps])
                rounded_box_xy([flange_w, flange_w, flange_t], r=corner_r, center=true);

            // Front pilot/boss (cylindrical)
            translate([0,0, boss_h/2 + eps])
                cylinder(h=boss_h, d=boss_d, center=true);

            // Output shaft (cylindrical, protruding from front)
            translate([0,0, boss_h + shaft_len/2])
                cylinder(h=shaft_len, d=shaft_d, center=true);
        }

        // Mounting holes through the front flange/boss region
        for (x = [-mount_spacing/2, mount_spacing/2])
            for (y = [-mount_spacing/2, mount_spacing/2])
                translate([x, y, hole_depth/2 - eps])
                    cylinder(h=hole_depth + 2*eps, d=hole_d, center=true);
    }
}

stepper_motor();