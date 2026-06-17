// Stepper motor (NEMA17-ish) simplified solid model
// Target: 42.3mm face width, 26.5mm body length, 5.0mm shaft diameter, 31.0mm mounting hole spacing
$fn = 96;

// Parameters
face_width = 42.3;                 //[21.15:84.6:0.1]
body_length = 26.5;                //[13.25:53:0.1]
shaft_diameter = 5.0;              //[2.5:10:0.1]
mounting_hole_spacing = 31.0;      //[15.5:62:0.1]
mounting_hole_diameter = 3.5;      //[2:7:0.1]

shaft_length = 20;                 //[10:40:0.1]
corner_radius = 2;                 //[0.5:6:0.1]
front_face_thickness = 3;          //[1.5:6:0.1]

shaft_boss_diameter = 22;          //[11:44:0.1]
shaft_boss_height = 2;             //[1:6:0.1]

front_face_recess_diameter = 24;   //[12:48:0.1]
front_face_recess_depth = 0.8;     //[0.3:2:0.1]

overlap = 0.6;                     //[0.2:2:0.1]

// Helpers
module rounded_square_prism(w, h, r, center=true) {
  // 2D rounded square extruded to height h
  linear_extrude(height=h, center=center)
    offset(r=r)
      square([w - 2*r, w - 2*r], center=true);
}

module motor() {
  // Coordinate convention:
  // Front face outer surface at z = 0
  // Body extends to negative z
  // Shaft extends to positive z

  difference() {
    union() {
      // Main body (rounded corners), connected to front face
      translate([0, 0, -(body_length/2 + front_face_thickness - overlap)])
        rounded_square_prism(face_width, body_length, corner_radius, center=true);

      // Front face plate
      translate([0, 0, -front_face_thickness/2])
        cube([face_width, face_width, front_face_thickness], center=true);

      // Shaft boss (front)
      translate([0, 0, shaft_boss_height/2 - overlap])
        cylinder(d=shaft_boss_diameter, h=shaft_boss_height, center=true);

      // Output shaft (5.0mm diameter), connected to boss
      translate([0, 0, shaft_boss_height - overlap + shaft_length/2])
        cylinder(d=shaft_diameter, h=shaft_length, center=true);
    }

    // Front face recess (shallow ring/spotface)
    translate([0, 0, -(front_face_recess_depth/2) - overlap/2])
      cylinder(d=front_face_recess_diameter, h=front_face_recess_depth + overlap, center=true);

    // Mounting through-holes (31mm spacing), through face + a bit into body
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2,
                   -(front_face_thickness + overlap)/2])
          cylinder(d=mounting_hole_diameter,
                   h=front_face_thickness + 2*overlap,
                   center=true);
  }
}

motor();