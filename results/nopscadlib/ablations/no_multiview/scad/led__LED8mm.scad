// Parameters
led_diameter_mm = 8; //[4:16:0.1]
body_height_mm = 9.2; //[4.6:18.4:0.1]
rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
rim_diameter_mm = 9.2; //[8.4:14:0.1]
lead_thickness_mm = 0.5; //[0.3:1:0.05]
lead_pitch_mm = 2.54; //[1.5:5.08:0.01]
lead_length_mm = 5; //[2.5:15:0.1]
right_angle = 0; //[0:10:1]
overlap_mm = 1.2; //[0.2:2:0.1]
grill_width_mm = 12; //[6:30:0.5]
grill_height_mm = 12; //[6:30:0.5]
grill_hole_mm = 2; //[1:5:0.1]
grill_gap_mm = 1; //[0.5:4:0.1]
grill_r_mm = 1000; //[20:2000:10]

// LED - complete geometry (fixed connectivity)
module led() {
  // Z references:
  // Rim spans: z = [0 .. rim_thickness_mm]
  // Body spans: z = [rim_thickness_mm - overlap_mm .. rim_thickness_mm - overlap_mm + body_height_mm]
  // Leads span: z = [-(lead_length_mm) .. rim_thickness_mm + overlap_mm]  (overlaps into rim by overlap_mm)

  color("red")
  union() {
    // LED Rim (base at z=0)
    translate([0, 0, rim_thickness_mm/2])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true, $fn=64);

    // LED Body (overlaps into rim by overlap_mm)
    translate([0, 0, (rim_thickness_mm - overlap_mm) + body_height_mm/2])
      cylinder(r=led_diameter_mm/2, h=body_height_mm, center=true, $fn=64);

    // Leads (extend up into rim by overlap_mm to guarantee attachment)
    // Place as a single solid union with the body/rim
    for (sx = [-1, 1]) {
      translate([sx*lead_pitch_mm/2, 0, (-lead_length_mm + (rim_thickness_mm + overlap_mm))/2])
        cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm + rim_thickness_mm + overlap_mm], center=true);
    }

    // Optional Right Angle Bend (kept connected to the vertical leads)
    if (right_angle > 0) {
      for (sx = [-1, 1]) {
        // Bend starts at the bottom end of the vertical lead (z = -lead_length_mm)
        // Overlap slightly into the vertical lead by overlap_mm
        translate([sx*lead_pitch_mm/2,
                   -(right_angle/2 + lead_thickness_mm/2 - overlap_mm),
                   -lead_length_mm + lead_thickness_mm/2])
          cube([lead_thickness_mm, right_angle, lead_thickness_mm], center=true);
      }
    }
  }
}

// Grill Hole Positions - complete geometry
module grill_hole_positions() {
  color("Silver") {
    union() {
      translate([-grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true, $fn=32);
      translate([grill_width_mm/4, -grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true, $fn=32);
      translate([-grill_width_mm/4, grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true, $fn=32);
      translate([grill_width_mm/4, grill_height_mm/4, rim_thickness_mm/2])
        cylinder(r=grill_hole_mm/2, h=rim_thickness_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  union() {
    led();
    grill_hole_positions();
  }
}

assembly();