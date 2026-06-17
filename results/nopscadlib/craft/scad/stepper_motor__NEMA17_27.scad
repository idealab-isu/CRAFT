// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
body_length = 26.5; //[13.25:53:0.1]
front_face_thickness = 2; //[1:4:0.1]
rear_cap_thickness = 2; //[1:4:0.1]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 20; //[10:40:0.1]
shaft_center_offset_x = 0; //[-5:5:0.1]
shaft_center_offset_y = 0; //[-5:5:0.1]
boss_diameter = 22; //[11:44:0.1]
boss_thickness = 2; //[1:5:0.1]
mount_hole_spacing = 31; //[15.5:62:0.1]
mount_hole_diameter = 3.2; //[1.6:6.4:0.1]
mount_hole_depth = 6; //[3:12:0.1]
corner_radius = 2; //[1:6:0.1]
eps = 0.5; //[0.2:2:0.1]
aux_plate_thickness = 2; //[1:6:0.1]
aux_plate_width = 42.3; //[21.15:84.6:0.1]
aux_plate_height = 20; //[10:40:0.1]
aux_plate_offset_y = 0; //[-30:30:0.1]
ttrack_pitch = 20; //[10:40:0.1]
ttrack_length = 60; //[30:120:0.1]
ttrack_hole_diameter = 5; //[2.5:10:0.1]
rail_pitch = 25; //[12.5:50:0.1]
rail_length = 75; //[37.5:150:0.1]
rail_hole_diameter = 4.5; //[2:9:0.1]
screw_shank_diameter = 3; //[1.5:6:0.1]
screw_length = 12; //[6:24:0.1]
screw_head_diameter = 6; //[3:12:0.1]
screw_head_height = 2.5; //[1:6:0.1]
washer_outer_diameter = 7; //[3.5:14:0.1]
washer_thickness = 1; //[0.5:3:0.1]
d_plug_width = 18; //[9:36:0.1]
d_plug_height = 10; //[5:20:0.1]
d_plug_depth = 8; //[4:16:0.1]
d_plug_offset_x = 0; //[-30:30:0.1]
d_plug_offset_y = 0; //[-30:30:0.1]
ttrack_insert_hole_diameter = 4; //[2:8:0.1]
ttrack_insert_spacing = 16; //[8:32:0.1]

// Connectivity overlap (1-2mm) to guarantee attachment
overlap = 1.5;

// Derived Z references (front face centered at z=0)
z_front_face_center = 0;
z_front_face_front  = z_front_face_center + front_face_thickness/2;
z_front_face_back   = z_front_face_center - front_face_thickness/2;

z_body_center = z_front_face_back - body_length/2 + overlap; // overlap into front face
z_body_front  = z_body_center + body_length/2;
z_body_back   = z_body_center - body_length/2;

z_rear_cap_center = z_body_back - rear_cap_thickness/2 + overlap; // overlap into body

z_aux_plate_center = z_front_face_front + aux_plate_thickness/2 - overlap; // overlap into front face

// --- FIX: add the missing/offset small vertical pin and ensure it is ATTACHED ---
// Place it on the top-right of the front face (as seen in top/bottom views),
// and embed it into the front face by 'overlap' so it cannot float.
pin_diameter = 4.5;
pin_height   = 10;
pin_offset_x =  face_width/2 - pin_diameter/2 - 2;  // near right edge, inside footprint
pin_offset_y =  face_width/2 - pin_diameter/2 - 2;  // near top edge, inside footprint
pin_z_center =  z_front_face_front + pin_height/2 - overlap; // overlaps into front face

// Modules
module motor_body() {
  color("Black")
    translate([0, 0, z_body_center])
      cube([face_width, face_width, body_length], center=true);
}

module front_face() {
  color("Black")
    translate([0, 0, z_front_face_center])
      cube([face_width, face_width, front_face_thickness], center=true);
}

module rear_cap_face() {
  color("Black")
    translate([0, 0, z_rear_cap_center])
      cube([face_width, face_width, rear_cap_thickness], center=true);
}

module shaft_boss_or_front_bearing_land() {
  color("Silver")
    translate([shaft_center_offset_x, shaft_center_offset_y,
               z_front_face_front + boss_thickness/2 - overlap])
      cylinder(r=boss_diameter/2, h=boss_thickness, center=true);
}

module output_shaft() {
  color("Silver")
    translate([shaft_center_offset_x, shaft_center_offset_y,
               (z_front_face_front + boss_thickness - overlap) + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
}

// FIXED: small vertical cylindrical pin/shaft on top-right, now physically attached
module aux_pin_top_right() {
  color("DimGray")
    translate([pin_offset_x, pin_offset_y, pin_z_center])
      cylinder(r=pin_diameter/2, h=pin_height, center=true);
}

// Mount holes should be CUT from the motor face/body, not added as floating solids
module mount_hole_pattern_cut() {
  for (x = [-1, 1], y = [-1, 1]) {
    translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2,
               z_front_face_center - mount_hole_depth/2])
      cylinder(r=mount_hole_diameter/2,
               h=mount_hole_depth + front_face_thickness + overlap*2,
               center=true);
  }
}

module aux_plate() {
  color("Silver")
    translate([0, aux_plate_offset_y, z_aux_plate_center])
      cube([aux_plate_width, aux_plate_height, aux_plate_thickness], center=true);
}

// These are HOLES in the aux plate; keep as cutters (not added solids)
module ttrack_hole_positions_cut() {
  for (i = [-1.5, -0.5, 0.5, 1.5]) {
    translate([0, aux_plate_offset_y + i * ttrack_pitch, z_aux_plate_center])
      cylinder(r=ttrack_hole_diameter/2, h=aux_plate_thickness + overlap*2, center=true);
  }
}

module rail_hole_positions_cut() {
  for (x = [-1, 0, 1]) {
    translate([x * rail_pitch, aux_plate_offset_y, z_aux_plate_center])
      cylinder(r=rail_hole_diameter/2, h=aux_plate_thickness + overlap*2, center=true);
  }
}

module ttrack_insert_hole_positions_cut() {
  for (x = [-0.5, 0.5]) {
    translate([x * ttrack_insert_spacing, aux_plate_offset_y + aux_plate_height/4, z_aux_plate_center])
      cylinder(r=ttrack_insert_hole_diameter/2, h=aux_plate_thickness + overlap*2, center=true);
  }
}

// Screw/washer: ensure they start inside the aux plate (overlap) so they are attached
module screw_and_washer() {
  color("DimGray") {
    // Place washer slightly embedded into aux plate
    translate([mount_hole_spacing/2, mount_hole_spacing/2,
               (z_aux_plate_center + aux_plate_thickness/2) - washer_thickness/2 - overlap])
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);

    // Screw shank starts inside aux plate and extends outward
    translate([mount_hole_spacing/2, mount_hole_spacing/2,
               (z_aux_plate_center + aux_plate_thickness/2) + screw_length/2 - overlap])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);

    // Screw head on top, with slight overlap into shank
    translate([mount_hole_spacing/2, mount_hole_spacing/2,
               (z_aux_plate_center + aux_plate_thickness/2) + screw_length + screw_head_height/2 - overlap])
      cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true);
  }
}

// D-plug: embed slightly into aux plate so it is attached
module d_plug_D() {
  color("Silver")
    translate([d_plug_offset_x, aux_plate_offset_y + d_plug_offset_y,
               (z_aux_plate_center + aux_plate_thickness/2) + d_plug_depth/2 - overlap])
      cube([d_plug_width, d_plug_height, d_plug_depth], center=true);
}

// Assembly: single connected solid; holes are subtracted (no floating discs)
module assembly() {
  union() {
    // Motor (with mounting holes cut)
    difference() {
      union() {
        motor_body();
        front_face();
        rear_cap_face();
        shaft_boss_or_front_bearing_land();
        output_shaft();

        // FIX: add the small top-right pin and ensure it overlaps into the front face
        aux_pin_top_right();
      }
      mount_hole_pattern_cut();
    }

    // Aux plate (with its holes cut) + attached hardware/connectors
    union() {
      difference() {
        aux_plate();
        union() {
          ttrack_hole_positions_cut();
          rail_hole_positions_cut();
          ttrack_insert_hole_positions_cut();
        }
      }
      screw_and_washer();
      d_plug_D();
    }
  }
}

assembly();