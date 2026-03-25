// Stepper motor (NEMA17-style) - single connected solid
// Target dims: 42.3mm face width, 47.0mm body length, 5.0mm shaft dia, 31.0mm mounting hole spacing

$fn = 64;

// Parameters
face_width_mm = 42.3;                 // motor face width (X/Y)
body_length_mm = 47.0;                // motor body length (Z)
front_face_thickness_mm = 3.0;        // front plate thickness
shaft_diameter_mm = 5.0;              // shaft diameter
shaft_length_mm = 20.0;               // shaft protrusion length
shaft_boss_diameter_mm = 22.0;        // front boss diameter
shaft_boss_height_mm = 2.0;           // front boss height
mounting_hole_spacing_mm = 31.0;      // center-to-center spacing (square pattern)
mounting_hole_diameter_mm = 3.5;      // clearance hole diameter

// Typical NEMA17-ish details (kept modest)
corner_chamfer_mm = 4.0;              // corner cut size on face
rear_boss_diameter_mm = 18.0;         // rear pilot/boss
rear_boss_height_mm = 1.5;            // rear boss height
connector_w_mm = 16.0;                // rear connector block width (X)
connector_h_mm = 10.0;                // rear connector block height (Y)
connector_d_mm = 6.0;                 // rear connector block depth (Z)
overlap_mm = 0.4;                     // small overlap to guarantee connectivity

module chamfered_prism_xy(w, h, zlen, c) {
    // 2D chamfered square extruded along Z
    linear_extrude(height=zlen, center=true)
        polygon(points=[
            [ w/2 - c,  h/2],
            [-w/2 + c,  h/2],
            [-w/2,      h/2 - c],
            [-w/2,     -h/2 + c],
            [-w/2 + c, -h/2],
            [ w/2 - c, -h/2],
            [ w/2,     -h/2 + c],
            [ w/2,      h/2 - c]
        ]);
}

module stepper_motor() {
    // Coordinate system: motor centered at origin, shaft points toward +Z
    // Front face plane is near +Z, rear near -Z.

    difference() {
        union() {
            // Main body with chamfered corners (NEMA-like)
            chamfered_prism_xy(face_width_mm, face_width_mm, body_length_mm, corner_chamfer_mm);

            // Front faceplate (slightly proud)
            translate([0, 0, body_length_mm/2 - front_face_thickness_mm/2 + overlap_mm])
                chamfered_prism_xy(face_width_mm, face_width_mm, front_face_thickness_mm, corner_chamfer_mm);

            // Front boss/flange around shaft
            translate([0, 0, body_length_mm/2 + shaft_boss_height_mm/2 - overlap_mm])
                cylinder(d=shaft_boss_diameter_mm, h=shaft_boss_height_mm, center=true);

            // Output shaft (connected with overlap into boss)
            translate([0, 0, body_length_mm/2 + shaft_boss_height_mm + shaft_length_mm/2 - overlap_mm])
                cylinder(d=shaft_diameter_mm, h=shaft_length_mm, center=true);

            // Rear pilot/boss (small)
            translate([0, 0, -body_length_mm/2 - rear_boss_height_mm/2 + overlap_mm])
                cylinder(d=rear_boss_diameter_mm, h=rear_boss_height_mm, center=true);

            // Rear connector block (kept attached to rear face)
            translate([0, -(face_width_mm/2 - connector_h_mm/2 - 2.0), -body_length_mm/2 - connector_d_mm/2 + overlap_mm])
                cube([connector_w_mm, connector_h_mm, connector_d_mm], center=true);
        }

        // Mounting holes on front face (through front plate only, not through whole body)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*mounting_hole_spacing_mm/2, sy*mounting_hole_spacing_mm/2,
                       body_length_mm/2 - front_face_thickness_mm/2 + overlap_mm])
                cylinder(d=mounting_hole_diameter_mm,
                         h=front_face_thickness_mm + 2*overlap_mm,
                         center=true);
        }

        // Optional shallow front recess ring to add face detail (doesn't break connectivity)
        translate([0, 0, body_length_mm/2 - front_face_thickness_mm + 0.6])
            cylinder(d=shaft_boss_diameter_mm + 6.0, h=1.2, center=true);
    }
}

stepper_motor();