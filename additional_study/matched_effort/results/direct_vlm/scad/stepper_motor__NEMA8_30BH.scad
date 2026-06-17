$fn = 96;

// Parameters (mm)
face_w = 20.0;          // square face width
body_len = 30.0;        // motor body length (front face to rear face)
shaft_d = 5.0;          // shaft diameter
mount_spacing = 16.0;   // center-to-center mounting hole spacing (square pattern)

// Typical details (reasonable defaults)
corner_r = 2.0;         // body corner radius
front_boss_d = 12.0;    // front pilot/boss diameter
front_boss_h = 2.0;     // front pilot/boss height (protrudes from front face)
mount_hole_d = 3.0;     // mounting hole diameter
shaft_len = 18.0;       // shaft protrusion length from front face (not including boss)
shaft_flat = false;     // set true to add a D-flat (optional)
shaft_flat_depth = 0.6; // depth of flat cut (if enabled)

// Small overlap to guarantee watertight unions
eps = 0.2;

// Helpers
module rounded_square_2d(w, r){
    r2 = min(r, w/2);
    offset(r=r2) square([w-2*r2, w-2*r2], center=true);
}

module motor_body_solid(){
    // Centered at origin; Z spans [-body_len/2, +body_len/2]
    linear_extrude(height=body_len, center=true)
        rounded_square_2d(face_w, corner_r);
}

module front_boss_solid(){
    // Boss protrudes from FRONT face (at z = -body_len/2) outward in -Z
    translate([0, 0, -body_len/2 - front_boss_h/2 + eps/2])
        cylinder(d=front_boss_d, h=front_boss_h + eps, center=true);
}

module shaft_solid(){
    // Shaft starts at front face and extends outward in -Z
    if (!shaft_flat){
        translate([0, 0, -body_len/2 - shaft_len/2 + eps/2])
            cylinder(d=shaft_d, h=shaft_len + eps, center=true);
    } else {
        difference(){
            translate([0, 0, -body_len/2 - shaft_len/2 + eps/2])
                cylinder(d=shaft_d, h=shaft_len + eps, center=true);
            // Cut flat along +X side
            translate([shaft_d/2 - shaft_flat_depth, 0, -body_len/2 - shaft_len/2])
                cube([shaft_d, shaft_d*2, shaft_len + 2*eps], center=true);
        }
    }
}

module mounting_holes_cut(){
    // Through-holes along Z through the body (and slightly beyond)
    for (x = [-mount_spacing/2, mount_spacing/2])
    for (y = [-mount_spacing/2, mount_spacing/2])
        translate([x, y, 0])
            cylinder(d=mount_hole_d, h=body_len + 2*eps, center=true);
}

module stepper_motor(){
    // One connected solid: body + boss + shaft, with holes subtracted
    difference(){
        union(){
            motor_body_solid();
            front_boss_solid();
            shaft_solid();
        }
        mounting_holes_cut();
    }
}

// Render
stepper_motor();