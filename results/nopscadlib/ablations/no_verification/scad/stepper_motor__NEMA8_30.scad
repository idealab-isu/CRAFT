$fn = 96;

// Target dimensions (as requested)
face_width = 20.0;          // square face width (X,Y)
body_length = 30.0;         // body length behind face (Z-)
shaft_diameter = 4.0;       // shaft diameter
shaft_length = 12.0;        // shaft length in front of face (Z+)
mount_hole_spacing = 16.0;  // center-to-center spacing (square pattern)
mount_hole_diameter = 3.0;  // through holes in face

// Typical stepper front-face features (kept proportional to 20mm face)
face_thickness = 2.5;       // front plate thickness
boss_diameter = 10.0;       // front pilot/boss diameter
boss_height = 1.5;          // boss protrusion
corner_chamfer = 1.0;       // small chamfer on front face edges
body_corner_radius = 1.2;   // slight rounding on body corners

// Small overlap to guarantee watertight unions/differences
overlap = 0.25;

// Coordinate system: front face outer surface at Z=0, body extends to negative Z, shaft to positive Z
z_face_center = -face_thickness/2;
z_body_center = -(face_thickness + body_length/2 - overlap);
z_boss_center =  boss_height/2 - overlap;
z_shaft_center =  boss_height + shaft_length/2 - overlap;

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
    // Minkowski-based rounding; keep r small for performance
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=center);
        sphere(r=r);
    }
}

module chamfered_plate(w=20, t=2.5, c=1.0) {
    // Chamfer only on the front (Z=0) edge using a hull between a slightly smaller front square and full back square
    // Back of plate at Z=-t, front at Z=0
    hull() {
        translate([0,0,-t]) cube([w, w, overlap], center=false);
        translate([c, c, -overlap]) cube([w-2*c, w-2*c, overlap], center=false);
    }
}

module motor_body() {
    // Body sits behind the face; slightly rounded corners for a more motor-like look
    translate([0, 0, z_body_center])
        rounded_box([face_width, face_width, body_length], r=body_corner_radius, center=true);
}

module front_face() {
    // Chamfered front plate, connected to body
    translate([-face_width/2, -face_width/2, 0])
        chamfered_plate(w=face_width, t=face_thickness, c=corner_chamfer);
}

module front_boss() {
    // Typical stepper pilot/boss on the front face
    translate([0, 0, z_boss_center])
        cylinder(d=boss_diameter, h=boss_height, center=true);
}

module motor_shaft() {
    // Single-ended shaft only (no through-shaft)
    translate([0, 0, z_shaft_center])
        cylinder(d=shaft_diameter, h=shaft_length, center=true);
}

module mounting_holes_pattern() {
    // Through holes only in the face plate thickness (plus overlap)
    // Centers at +/- mount_hole_spacing/2 in X and Y
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2, z_face_center])
            cylinder(d=mount_hole_diameter, h=face_thickness + 2*overlap, center=true);
}

// ONE connected solid: body + face + boss + shaft, with holes subtracted
difference() {
    union() {
        motor_body();
        front_face();
        front_boss();
        motor_shaft();
    }
    mounting_holes_pattern();
}