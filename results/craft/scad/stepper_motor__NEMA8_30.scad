// NEMA8-like stepper motor with requested key dimensions:
// - 20.0mm face width
// - 30.0mm body length (behind face)
// - 4.0mm shaft diameter
// - 16.0mm mounting hole spacing (center-to-center)
// One connected solid; all translations derived from dimensions.

$fn = 96;

// Requested dimensions
face_width = 20.0;
body_length = 30.0;
shaft_diameter = 4.0;
mount_hole_spacing = 16.0;

// Typical/simple details (kept minimal but NEMA-like)
face_plate_thickness = 2.0;
body_corner_radius = 1.0;

front_hub_diameter = 10.0;
front_hub_thickness = 2.0;

shaft_length = 12.0;

mount_hole_diameter = 3.0;     // through holes
counterbore_diameter = 6.0;
counterbore_depth = 1.0;

rear_boss_diameter = 10.0;     // rear pilot/boss (common on steppers)
rear_boss_thickness = 1.5;

connector_w = 10.0;
connector_h = 8.0;
connector_d = 6.0;

eps = 0.01;
overlap = 0.6;

// Rounded box helper (fast + stable)
module rounded_box(size=[10,10,10], r=1, center=true) {
    rr = min(r, min(size[0], min(size[1], size[2]))/2 - eps);
    minkowski() {
        cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=center);
        sphere(r=rr);
    }
}

// Main solid (no holes)
module motor_solid() {
    // Coordinate system:
    // Faceplate front surface at z=0
    // Body extends to negative z
    union() {
        // Body (behind faceplate)
        translate([0, 0, -face_plate_thickness - body_length/2 + overlap/2])
            rounded_box([face_width, face_width, body_length + overlap], r=body_corner_radius, center=true);

        // Faceplate (square)
        translate([0, 0, -face_plate_thickness/2])
            cube([face_width, face_width, face_plate_thickness + overlap], center=true);

        // Front hub (boss) on face
        translate([0, 0, front_hub_thickness/2 - overlap/2])
            cylinder(d=front_hub_diameter, h=front_hub_thickness + overlap, center=true);

        // Shaft (4mm diameter)
        translate([0, 0, front_hub_thickness + shaft_length/2 - overlap/2])
            cylinder(d=shaft_diameter, h=shaft_length + overlap, center=true);

        // Rear boss (pilot) on back face of body
        translate([0, 0, -face_plate_thickness - body_length - rear_boss_thickness/2 + overlap/2])
            cylinder(d=rear_boss_diameter, h=rear_boss_thickness + overlap, center=true);

        // Side connector block (attached to body side, not floating)
        translate([face_width/2 + connector_d/2 - overlap, 0,
                   -face_plate_thickness - body_length*0.25])
            cube([connector_d, connector_w, connector_h], center=true);
    }
}

module motor() {
    difference() {
        motor_solid();

        // 4 mounting holes on 16mm spacing, through faceplate only
        for (sx = [-1, 1], sy = [-1, 1]) {
            x = sx * mount_hole_spacing/2;
            y = sy * mount_hole_spacing/2;

            // Through hole (slightly extended to guarantee cut)
            translate([x, y, -face_plate_thickness/2])
                cylinder(d=mount_hole_diameter, h=face_plate_thickness + 2*eps, center=true);

            // Counterbore from front side (z from 0 downwards)
            translate([x, y, -counterbore_depth/2 + eps])
                cylinder(d=counterbore_diameter, h=counterbore_depth + 2*eps, center=true);
        }
    }
}

motor();