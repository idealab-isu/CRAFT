// Parameters
led_diameter_mm = 10.0; //[5.0:20.0:0.1]
body_height_mm = 11.0; //[6.0:22.0:0.1]
rim_thickness_mm = 1.0; //[0.5:2.0:0.1]
rim_diameter_mm = 10.8; //[8.0:21.6:0.1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.6; //[0.3:1.2:0.05]
lead_length_mm = 5.0; //[2.5:15.0:0.1]
overlap_mm = 1.2; //[0.5:2.0:0.1]  // ensure 1-2mm overlap for robust connectivity
lens_round_radius_mm = 5.0; //[2.5:10.0:0.1]
grill_width_mm = 20.0; //[10.0:60.0:0.5]
grill_height_mm = 20.0; //[10.0:60.0:0.5]
grill_hole_mm = 3.0; //[1.0:8.0:0.1]
grill_gap_mm = 1.0; //[0.5:5.0:0.1]
grill_radius_limit_mm = 1000.0; //[50.0:2000.0:10.0]

// Shared Z references (rim top at z=0, leads go downward)
rim_top_z = 0;
rim_center_z = rim_top_z - rim_thickness_mm/2;
rim_bottom_z = rim_top_z - rim_thickness_mm;

// LED - complete geometry (connected)
module led() {
  // Body sits on rim top with slight overlap into rim
  body_cyl_h = max(0.01, body_height_mm - lens_round_radius_mm);
  body_cyl_center_z = rim_top_z + body_cyl_h/2 - overlap_mm; // overlaps into rim
  body_cyl_top_z = body_cyl_center_z + body_cyl_h/2;

  // Dome sphere centered so its bottom meets cylinder top, with overlap
  dome_center_z = body_cyl_top_z - overlap_mm;

  // Leads: make them long enough to penetrate the mounting plate by overlap_mm
  // Plate top is set to lead_bottom_z + overlap_mm, so to intersect plate we extend leads by overlap_mm.
  lead_h = lead_length_mm + overlap_mm;                 // extend slightly beyond nominal
  lead_top_z = rim_bottom_z + overlap_mm;               // start inside rim for junction
  lead_center_z = lead_top_z - lead_h/2;

  color("red")
  union() {
    // Rim
    translate([0, 0, rim_center_z])
      cylinder(r=rim_diameter_mm/2, h=rim_thickness_mm, center=true);

    // LED Body (cylinder + dome) - attached to rim via overlap
    translate([0, 0, body_cyl_center_z])
      cylinder(r=led_diameter_mm/2, h=body_cyl_h, center=true);

    translate([0, 0, dome_center_z])
      sphere(r=led_diameter_mm/2);

    // Leads - attached to rim and extended to intersect the plate
    translate([-lead_pitch_mm/2, 0, lead_center_z])
      cube([lead_thickness_mm, lead_thickness_mm, lead_h], center=true);

    translate([ lead_pitch_mm/2, 0, lead_center_z])
      cube([lead_thickness_mm, lead_thickness_mm, lead_h], center=true);
  }
}

// Gray mounting plate/board - positioned to physically intersect the lead ends
module mounting_plate() {
  // Compute lead bottom based on the actual lead geometry used in led()
  lead_h = lead_length_mm + overlap_mm;
  lead_top_z = rim_bottom_z + overlap_mm;
  lead_bottom_z = lead_top_z - lead_h;                  // actual bottom of lead solids

  // Make plate thick enough to be a "board" and guarantee overlap with leads
  plate_th = max(2.0, lead_thickness_mm + overlap_mm);  // >=2mm board thickness
  // Place plate so its top is slightly ABOVE the lead bottom -> guaranteed intersection
  plate_top_z = lead_bottom_z + overlap_mm;
  plate_center_z = plate_top_z - plate_th/2;

  color("gray")
  translate([0, 0, plate_center_z])
    cube([grill_width_mm, grill_height_mm, plate_th], center=true);
}

// Assembly (single solid, all parts physically connected)
module assembly() {
  union() {
    led();
    mounting_plate();
  }
}

assembly();