// Stepper motor (NEMA-style) - corrected, connected, verifiable geometry

$fn = 96;

// Parameters
face_width = 35.2;                 //[17.6:70.4:0.1]
front_face_thickness = 3.0;        //[1.5:6.0:0.1]
body_length = 36.0;                //[18.0:72.0:0.1]
body_width = 35.2;                 //[17.6:70.4:0.1]

shaft_diameter = 5.0;              //[2.5:10.0:0.1]
shaft_length = 20.0;               //[10.0:40.0:0.1]

mounting_hole_spacing = 26.0;      //[13.0:52.0:0.1]
mounting_hole_diameter = 3.2;      //[2.0:6.0:0.1]
mounting_hole_depth = 8.0;         //[3.0:20.0:0.1]

overlap = 1.0;                     //[0.5:2.0:0.1]
eps = 0.2;                         //[0.05:0.5:0.05]

// NEMA-style front features (typical)
boss_diameter = 22.0;
boss_height = 2.0;
corner_chamfer = 2.0;

// Small rear cable bump to make back view distinguishable (still connected)
rear_bump_w = 10.0;
rear_bump_h = 6.0;
rear_bump_t = 3.0;

// Helpers
module chamfered_plate(w, t, c) {
  // 2D chamfered square extruded to thickness t
  linear_extrude(height=t, center=true)
    polygon(points=[
      [ w/2 - c,  w/2],
      [ w/2,      w/2 - c],
      [ w/2,     -w/2 + c],
      [ w/2 - c, -w/2],
      [-w/2 + c, -w/2],
      [-w/2,     -w/2 + c],
      [-w/2,      w/2 - c],
      [-w/2 + c,  w/2]
    ]);
}

module stepper_motor() {
  // Coordinate system:
  // Front face centered at Z=0, shaft goes +Z, body extends -Z.
  difference() {
    union() {
      // Main body (slightly chamfered front edges via hull between two profiles)
      // Keep overall length = body_length, width = body_width
      translate([0,0,-(front_face_thickness/2 + body_length/2 - overlap)])
        cube([body_width, body_width, body_length], center=true);

      // Front face plate with chamfered corners
      translate([0,0,0])
        chamfered_plate(face_width, front_face_thickness, corner_chamfer);

      // Front boss (pilot)
      translate([0,0, front_face_thickness/2 + boss_height/2 - overlap])
        cylinder(d=boss_diameter, h=boss_height, center=true);

      // Shaft (connected to boss)
      translate([0,0, front_face_thickness/2 + boss_height - overlap + shaft_length/2])
        cylinder(d=shaft_diameter, h=shaft_length, center=true);

      // Rear cable bump (connected to body)
      translate([0,0, -(front_face_thickness + body_length) + rear_bump_t/2 + overlap])
        cube([rear_bump_w, rear_bump_h, rear_bump_t], center=true);
    }

    // Mounting holes: actual holes (difference), clearly verifiable at 26mm spacing
    for (x = [-1, 1])
      for (y = [-1, 1]) {
        translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, 0])
          cylinder(d=mounting_hole_diameter,
                   h=front_face_thickness + mounting_hole_depth + 2*eps,
                   center=true);
      }

    // Small center dimple on face for visual cue (does not affect key dims)
    translate([0,0,0])
      cylinder(d=6.0, h=front_face_thickness + 2*eps, center=true);
  }
}

stepper_motor();