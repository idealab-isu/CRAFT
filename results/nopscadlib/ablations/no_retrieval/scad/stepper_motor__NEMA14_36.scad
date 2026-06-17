$fn = 96;

// =====================
// Parameters (mm)
// =====================
face_W = 35.2;                 // motor face width (X and Z)
body_L = 36.0;                 // motor body length (Y)

front_face_T = 2.0;            // front plate thickness
rear_cap_T   = 2.0;            // rear plate thickness
rear_cap_inset = 0.6;          // rear cap inset from body edges

shaft_D = 5.0;                 // shaft diameter
shaft_L = 20.0;                // shaft length from boss front

boss_D = 22.0;                 // front pilot/boss diameter
boss_H = 2.0;                  // boss height

mount_spacing = 26.0;          // hole spacing (square pattern, center-to-center)
mount_hole_D = 3.0;            // mounting hole diameter
mount_hole_depth = 6.0;        // depth into motor from front face

shaft_flat_depth = 0.5;        // depth of D-flat
shaft_flat_L = 10.0;           // length of flat along shaft (from tip)

connector_W = 12.0;
connector_H = 8.0;
connector_L = 6.0;
connector_offset_Z = 0.0;

body_corner_R = 2.0;           // corner radius for body (rounded square)

overlap = 0.6;                 // small overlap to guarantee connectivity

// =====================
// Helpers
// =====================
module rounded_box(size=[10,10,10], r=1, center=true) {
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, sx/2, sz/2);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
        for (ix = [-1, 1], iz = [-1, 1]) {
            translate([ix*(sx/2-rr), 0, iz*(sz/2-rr)])
                rotate([90,0,0])
                    cylinder(r=rr, h=sy, center=true);
        }
    }
}

module mounting_holes_pattern() {
    // Holes drilled from the FRONT face into the body along +Y direction.
    // Front face outer plane is at y = -body_L/2 - front_face_T
    // Start the hole just inside the front face and extend into the body.
    y_center = (-body_L/2 - front_face_T) + mount_hole_depth/2 + overlap;

    for (x = [-mount_spacing/2, mount_spacing/2],
         z = [-mount_spacing/2, mount_spacing/2]) {
        translate([x, y_center, z])
            rotate([90,0,0])
                cylinder(d=mount_hole_D, h=mount_hole_depth + 2*overlap, center=true);
    }
}

module shaft_with_flat() {
    // Shaft axis along Y, protruding out the front (-Y).
    // Boss outer front plane is at y = -body_L/2 - front_face_T - boss_H
    y_center = (-body_L/2 - front_face_T - boss_H) - shaft_L/2 + overlap;

    difference() {
        translate([0, y_center, 0])
            rotate([90,0,0])
                cylinder(d=shaft_D, h=shaft_L, center=true);

        // D-flat: subtract a box that cuts into the shaft on +X side
        // Flat starts at the shaft tip and runs shaft_flat_L toward the motor.
        y_tip = (-body_L/2 - front_face_T - boss_H) - shaft_L + overlap;
        translate([shaft_D/2 - shaft_flat_depth + overlap, y_tip + shaft_flat_L/2, 0])
            cube([shaft_D + 2*overlap, shaft_flat_L + 2*overlap, shaft_D + 2*overlap], center=true);
    }
}

// =====================
// Main Model (ONE connected solid)
// =====================
module stepper_motor() {
    difference() {
        union() {
            // Main body (rounded corners)
            color("Black")
                rounded_box([face_W, body_L, face_W], r=body_corner_R, center=true);

            // Front face plate (attached to body, extends outward to -Y)
            color("DimGray")
                translate([0, -body_L/2 - front_face_T/2 + overlap, 0])
                    cube([face_W, front_face_T, face_W], center=true);

            // Front boss/pilot (attached to front face, extends outward to -Y)
            color("Silver")
                translate([0, -body_L/2 - front_face_T - boss_H/2 + overlap, 0])
                    rotate([90,0,0])
                        cylinder(d=boss_D, h=boss_H, center=true);

            // Output shaft with D-flat (attached to boss)
            color("Silver")
                shaft_with_flat();

            // Rear cap (inset, attached to body, extends outward to +Y)
            color("Black")
                translate([0, body_L/2 + rear_cap_T/2 - overlap, 0])
                    cube([face_W - 2*rear_cap_inset, rear_cap_T, face_W - 2*rear_cap_inset], center=true);

            // Rear connector (attached to rear cap)
            color("DimGray")
                translate([0, body_L/2 + rear_cap_T + connector_L/2 - overlap, connector_offset_Z])
                    cube([connector_W, connector_L, connector_H], center=true);
        }

        // Mounting holes (26.0mm spacing square pattern on front face)
        mounting_holes_pattern();
    }
}

// Final output
stepper_motor();