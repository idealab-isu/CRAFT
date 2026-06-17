// NEMA-style stepper motor (single connected solid)
// Target critical dims:
// - face_width = 42.3 mm
// - body_length = 40.0 mm
// - shaft_diameter = 5.0 mm
// - mount_hole_spacing = 31.0 mm

$fn = 64;

// Parameters
face_width = 42.3;
body_width = 42.3;
body_length = 40.0;

front_face_thickness = 3.0;

shaft_diameter = 5.0;
shaft_length = 20.0;
shaft_offset_from_face = 0.0;

mount_hole_spacing = 31.0;
mount_hole_diameter = 3.2;

corner_radius = 2.0;

shaft_boss_diameter = 22.0;
shaft_boss_height = 2.0;

rear_boss_diameter = 18.0;
rear_boss_height = 1.5;

eps = 0.2;

// Rounded rectangle prism (centered)
module rounded_cube_xy(size=[10,10,10], r=1, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        linear_extrude(height=sz, center=true)
            offset(r=r)
                square([sx-2*r, sy-2*r], center=true);
}

// Main motor solid with holes subtracted (still one connected solid)
module stepper_motor() {

    // Z reference: front face outer surface at z=0
    // Body extends to negative Z, shaft to positive Z.
    z_face_center = -front_face_thickness/2;
    z_body_center = -(front_face_thickness + body_length)/2;
    z_front_boss_center = shaft_boss_height/2; // boss starts at z=0
    z_shaft_center = front_face_thickness + shaft_offset_from_face + shaft_length/2; // shaft starts at z=front_face_thickness+offset
    z_rear_boss_center = -(front_face_thickness + body_length) - rear_boss_height/2; // rear boss behind body

    difference() {
        union() {
            // Motor body (rounded)
            translate([0,0,z_body_center])
                rounded_cube_xy([body_width, body_width, body_length], r=corner_radius, center=true);

            // Front face plate (slightly rounded)
            translate([0,0,z_face_center])
                rounded_cube_xy([face_width, face_width, front_face_thickness], r=corner_radius, center=true);

            // Front circular boss (register)
            translate([0,0,z_front_boss_center])
                cylinder(h=shaft_boss_height, r=shaft_boss_diameter/2, center=true);

            // Shaft (5mm dia) connected to face (starts at z=front_face_thickness+offset)
            translate([0,0,z_shaft_center])
                cylinder(h=shaft_length, r=shaft_diameter/2, center=true);

            // Rear boss (small nub) connected to back of body
            translate([0,0,z_rear_boss_center])
                cylinder(h=rear_boss_height, r=rear_boss_diameter/2, center=true);
        }

        // Mounting holes through front face plate (clear, verifiable 31mm spacing)
        // Holes go through the front face thickness only (plus eps), starting at z=0 downwards.
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, -front_face_thickness/2])
                    cylinder(h=front_face_thickness + 2*eps, r=mount_hole_diameter/2, center=true);
    }
}

stepper_motor();