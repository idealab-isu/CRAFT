// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
body_length = 47; //[23.5:94:0.1]
body_depth = 40; //[20:80:0.1]
body_height = 40; //[20:80:0.1]
front_face_thickness = 3; //[1.5:6:0.1]
rear_cap_thickness = 2.5; //[1.25:5:0.1]
corner_radius = 2; //[1:4:0.1]
boss_diameter = 22; //[11:44:0.1]
boss_height = 2; //[1:4:0.1]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 20; //[10:40:0.1]
mount_hole_spacing = 31; //[15.5:62:0.1]
mount_hole_diameter = 3.2; //[1.6:6.4:0.1]
mount_hole_depth = 6; //[3:12:0.1]
eps_overlap = 1; //[0.5:2:0.1]
dplug_length = 18; //[9:36:0.1]
dplug_width = 12; //[6:24:0.1]
dplug_rad = 2; //[1:4:0.1]
dplug_thickness = 2; //[1:4:0.1]
grill_hole_diameter = 3; //[1.5:6:0.1]
grill_margin = 6; //[3:12:0.1]
ttrack_hole_diameter = 4; //[2:8:0.1]
rail_hole_diameter = 4; //[2:8:0.1]
screw_shank_diameter = 3; //[1.5:6:0.1]
screw_length = 10; //[5:20:0.1]
washer_diameter = 7; //[3.5:14:0.1]
washer_thickness = 1; //[0.5:2:0.1]

// Added: rear electrical connector/pins (and ensured attachment)
pin_diameter = 1.2;
pin_length = 6;
pin_spacing = 2.54;
pin_count = 4;
pin_block_w = (pin_count-1)*pin_spacing + 3.0;  // small housing width
pin_block_h = 4.0;
pin_block_t = 4.0; // thickness along X (sticks out of rear)
pin_z_offset = -body_height/2 + 6; // near bottom like typical motors

// Convenience: rear face X position of the rear cap (outermost)
rear_face_x = front_face_thickness/2 + body_length + rear_cap_thickness/2;

// NEMA-style stepper motor
module NEMA_motor() {
  // Motor body
  color("Black")
  union() {
    translate([front_face_thickness/2 + body_length/2 - eps_overlap, 0, 0])
      cube([body_length, body_depth, body_height], center=true);

    // Front face
    translate([0, 0, 0])
      cube([front_face_thickness, face_width, face_width], center=true);

    // Rear cap
    translate([rear_face_x - eps_overlap, 0, 0])
      cube([rear_cap_thickness, face_width, face_width], center=true);

    // Shaft center boss
    translate([-front_face_thickness/2 - boss_height/2 + eps_overlap, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=boss_diameter/2, h=boss_height, center=true);

    // Output shaft
    color("Silver")
    translate([-front_face_thickness/2 - shaft_length/2 + eps_overlap, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
}

// Rear electrical connector/pins (physically attached with overlap into rear cap)
module rear_connector_and_pins() {
  // Place connector so it intersects the rear cap by eps_overlap (1-2mm)
  // Rear cap outer face is at: rear_face_x + rear_cap_thickness/2
  // We want the connector block to start inside the cap by eps_overlap.
  conn_center_x =
    (rear_face_x + rear_cap_thickness/2) + (pin_block_t/2) - eps_overlap;

  // Put it near one side/bottom like typical NEMA motors
  conn_center_y = -face_width/2 + pin_block_w/2 + 6;

  union() {
    // Small housing block (grey)
    color("DimGray")
      translate([conn_center_x, conn_center_y, pin_z_offset])
        cube([pin_block_t, pin_block_w, pin_block_h], center=true);

    // Pins (orange) protruding further out, but rooted inside the housing
    // Ensure each pin overlaps into the housing by eps_overlap.
    color("Orange")
      for (i = [0:pin_count-1]) {
        y_i = conn_center_y + (i - (pin_count-1)/2) * pin_spacing;
        translate([
          conn_center_x + pin_block_t/2 + pin_length/2 - eps_overlap,
          y_i,
          pin_z_offset
        ])
          rotate([0, 90, 0])
          cylinder(r=pin_diameter/2, h=pin_length, center=true, $fn=24);
      }
  }
}

// D Plug D (kept, but ensured it intersects the body slightly)
module d_plug_D() {
  // Attach to rear area and overlap into the rear cap/body by eps_overlap
  plug_center_x =
    (rear_face_x - rear_cap_thickness/2) + (dplug_thickness/2) - eps_overlap;

  color("DimGray")
    translate([plug_center_x, 0, -body_height/2 + dplug_thickness/2 - eps_overlap])
      rotate([0, 90, 0])
      linear_extrude(height=dplug_thickness, center=true)
      offset(r=dplug_rad)
      square([dplug_length, dplug_width], center=true);
}

// Grill Hole Positions (cutters)
module grill_hole_positions() {
  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([rear_face_x, x * (face_width/2 - grill_margin), y * (face_width/2 - grill_margin)])
        rotate([0, 90, 0])
        cylinder(r=grill_hole_diameter/2, h=rear_cap_thickness + 2*eps_overlap, center=true);
}

// Screw and Washer (kept as-is; these are external hardware, but unioned)
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([front_face_thickness/2 - screw_length/2 + eps_overlap, mount_hole_spacing/2, mount_hole_spacing/2])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
    // Washer
    translate([-front_face_thickness/2 + washer_thickness/2 - eps_overlap, mount_hole_spacing/2, mount_hole_spacing/2])
      rotate([0, 90, 0])
      cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
  }
}

// Ttrack Hole Positions (cutters)
module ttrack_hole_positions() {
  for (z = [-1, 1])
    translate([front_face_thickness/2 + body_length/2, 0, z * (body_height/2 - ttrack_hole_diameter/2 - eps_overlap)])
      rotate([90, 0, 0])
      cylinder(r=ttrack_hole_diameter/2, h=body_depth + 2*eps_overlap, center=true);
}

// Rail Hole Positions (cutters)
module rail_hole_positions() {
  for (y = [-1, 1])
    translate([front_face_thickness/2 + body_length/2, y * (body_depth/2 - rail_hole_diameter/2 - eps_overlap), 0])
      cylinder(r=rail_hole_diameter/2, h=body_height + 2*eps_overlap, center=true);
}

// Assembly
module assembly() {
  difference() {
    union() {
      // Single connected solid for the motor + attached rear connector
      union() {
        NEMA_motor();
        rear_connector_and_pins(); // FIX: now intersects rear cap by eps_overlap
        d_plug_D();                // ensured overlap into rear cap/body
      }
      // External hardware (kept)
      screw_and_washer();
    }

    union() {
      // Mounting holes
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([front_face_thickness/2 - (mount_hole_depth + front_face_thickness)/2, x * mount_hole_spacing/2, y * mount_hole_spacing/2])
            rotate([0, 90, 0])
            cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + front_face_thickness + 2*eps_overlap, center=true);

      grill_hole_positions();
      ttrack_hole_positions();
      rail_hole_positions();
    }
  }
}

assembly();