// Parameters
led_diameter_mm = 3; //[1.5:6:0.1]
body_height_mm = 3.15; //[1.6:6.3:0.05]
rim_thickness_mm = 0.6; //[0.3:1.2:0.05]
rim_diameter_mm = 3.6; //[2.8:7.2:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.25:1:0.01]
lead_length_mm = 5; //[2.5:10:0.1]
overlap_mm = 0.8; //[0.3:2:0.1]
grill_plate_w_mm = 8; //[4:16:0.5]
grill_plate_h_mm = 8; //[4:16:0.5]
grill_plate_t_mm = 0.6; //[0.3:1.2:0.05]
grill_hole_d_mm = 1.2; //[0.6:2.4:0.1]
grill_gap_mm = 0.8; //[0.4:1.6:0.1]

// Derived Z references (keep everything connected with slight overlap)
z_rim_center   = 0;
z_rim_top      = z_rim_center + rim_thickness_mm/2;
z_rim_bottom   = z_rim_center - rim_thickness_mm/2;

z_body_center  = z_rim_top + body_height_mm/2 - overlap_mm;  // overlaps into rim

// Leads overlap into rim and extend down to (and slightly into) the plate
z_lead_top     = z_rim_bottom + overlap_mm;                  // inside rim
z_plate_top    = z_rim_bottom - lead_length_mm + overlap_mm; // plate top intersects lead tips
z_plate_center = z_plate_top - grill_plate_t_mm/2;           // plate positioned from its top face

// LED - complete geometry (single connected solid)
module led() {
  union() {
    color("red") {
      // LED Body (overlaps rim)
      translate([0, 0, z_body_center])
        cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true, $fn=32);

      // Rim Flange
      translate([0, 0, z_rim_center])
        cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true, $fn=32);

      // Leads: compute center so top is at z_lead_top and bottom reaches into plate
      lead_total_h = (z_lead_top - z_plate_top) + overlap_mm; // extra overlap into plate
      z_lead_center = (z_lead_top + z_plate_top)/2;

      for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, z_lead_center])
          cube([lead_thickness_mm, lead_thickness_mm, lead_total_h], center=true);
      }
    }
  }
}

// Grill Plate + attached cylinders (no floating)
// Also add two "pad" cylinders under the lead positions so the small gray cylinders
// are physically connected to BOTH the plate and the LED leads.
module grill_and_pads() {
  union() {
    color("Silver") {
      // Grill Plate (intersects lead tips)
      translate([0, 0, z_plate_center])
        cube([grill_plate_w_mm, grill_plate_h_mm, grill_plate_t_mm], center=true);

      // Grill Hole Markers (physically attached to plate: same Z, taller than plate)
      hole_h = grill_plate_t_mm + 2*overlap_mm;

      translate([-grill_plate_w_mm/2 + (grill_hole_d_mm + grill_gap_mm)/2,
                 -grill_plate_h_mm/2 + (grill_hole_d_mm + grill_gap_mm)/2,
                 z_plate_center])
        cylinder(r=grill_hole_d_mm/2, h=hole_h, center=true, $fn=16);

      translate([-grill_plate_w_mm/2 + 3*(grill_hole_d_mm + grill_gap_mm)/2,
                 -grill_plate_h_mm/2 + (grill_hole_d_mm + grill_gap_mm)/2,
                 z_plate_center])
        cylinder(r=grill_hole_d_mm/2, h=hole_h, center=true, $fn=16);

      translate([-grill_plate_w_mm/2 + (grill_hole_d_mm + grill_gap_mm),
                 -grill_plate_h_mm/2 + 3*(grill_hole_d_mm + grill_gap_mm)/2,
                 z_plate_center])
        cylinder(r=grill_hole_d_mm/2, h=hole_h, center=true, $fn=16);

      translate([-grill_plate_w_mm/2 + 2*(grill_hole_d_mm + grill_gap_mm),
                 -grill_plate_h_mm/2 + 3*(grill_hole_d_mm + grill_gap_mm)/2,
                 z_plate_center])
        cylinder(r=grill_hole_d_mm/2, h=hole_h, center=true, $fn=16);

      // Through-hole pad cylinders (the previously floating gray cylinders):
      // Place them at the lead XY positions and make them penetrate the plate
      // and overlap upward into the lead tips.
      pad_r = max(grill_hole_d_mm/2, lead_thickness_mm*1.2);
      pad_h = grill_plate_t_mm + 2*overlap_mm; // ensures intersection with plate and lead
      z_pad_center = z_plate_center + grill_plate_t_mm/2 - overlap_mm/2; // slightly above plate center

      for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, z_pad_center])
          cylinder(r=pad_r, h=pad_h, center=true, $fn=24);
      }
    }
  }
}

// Assembly: single solid union so nothing is disconnected
module assembly() {
  union() {
    led();
    grill_and_pads();
  }
}

assembly();