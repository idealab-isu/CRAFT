$fn = 96;

// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
flange_thickness_mm = 6; //[3:12:1]
rear_cap_thickness_mm = 8; //[4:16:1]
pilot_diameter_mm = 55; //[30:110:1]
pilot_height_mm = 2.5; //[1:6:0.5]
shaft_diameter_mm = 19; //[8:38:1]
shaft_length_mm = 40; //[15:80:1]
shaft_flat_depth_mm = 1.0; //[0.5:3.0:0.1]
shaft_flat_length_mm = 25; //[10:60:1]
mount_hole_diameter_mm = 6.5; //[3:13:0.5]
mount_hole_pitch_square_mm = 65; //[40:120:1]
connector_width_mm = 30; //[15:60:1]
connector_height_mm = 18; //[8:36:1]
connector_depth_mm = 14; //[6:28:1]
connector_side_offset_mm = 18; //[0:40:1]
overlap_mm = 1; //[0.5:2:0.5]

// Derived / additional feature parameters (kept proportional to frame size)
corner_r_mm = motor_frame_size_mm * 0.06;                 // body corner radius
flange_overhang_mm = motor_frame_size_mm * 0.10;          // flange larger than body
flange_size_mm = motor_frame_size_mm + 2*flange_overhang_mm;

boss_diameter_mm = motor_frame_size_mm * 0.22;            // front bolt bosses
boss_height_mm = flange_thickness_mm * 0.55;

rear_bulge_d_mm = motor_frame_size_mm * 0.62;             // rear cover bulge
rear_bulge_h_mm = rear_cap_thickness_mm * 0.70;

rear_rim_d_mm = motor_frame_size_mm * 0.78;               // rear rim ring
rear_rim_h_mm = rear_cap_thickness_mm * 0.35;

key_diameter_mm = shaft_diameter_mm * 0.55;               // small key/encoder stub on shaft
key_height_mm = shaft_length_mm * 0.18;

connector_fillet_mm = min(connector_width_mm, connector_height_mm) * 0.12;

// Helpers
module rounded_box(size=[10,10,10], r=1, center=true) {
  // Minkowski rounded cube; keep r reasonable
  rr = max(0.01, min(r, min(size[0], min(size[1], size[2]))/2 - 0.01));
  minkowski() {
    cube([size[0]-2*rr, size[1]-2*rr, size[2]-2*rr], center=center);
    sphere(r=rr);
  }
}

module servo_motor() {
  color([0.15, 0.2, 0.35])
  union() {

    // Coordinate convention:
    // Front face of flange at z=0, motor extends to negative z.
    // Shaft extends to positive z.

    // --- Main body (rounded edges) ---
    translate([0,0,-body_length_mm/2 - flange_thickness_mm + overlap_mm])
      rounded_box([motor_frame_size_mm, motor_frame_size_mm, body_length_mm], r=corner_r_mm, center=true);

    // --- Front flange with mounting holes (holes are subtracted but solid remains connected) ---
    translate([0,0,-flange_thickness_mm/2 + overlap_mm/2])
      difference() {
        rounded_box([flange_size_mm, flange_size_mm, flange_thickness_mm], r=corner_r_mm*0.9, center=true);

        // Mounting holes (through flange)
        for (x = [-1, 1], y = [-1, 1])
          translate([x * mount_hole_pitch_square_mm/2, y * mount_hole_pitch_square_mm/2, 0])
            cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + 2*overlap_mm, center=true);

        // Slight front face recess around pilot (visual detail)
        cylinder(r=pilot_diameter_mm/2 + motor_frame_size_mm*0.03,
                 h=flange_thickness_mm*0.35 + 2*overlap_mm, center=true);
      }

    // --- Front bolt bosses (raised pads around holes) ---
    for (x = [-1, 1], y = [-1, 1])
      translate([x * mount_hole_pitch_square_mm/2, y * mount_hole_pitch_square_mm/2,
                 -flange_thickness_mm + boss_height_mm/2 + overlap_mm])
        difference() {
          cylinder(r=boss_diameter_mm/2, h=boss_height_mm, center=true);
          cylinder(r=mount_hole_diameter_mm/2, h=boss_height_mm + 2*overlap_mm, center=true);
        }

    // --- Front pilot (register) ---
    translate([0,0,pilot_height_mm/2 - overlap_mm/2])
      cylinder(r=pilot_diameter_mm/2, h=pilot_height_mm, center=true);

    // --- Output shaft with flat ---
    translate([0,0, pilot_height_mm + shaft_length_mm/2 - overlap_mm/2])
      difference() {
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

        // Flat: subtract a box that intersects the shaft along the first part of its length
        translate([shaft_diameter_mm/2 - shaft_flat_depth_mm + overlap_mm/2, 0,
                   -shaft_length_mm/2 + shaft_flat_length_mm/2 + overlap_mm])
          cube([shaft_diameter_mm*2, shaft_diameter_mm*2, shaft_flat_length_mm], center=true);
      }

    // --- Small key/encoder stub on shaft tip (servo-like detail) ---
    translate([0,0, pilot_height_mm + shaft_length_mm + key_height_mm/2 - overlap_mm/2])
      cylinder(r=key_diameter_mm/2, h=key_height_mm, center=true);

    // --- Rear cap (slightly inset) ---
    translate([0,0, -flange_thickness_mm - body_length_mm - rear_cap_thickness_mm/2 + overlap_mm/2])
      rounded_box([motor_frame_size_mm*0.98, motor_frame_size_mm*0.98, rear_cap_thickness_mm],
                  r=corner_r_mm*0.8, center=true);

    // --- Rear rim ring (cover detail) ---
    translate([0,0, -flange_thickness_mm - body_length_mm - rear_cap_thickness_mm + rear_rim_h_mm/2 + overlap_mm])
      difference() {
        cylinder(r=rear_rim_d_mm/2, h=rear_rim_h_mm, center=true);
        cylinder(r=rear_rim_d_mm/2 - motor_frame_size_mm*0.05, h=rear_rim_h_mm + 2*overlap_mm, center=true);
      }

    // --- Rear bulge (fan/encoder housing look) ---
    translate([0,0, -flange_thickness_mm - body_length_mm - rear_cap_thickness_mm - rear_bulge_h_mm/2 + overlap_mm/2])
      cylinder(r=rear_bulge_d_mm/2, h=rear_bulge_h_mm, center=true);

    // --- Connector block (attached to rear cap area, not floating) ---
    // Place it on the side of the rear cap, centered in Z within connector depth.
    translate([
        motor_frame_size_mm/2 + connector_width_mm/2 - overlap_mm,                 // touches body side
        connector_side_offset_mm,                                                  // user offset along Y
        -flange_thickness_mm - body_length_mm - rear_cap_thickness_mm - connector_depth_mm/2 + overlap_mm
      ])
      rounded_box([connector_width_mm, connector_height_mm, connector_depth_mm],
                  r=connector_fillet_mm, center=true);

    // --- Small strain-relief nub on connector (extra recognizable detail, connected) ---
    translate([
        motor_frame_size_mm/2 + connector_width_mm - connector_fillet_mm - overlap_mm, // on outer face of connector
        connector_side_offset_mm,
        -flange_thickness_mm - body_length_mm - rear_cap_thickness_mm - connector_depth_mm*0.55 + overlap_mm
      ])
      rotate([0,90,0])
        cylinder(r=min(connector_height_mm, connector_depth_mm)*0.18,
                 h=connector_width_mm*0.35, center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();