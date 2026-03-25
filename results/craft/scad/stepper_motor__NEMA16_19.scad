$fn = 96;

// Target critical dimensions (mm)
face_width = 39.5;          // square face width
body_length = 19.2;         // motor body length (excluding shaft protrusion)
shaft_diameter = 5.0;       // shaft diameter
mount_hole_spacing = 31.0;  // center-to-center spacing (square pattern)

// Additional typical NEMA-style features (kept reasonable, not critical)
face_thickness = 3.0;
rear_cap_thickness = 2.5;

mount_hole_diameter = 3.5;

shaft_length = 20.0;
shaft_boss_diameter = 22.0;
shaft_boss_height = 2.0;

d_plug_flat_depth = 0.6;

corner_radius = 4.0;        // rounded body corners
endbell_inset = 0.8;        // slight step between endbells and main body
endbell_radius = corner_radius + 1.2;

overlap = 0.6;              // overlap to ensure watertight unions

// Derived
hole_x = mount_hole_spacing/2;
hole_y = mount_hole_spacing/2;

body_w = face_width;        // keep body same width as face for verifiable 39.5mm

// Z layout: front face centered at z=0
z_face_center = 0;
z_face_front  = z_face_center + face_thickness/2;
z_face_back   = z_face_center - face_thickness/2;

z_body_center = z_face_back - body_length/2 + overlap;
z_body_back   = z_face_back - body_length + overlap;

z_rear_center = z_body_back - rear_cap_thickness/2 + overlap;

z_boss_center  = z_face_front + shaft_boss_height/2 - overlap;
z_shaft_center = z_face_front + shaft_length/2 - overlap;

// Helpers
module rounded_square_prism(w, h, r, center=true) {
  // 2D rounded square extruded to height h
  linear_extrude(height=h, center=center)
    offset(r=r)
      square([w-2*r, w-2*r], center=true);
}

module endbell_prism(w, h, r, inset) {
  // Slightly inset endbell with a bit more rounding
  rounded_square_prism(w - 2*inset, h, r, center=true);
}

module stepper_motor_connected() {
  union() {
    // Main motor solids with holes removed
    difference() {
      union() {
        // Main body (rounded NEMA-style)
        translate([0, 0, z_body_center])
          rounded_square_prism(body_w, body_length, corner_radius, center=true);

        // Front endbell (slight step)
        translate([0, 0, z_face_center])
          endbell_prism(face_width, face_thickness, endbell_radius, endbell_inset);

        // Rear endbell/cap (slight step)
        translate([0, 0, z_rear_center])
          endbell_prism(face_width, rear_cap_thickness, endbell_radius, endbell_inset);

        // Shaft boss (front)
        translate([0, 0, z_boss_center])
          cylinder(d=shaft_boss_diameter, h=shaft_boss_height, center=true);
      }

      // 4x mounting holes through the front face plate only (31mm spacing)
      for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*hole_x, sy*hole_y, z_face_center])
          cylinder(d=mount_hole_diameter, h=face_thickness + 2*overlap, center=true);
      }
    }

    // Shaft with D-flat, connected into boss/face by overlap
    difference() {
      translate([0, 0, z_shaft_center])
        cylinder(d=shaft_diameter, h=shaft_length, center=true);

      // D-flat cut
      translate([shaft_diameter/2 - d_plug_flat_depth/2, 0, z_shaft_center])
        cube([shaft_diameter, shaft_diameter*2, shaft_length + 4*overlap], center=true);
    }
  }
}

stepper_motor_connected();