// NEMA17-like stepper motor (single connected solid)
// Target dims: 42.3mm face width, 34.0mm body length, 5.0mm shaft dia, 31.0mm mounting hole spacing

$fn = 64;

// Parameters
face_width = 42.3;
body_length = 34.0;

front_plate_thickness = 3.0;

shaft_diameter = 5.0;
shaft_length = 20.0;

shaft_boss_diameter = 22.0;
shaft_boss_height = 2.0;

mount_hole_spacing = 31.0;
mount_hole_diameter = 3.5;

mount_hole_counterbore_diameter = 6.5;
mount_hole_counterbore_depth = 1.5;

corner_radius = 2.0;     // visual rounding on body edges
overlap = 0.6;           // small overlap to guarantee connectivity / robust boolean ops

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
    // Minkowski rounded cube (kept modest for performance)
    minkowski() {
        cube([max(0.01, size[0]-2*r), max(0.01, size[1]-2*r), max(0.01, size[2]-2*r)], center=center);
        sphere(r=r, $fn=24);
    }
}

module nema17_motor() {
    // Coordinate system:
    // Front face plane is at z=0, motor extends to negative z, shaft extends to positive z.
    difference() {
        union() {
            // Main body (rounded)
            translate([0,0,-body_length/2])
                rounded_box([face_width, face_width, body_length], r=corner_radius, center=true);

            // Front faceplate (slightly proud of body for visible detail)
            translate([0,0,-front_plate_thickness/2 + overlap])
                cube([face_width, face_width, front_plate_thickness], center=true);

            // Front boss
            translate([0,0,shaft_boss_height/2 - overlap])
                cylinder(d=shaft_boss_diameter, h=shaft_boss_height, center=true, $fn=96);

            // Shaft (connected to boss)
            translate([0,0,shaft_boss_height - overlap + shaft_length/2])
                cylinder(d=shaft_diameter, h=shaft_length, center=true, $fn=64);

            // Rear pilot (small nub) to make back view recognizable (still connected)
            rear_pilot_d = 12.0;
            rear_pilot_h = 1.5;
            translate([0,0,-body_length + rear_pilot_h/2 - overlap])
                cylinder(d=rear_pilot_d, h=rear_pilot_h, center=true, $fn=64);
        }

        // Mounting holes through faceplate (31mm spacing)
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, -front_plate_thickness/2])
                    cylinder(d=mount_hole_diameter, h=front_plate_thickness + 2*overlap, center=true, $fn=32);

        // Counterbores on front face (shallow)
        for (x = [-1, 1])
            for (y = [-1, 1])
                translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, -mount_hole_counterbore_depth/2 + overlap])
                    cylinder(d=mount_hole_counterbore_diameter, h=mount_hole_counterbore_depth + 2*overlap, center=true, $fn=48);

        // Front face recess ring around boss (visual detail)
        recess_d = 24.0;
        recess_depth = 0.6;
        translate([0,0,-recess_depth/2 + overlap])
            cylinder(d=recess_d, h=recess_depth + 2*overlap, center=true, $fn=96);
    }
}

nema17_motor();