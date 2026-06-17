// Stepper motor (NEMA-like mini) - corrected for:
// - 20.0mm face width
// - 30.0mm body length
// - 4.0mm shaft diameter (centered)
// - 16.0mm mounting hole spacing (visible corner holes on face)
// - One connected solid (all parts overlap slightly)
// - No arbitrary translate values (all derived from dimensions)

$fn = 96;

// Parameters
face_width = 20.0;                 //[10.0:40.0:0.5]
body_length = 30.0;                //[15.0:60.0:0.5]
front_face_thickness = 2.0;        //[1.0:6.0:0.25]
shaft_diameter = 4.0;              //[2.0:10.0:0.25]
shaft_length = 12.0;               //[6.0:30.0:0.5]
mount_hole_spacing = 16.0;         //[8.0:32.0:0.5]
mount_hole_diameter = 3.0;         //[1.5:6.0:0.25]
boss_diameter = 10.0;              //[6.0:20.0:0.5]
boss_thickness = 2.0;              //[1.0:6.0:0.25]
rear_cap_thickness = 2.0;          //[1.0:6.0:0.25]
fillet_radius = 1.0;               //[0.5:4.0:0.25]
label_plate_thickness = 0.8;       //[0.4:2.0:0.1]
label_plate_width = 14.0;          //[7.0:28.0:0.5]
label_plate_height = 8.0;          //[4.0:16.0:0.5]
connector_width = 8.0;             //[4.0:16.0:0.5]
connector_height = 6.0;            //[3.0:12.0:0.5]
connector_depth = 6.0;             //[3.0:15.0:0.5]
shaft_flat_depth = 0.6;            //[0.2:1.5:0.05]
shaft_flat_length = 8.0;           //[3.0:20.0:0.5]
overlap = 0.6;                     //[0.2:2.0:0.1]

// Derived Z positions (centered body at origin)
z_body_front =  body_length/2;
z_body_back  = -body_length/2;

z_front_face_c = z_body_front + front_face_thickness/2 - overlap;
z_boss_c       = z_body_front + front_face_thickness + boss_thickness/2 - overlap;
z_shaft_c      = z_body_front + front_face_thickness + boss_thickness + shaft_length/2 - overlap;

z_rear_cap_c   = z_body_back - rear_cap_thickness/2 + overlap;

// Helpers
module rounded_body(w, l, r) {
  // Rounded edges via minkowski; keep r modest to avoid bloating too much.
  minkowski() {
    cube([w - 2*r, w - 2*r, l - 2*r], center=true);
    sphere(r=r);
  }
}

module front_face_plate() {
  translate([0, 0, z_front_face_c])
    cube([face_width, face_width, front_face_thickness], center=true);
}

module front_boss() {
  translate([0, 0, z_boss_c])
    cylinder(d=boss_diameter, h=boss_thickness, center=true);
}

module output_shaft() {
  translate([0, 0, z_shaft_c])
    cylinder(d=shaft_diameter, h=shaft_length, center=true);
}

module shaft_flat_cutter() {
  // Cut a flat on +X side of shaft; cutter overlaps shaft lengthwise.
  translate([shaft_diameter/2 - shaft_flat_depth/2, 0,
             z_body_front + front_face_thickness + boss_thickness + shaft_flat_length/2 - overlap])
    cube([shaft_diameter, shaft_diameter, shaft_flat_length + 2*overlap], center=true);
}

module rear_cap() {
  translate([0, 0, z_rear_cap_c])
    cube([face_width, face_width, rear_cap_thickness], center=true);
}

module label_plate() {
  // On +Y side; overlap into body to ensure connectivity
  translate([0, face_width/2 + label_plate_thickness/2 - overlap, 0])
    cube([label_plate_width, label_plate_thickness, label_plate_height], center=true);
}

module wiring_connector() {
  // On -Y side near rear; overlap into body
  translate([0,
             -face_width/2 - connector_height/2 + overlap,
             z_body_back + connector_depth/2 + overlap])
    cube([connector_width, connector_height, connector_depth], center=true);
}

module mount_hole_at(x, y) {
  // Drill through front face plate (and slightly into boss region for visibility/robustness)
  translate([x, y, z_front_face_c])
    cylinder(d=mount_hole_diameter,
             h=front_face_thickness + boss_thickness + 4*overlap,
             center=true);
}

module mounting_holes() {
  // 16mm spacing => holes at +/-8mm in X and Y
  for (sx = [-1, 1], sy = [-1, 1])
    mount_hole_at(sx*mount_hole_spacing/2, sy*mount_hole_spacing/2);
}

module front_assembly_with_holes() {
  difference() {
    union() {
      front_face_plate();
      front_boss();
    }
    mounting_holes();
  }
}

module shaft_with_flat() {
  difference() {
    output_shaft();
    shaft_flat_cutter();
  }
}

// Final connected motor
module motor() {
  union() {
    // Main body (rounded)
    rounded_body(face_width, body_length, fillet_radius);

    // Rear cap (overlaps into body)
    rear_cap();

    // Front face + boss with mounting holes (overlaps into body)
    front_assembly_with_holes();

    // Shaft (centered on face)
    shaft_with_flat();

    // Side details (overlap into body)
    label_plate();
    wiring_connector();
  }
}

motor();