// IEC C14 power inlet module (ATX style) - 40.0mm x 27.0mm face
// One connected solid (inlet + flange + rear boss + terminals)
// No floating parts; all translate() values derived from dimensions.

$fn = 96;

// -------------------- Parameters --------------------
target_width_mm  = 40;   //[20:80:0.5]   // overall face width
target_height_mm = 27;   //[13.5:54:0.5] // overall face height

panel_thickness_mm  = 2;   //[1:6:0.25]   // reference only
flange_thickness_mm = 3;   //[1.5:8:0.25]
bezel_radius_mm     = 3;   //[1:8:0.25]

screw_hole_diameter_mm = 3.2; //[2:6:0.1]
screw_hole_pitch_x_mm  = 32;  //[16:64:0.5]
screw_hole_pitch_y_mm  = 20;  //[10:40:0.5]

inlet_depth_mm   = 30;  //[15:60:0.5]   // depth behind panel
body_width_mm    = 30;  //[20:50:0.5]   // main body width behind flange
body_height_mm   = 22;  //[14:40:0.5]   // main body height behind flange

// IEC C14 face opening (approximate, recognizable)
face_open_w_mm = 27.5;  //[20:32:0.25]
face_open_h_mm = 19.5;  //[14:24:0.25]
face_open_r_mm = 2.2;   //[0.5:5:0.1]
face_recess_depth_mm = 2.2; //[1:5:0.1] // recessed pocket depth

// Keyed notch at top center (C14 key)
key_notch_w_mm = 10.0;  //[6:14:0.25]
key_notch_h_mm = 2.2;   //[1:4:0.1]

// Pin cavities (3-pin)
pin_hole_d_mm = 4.2;     //[3:6:0.1]
pin_pitch_x_mm = 10.0;   //[8:14:0.25]   // L-N spacing
pin_pitch_y_mm = 7.0;    //[5:10:0.25]   // Earth above L/N
pin_hole_depth_mm = 10.0; //[4:18:0.25]

// Rear strain relief / cable clearance boss (connected)
strain_relief_clearance_diameter_mm = 18; //[10:30:0.5]
strain_relief_clearance_depth_mm    = 12; //[6:30:0.5]

// Rear terminals (spade tabs) - connected to body
tab_w_mm = 6.3;   //[4:10:0.1]
tab_t_mm = 0.8;   //[0.5:2:0.05]
tab_len_mm = 10;  //[6:20:0.5]
tab_spacing_x_mm = 10.0; //[8:14:0.25]
tab_spacing_y_mm = 7.0;  //[5:10:0.25]

overlap_mm = 1; //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
  }
}

module rounded_box(w, h, d, r, center=true) {
  linear_extrude(height=d, center=center)
    rounded_rect_2d(w, h, r);
}

// -------------------- IEC Inlet Solid --------------------
module iec_c14_inlet_solid() {

  // Coordinate convention:
  // Z=0 is panel plane center. Positive Z is "front/outside", negative Z is "rear/inside".
  // Flange sits on front side; body extends to rear.

  // Place flange so its back face slightly overlaps the panel plane (ensures connection)
  flange_zc = panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm;

  // Body: front face slightly overlaps the panel plane (ensures connection to flange region)
  body_zc = -panel_thickness_mm/2 - inlet_depth_mm/2 + overlap_mm;

  // Rear boss: front face overlaps rear face of body
  body_rear_face_z = body_zc - inlet_depth_mm/2;
  boss_zc = body_rear_face_z - strain_relief_clearance_depth_mm/2 + overlap_mm;

  // Tabs: start at rear face of body and extend further rear (overlap into body)
  tab_zc = body_rear_face_z - tab_len_mm/2 + overlap_mm;

  // Front face of flange (for cutting from the front)
  flange_front_face_z = flange_zc + flange_thickness_mm/2;

  difference() {
    union() {
      // Flange (40 x 27)
      translate([0,0,flange_zc])
        rounded_box(target_width_mm, target_height_mm, flange_thickness_mm, bezel_radius_mm, center=true);

      // Main body behind panel
      translate([0,0,body_zc])
        rounded_box(body_width_mm, body_height_mm, inlet_depth_mm, 2.0, center=true);

      // Rear strain relief boss (connected)
      translate([0,0,boss_zc])
        cylinder(d=strain_relief_clearance_diameter_mm, h=strain_relief_clearance_depth_mm, center=true);

      // Three rear spade tabs (connected to body)
      for (p = [
        [-tab_spacing_x_mm/2, -tab_spacing_y_mm/2, tab_zc], // L
        [ tab_spacing_x_mm/2, -tab_spacing_y_mm/2, tab_zc], // N
        [ 0,                  tab_spacing_y_mm/2, tab_zc]   // E
      ]) {
        translate(p)
          cube([tab_w_mm, tab_t_mm, tab_len_mm], center=true);
      }
    }

    // --- Subtractions to create recognizable IEC C14 face features ---

    // Recessed pocket on front face (keyed)
    // Cut from the flange front face inward so it is always visible on the front.
    recess_zc = flange_front_face_z - face_recess_depth_mm/2 + overlap_mm;
    translate([0,0,recess_zc])
      linear_extrude(height=face_recess_depth_mm + 2*overlap_mm, center=true)
        difference() {
          rounded_rect_2d(face_open_w_mm, face_open_h_mm, face_open_r_mm);
          // Key notch at top center
          translate([0, face_open_h_mm/2 - key_notch_h_mm/2])
            square([key_notch_w_mm, key_notch_h_mm], center=true);
        }

    // Through opening behind the recess (actual inlet mouth)
    // Ensures the inlet is not just a shallow pocket.
    mouth_depth = flange_thickness_mm + panel_thickness_mm + 6; // derived, extends into body
    mouth_zc = flange_front_face_z - mouth_depth/2 + overlap_mm;
    translate([0,0,mouth_zc])
      linear_extrude(height=mouth_depth + 2*overlap_mm, center=true)
        difference() {
          rounded_rect_2d(face_open_w_mm, face_open_h_mm, face_open_r_mm);
          translate([0, face_open_h_mm/2 - key_notch_h_mm/2])
            square([key_notch_w_mm, key_notch_h_mm], center=true);
        }

    // Three pin cavities into the body from the front
    pin_cut_depth = pin_hole_depth_mm;
    pin_zc = flange_front_face_z - pin_cut_depth/2 + overlap_mm;
    for (p2 = [
      [-pin_pitch_x_mm/2, -pin_pitch_y_mm/2, pin_zc], // L
      [ pin_pitch_x_mm/2, -pin_pitch_y_mm/2, pin_zc], // N
      [ 0,                 pin_pitch_y_mm/2, pin_zc]  // E
    ]) {
      translate(p2)
        cylinder(d=pin_hole_d_mm, h=pin_cut_depth + 2*overlap_mm, center=true);
    }

    // Mounting screw holes through flange (and slightly into body for clean cut)
    hole_h = flange_thickness_mm + panel_thickness_mm + 4*overlap_mm;
    hole_zc = flange_zc; // centered on flange
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*screw_hole_pitch_x_mm/2, sy*screw_hole_pitch_y_mm/2, hole_zc])
        cylinder(d=screw_hole_diameter_mm, h=hole_h, center=true);
    }
  }
}

// -------------------- Build --------------------
iec_c14_inlet_solid();