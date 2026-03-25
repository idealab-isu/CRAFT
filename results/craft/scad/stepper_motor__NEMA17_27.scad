// NEMA-style stepper motor (single connected solid)
// Target: 42.3mm face width, 26.5mm body length, 5.0mm shaft dia, 31.0mm mounting hole spacing

// Parameters
face_width = 42.3;                 //[21.15:84.6:0.1]
body_length = 26.5;                //[13.25:53:0.1]
front_face_thickness = 3.5;        //[1.75:7:0.1]

shaft_diameter = 5.0;              //[2.5:10:0.1]
shaft_length = 20;                 //[10:40:0.1]
shaft_shoulder_diameter = 8;       //[4:16:0.1]
shaft_shoulder_height = 2;         //[1:6:0.1]

pilot_boss_diameter = 22;          //[11:44:0.1]
pilot_boss_height = 2;             //[1:6:0.1]

mounting_hole_spacing = 31.0;      //[15.5:62:0.1]
mounting_hole_diameter = 3.2;      //[2:6:0.1]

// Rear feature (simple connector boss)
rear_boss_diameter = 16;           //[5:25:0.1]
rear_boss_height = 3;              //[1:8:0.1]

// Corner chamfer approximation (typical NEMA look)
corner_cut = 4;                    //[0:8:0.1]

// Front face details (to read as NEMA17 in ortho views)
face_recess_depth = 0.8;           //[0:2:0.1]
face_recess_margin = 3.0;          //[0:8:0.1]
mount_dimple_depth = 1.2;          //[0.2:2.5:0.1]

$fn = 96;
eps = 0.25;

// Derived
body_w = face_width;
body_h = face_width;

z_front = 0; // frontmost plane of the face plate
z_face_center = z_front - front_face_thickness/2;
z_body_center = z_front - front_face_thickness - body_length/2;
z_back = z_front - front_face_thickness - body_length;

// Helper: chamfered square prism (via subtracting corner cubes)
module chamfered_prism(w, h, l, cut) {
    difference() {
        cube([w, h, l], center=true);
        if (cut > 0) {
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(w/2 - cut/2), sy*(h/2 - cut/2), 0])
                    cube([cut, cut, l + 2*eps], center=true);
            }
        }
    }
}

// Main motor (ONE connected solid; holes are recessed dimples, not through-holes)
module nema_stepper() {

    // Clamp details so they always remain within the face thickness
    dimple_depth = min(mount_dimple_depth, front_face_thickness - 0.6);
    recess_depth = min(face_recess_depth, front_face_thickness - 0.6);

    // Ensure recess stays inside the face outline
    recess_w = max(0.1, face_width - 2*face_recess_margin);

    union() {
        // Body (behind face)
        translate([0, 0, z_body_center])
            chamfered_prism(body_w, body_h, body_length, corner_cut);

        // Front face plate with recessed panel + mounting dimples (difference keeps one solid)
        translate([0, 0, z_face_center])
        difference() {
            cube([face_width, face_width, front_face_thickness], center=true);

            // Recessed square panel to make front face readable in ortho views
            translate([0, 0, front_face_thickness/2 - recess_depth/2 + eps])
                cube([recess_w, recess_w, recess_depth], center=true);

            // Mounting hole dimples at 31mm spacing (center-to-center)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*mounting_hole_spacing/2,
                           sy*mounting_hole_spacing/2,
                           front_face_thickness/2 - dimple_depth/2 + eps])
                    cylinder(d=mounting_hole_diameter, h=dimple_depth, center=true);
            }
        }

        // Front pilot boss (protrudes forward, connected with slight overlap)
        translate([0, 0, z_front + pilot_boss_height/2 - eps])
            cylinder(d=pilot_boss_diameter, h=pilot_boss_height, center=true);

        // Shaft shoulder (protrudes forward, connected with slight overlap)
        translate([0, 0, z_front + shaft_shoulder_height/2 - eps])
            cylinder(d=shaft_shoulder_diameter, h=shaft_shoulder_height, center=true);

        // Shaft (protrudes forward, connected with slight overlap)
        translate([0, 0, z_front + shaft_length/2 - eps])
            cylinder(d=shaft_diameter, h=shaft_length, center=true);

        // Rear connector/boss (protrudes backward, connected with slight overlap)
        translate([0, 0, z_back - rear_boss_height/2 + eps])
            cylinder(d=rear_boss_diameter, h=rear_boss_height, center=true);

        // Rear "cap" ring to break the flat silhouette in back/side views (still connected)
        rear_ring_d = min(face_width - 6, 36);
        rear_ring_h = 1.2;
        translate([0, 0, z_back + rear_ring_h/2 + eps])
            cylinder(d=rear_ring_d, h=rear_ring_h, center=true);
    }
}

nema_stepper();