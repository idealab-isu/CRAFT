// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
front_flange_diameter_mm = 90; //[45:180:1]
front_flange_thickness_mm = 6; //[3:12:0.5]
pilot_diameter_mm = 60; //[30:120:1]
pilot_length_mm = 2; //[1:6:0.5]
shaft_diameter_mm = 19; //[9.5:38:0.5]
shaft_length_mm = 40; //[20:80:1]
shaft_key_width_mm = 6; //[3:12:0.5]
shaft_key_depth_mm = 2.8; //[1.4:5.6:0.1]
shaft_key_length_mm = 25; //[10:60:1]
mount_hole_diameter_mm = 6.6; //[3.3:13.2:0.1]
mount_hole_square_pitch_mm = 70; //[35:140:1]
rear_endcap_thickness_mm = 6; //[3:15:0.5]
rear_endcap_diameter_mm = 78; //[39:156:1]
rear_connector_width_mm = 30; //[15:60:1]
rear_connector_height_mm = 18; //[9:36:1]
rear_connector_length_mm = 20; //[10:50:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 96;

// Servo Motor - complete geometry (ONE connected solid)
module servo_motor() {

  // Derived dims (keep formulas, no arbitrary placement)
  body_r_mm = min(body_width_mm, body_height_mm)/2;

  // Faceplate / flange features (typical servo motor look)
  flange_flat_w_mm = body_width_mm;                 // flats align with body
  flange_flat_h_mm = body_height_mm;
  flange_round_r_mm = front_flange_diameter_mm/2;

  // Small front boss around shaft (visual detail)
  boss_d_mm = max(shaft_diameter_mm*1.8, pilot_diameter_mm*0.55);
  boss_h_mm = max(2, front_flange_thickness_mm*0.55);

  // Rear endcap ring detail
  rear_ring_outer_d_mm = rear_endcap_diameter_mm;
  rear_ring_inner_d_mm = max(rear_endcap_diameter_mm - 10, rear_endcap_diameter_mm*0.78);

  // Connector placement: on rear face, offset to one side (cable outlet)
  conn_x_off_mm = body_width_mm/2 - rear_connector_width_mm/2 + overlap_mm; // touches side
  conn_z_center_mm = -body_length_mm/2 - rear_connector_length_mm/2 + overlap_mm; // touches rear face

  color([0.15, 0.2, 0.35])
  union() {
    difference() {
      union() {
        // --- Main body: cylindrical with two flats (servo-like silhouette) ---
        intersection() {
          cylinder(r=body_r_mm, h=body_length_mm, center=true);
          cube([body_width_mm, body_height_mm, body_length_mm + 2*overlap_mm], center=true);
        }

        // --- Front flange / faceplate: round with flats, connected to body ---
        translate([0, 0, body_length_mm/2 + front_flange_thickness_mm/2 - overlap_mm])
          union() {
            intersection() {
              cylinder(r=flange_round_r_mm, h=front_flange_thickness_mm, center=true);
              cube([flange_flat_w_mm, flange_flat_h_mm, front_flange_thickness_mm + 2*overlap_mm], center=true);
            }

            // Small boss around shaft (adds recognizable face detail)
            translate([0, 0, front_flange_thickness_mm/2 + boss_h_mm/2 - overlap_mm])
              cylinder(r=boss_d_mm/2, h=boss_h_mm, center=true);
          }

        // --- Front pilot (register) connected to flange ---
        translate([0, 0, body_length_mm/2 + front_flange_thickness_mm + pilot_length_mm/2 - overlap_mm])
          cylinder(r=pilot_diameter_mm/2, h=pilot_length_mm, center=true);

        // --- Output shaft connected to pilot/flange ---
        translate([0, 0, body_length_mm/2 + front_flange_thickness_mm + shaft_length_mm/2 - overlap_mm])
          cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);

        // --- Rear endcap: ring + center cap (adds rear detail), connected to body ---
        translate([0, 0, -body_length_mm/2 - rear_endcap_thickness_mm/2 + overlap_mm])
          union() {
            // Outer cap
            cylinder(r=rear_endcap_diameter_mm/2, h=rear_endcap_thickness_mm, center=true);

            // Raised ring detail (slightly proud)
            translate([0, 0, rear_endcap_thickness_mm/2 - (rear_endcap_thickness_mm*0.35)/2 - overlap_mm])
              difference() {
                cylinder(r=rear_ring_outer_d_mm/2, h=rear_endcap_thickness_mm*0.35, center=true);
                cylinder(r=rear_ring_inner_d_mm/2, h=rear_endcap_thickness_mm*0.35 + 2*overlap_mm, center=true);
              }
          }

        // --- Rear connector / cable outlet: attached to rear face and side ---
        translate([conn_x_off_mm, 0, conn_z_center_mm])
          cube([rear_connector_width_mm, rear_connector_height_mm, rear_connector_length_mm], center=true);
      }

      // --- Subtractions: mounting holes + shaft keyway ---

      // Mount holes through front flange (bolt pattern)
      for (x = [-1, 1], y = [-1, 1]) {
        translate([
          x * mount_hole_square_pitch_mm/2,
          y * mount_hole_square_pitch_mm/2,
          body_length_mm/2 + front_flange_thickness_mm/2 - overlap_mm
        ])
          cylinder(
            r=mount_hole_diameter_mm/2,
            h=front_flange_thickness_mm + 2*overlap_mm,
            center=true
          );
      }

      // Optional center relief on faceplate (visual cue)
      translate([0, 0, body_length_mm/2 + front_flange_thickness_mm/2 - overlap_mm])
        cylinder(r=pilot_diameter_mm/2 + 1, h=front_flange_thickness_mm*0.6, center=true);

      // Shaft keyway (cut into shaft)
      translate([
        shaft_diameter_mm/2 - shaft_key_depth_mm/2,
        0,
        body_length_mm/2 + front_flange_thickness_mm + shaft_key_length_mm/2 - overlap_mm
      ])
        cube([shaft_diameter_mm, shaft_key_width_mm, shaft_key_length_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();