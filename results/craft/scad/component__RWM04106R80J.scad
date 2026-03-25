// Parameters
resistance_ohms = 6.8; //[3.4:13.6:0.1]
power_w = 3; //[1.5:6:0.5]
body_length_mm = 15; //[8:30:1]
body_diameter_mm = 5.5; //[3:11:0.1]
enamel_thickness_mm = 0.4; //[0.2:0.8:0.05]
lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_mm = 30; //[15:60:1]
lead_overlap_mm = 1; //[0.5:2:0.1]
sleeve_length_each_mm = 10; //[0:25:1]
sleeve_thickness_mm = 0.25; //[0.1:0.6:0.05]
eps_mm = 0.01; //[0.001:0.1:0.001]

// Connectivity overlap (force solid intersections between parts)
connect_overlap_mm = 1.5; // 1-2mm recommended

// ---------- Single connected resistor geometry ----------
module resistor_connected() {
  // Derived
  body_r = body_diameter_mm/2;
  core_r = max(0.01, body_r - enamel_thickness_mm);

  // Ensure overlap is at least 1mm and not longer than the lead itself
  overlap = min(max(connect_overlap_mm, 1), lead_length_each_mm);

  // Body extents along X (body cylinder is along Z by default, so rotate it to X)
  // We'll build everything along X to avoid axis confusion and guarantee attachment.
  body_half = body_length_mm/2;

  // Leads: place so inner end penetrates into body by 'overlap'
  // For a centered X-axis cylinder of length L at x=cx:
  // left end = cx - L/2, right end = cx + L/2
  lead_L = lead_length_each_mm + overlap; // extra length ensures penetration robustness

  // Left lead: its right end should be at (-body_half + overlap)
  left_lead_cx  = (-body_half + overlap) - lead_L/2;

  // Right lead: its left end should be at ( body_half - overlap)
  right_lead_cx = ( body_half - overlap) + lead_L/2;

  // Sleeves: must overlap into body/lead region too (and be on top of the lead)
  sleeve_L = max(0, sleeve_length_each_mm);
  sleeve_L_eff = (sleeve_L > 0) ? (sleeve_L + overlap) : 0;

  // Left sleeve: its right end should be at (-body_half + overlap)
  left_sleeve_cx  = (-body_half + overlap) - sleeve_L_eff/2;

  // Right sleeve: its left end should be at ( body_half - overlap)
  right_sleeve_cx = ( body_half - overlap) + sleeve_L_eff/2;

  union() {
    // Resistor body (core + enamel) oriented along X so leads attach correctly
    union() {
      // Core (grey cylinder) - physically present and unioned
      color("DimGray")
        rotate([0, 90, 0])
          cylinder(r=core_r, h=body_length_mm, center=true, $fn=48);

      // Enamel coating (white shell) - unioned with core (touching at core surface)
      color("White")
        rotate([0, 90, 0])
          difference() {
            cylinder(r=body_r, h=body_length_mm, center=true, $fn=48);
            cylinder(r=core_r, h=body_length_mm + eps_mm, center=true, $fn=48);
          }
    }

    // Leads (silver) - forced overlap into body
    color("Silver") {
      translate([left_lead_cx, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=lead_diameter_mm/2, h=lead_L, center=true, $fn=24);

      translate([right_lead_cx, 0, 0])
        rotate([0, 90, 0])
          cylinder(r=lead_diameter_mm/2, h=lead_L, center=true, $fn=24);
    }

    // Sleeves (black) - forced overlap into body/lead region
    if (sleeve_L > 0) {
      color("Black") {
        translate([left_sleeve_cx, 0, 0])
          rotate([0, 90, 0])
            cylinder(r=lead_diameter_mm/2 + sleeve_thickness_mm, h=sleeve_L_eff, center=true, $fn=24);

        translate([right_sleeve_cx, 0, 0])
          rotate([0, 90, 0])
            cylinder(r=lead_diameter_mm/2 + sleeve_thickness_mm, h=sleeve_L_eff, center=true, $fn=24);
      }
    }
  }
}

// Backwards-compatible module names (all now produce the same single connected solid)
module resistor() { resistor_connected(); }
module al_clad_resistor() { resistor_connected(); }
module sleeved_resistor() { resistor_connected(); }
module al_clad_resistor_assembly() { resistor_connected(); }

// Assembly: union into a single solid (no stacked duplicates)
module assembly() {
  union() {
    resistor_connected();
  }
}

assembly();