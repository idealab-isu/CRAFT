// Parameters
led_diameter_mm = 3.0; //[1.5:6.0:0.05]
body_height_mm = 3.15; //[1.6:6.3:0.05]
through_hole = 1; //[0:1:1]
lead_count = 2; //[2:2:1]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
lead_thickness_mm = 0.5; //[0.25:1.0:0.01]
lead_length_mm = 5.0; //[2.5:10.0:0.1]
rim_thickness_mm = 0.8; //[0.4:1.6:0.05]
rim_diameter_mm = 3.3; //[2.8:6.6:0.05]
eps_mm = 0.2; //[0.05:0.5:0.01]
lead_embed_mm = 0.8; //[0.4:1.6:0.05]
grill_width_mm = 6.0; //[3.0:12.0:0.1]
grill_height_mm = 6.0; //[3.0:12.0:0.1]
grill_hole_mm = 1.0; //[0.5:2.0:0.05]
grill_gap_mm = 0.6; //[0.3:1.2:0.05]
grill_r_mm = 1000; //[50:2000:10]

// Quality
$fn = 64;

// LED3mm - typical 3mm THT LED geometry (domed lens + flange + flat side + leads)
// Coordinate convention: flange sits on Z=0..rim_thickness_mm, body above it, leads below it.
module LED3mm() {
  r_body = led_diameter_mm/2;
  r_rim  = rim_diameter_mm/2;

  // Split body height into cylindrical "barrel" + domed lens cap
  dome_h   = min(r_body, body_height_mm*0.55);
  barrel_h = max(0.01, body_height_mm - dome_h);

  // Flat side (typical LED has a flat on one side of the epoxy body)
  flat_depth = max(0.15, led_diameter_mm*0.12); // how much to shave off radius
  flat_x = r_body - flat_depth;                 // plane location for flat (x > flat_x removed)

  // Leads
  lead_h = lead_length_mm + lead_embed_mm;

  // Z references
  z_rim_center    = rim_thickness_mm/2;
  z_barrel_center = rim_thickness_mm + barrel_h/2;
  z_dome_base     = rim_thickness_mm + barrel_h;
  z_dome_center   = z_dome_base + dome_h/2;

  // Lead center so top of lead overlaps into rim by lead_embed_mm
  z_lead_center = -lead_length_mm/2 + lead_embed_mm/2;

  // Build as ONE connected solid (union), with small overlaps where needed
  union() {
    // Epoxy body (barrel + dome) with flat side
    color([0.85, 0.85, 0.8])
    difference() {
      union() {
        // Barrel
        translate([0, 0, z_barrel_center])
          cylinder(r=r_body, h=barrel_h + eps_mm, center=true);

        // Domed lens (use scaled sphere to create a smooth dome)
        translate([0, 0, z_dome_center])
          scale([1, 1, dome_h/r_body])
            sphere(r=r_body);
      }

      // Flat side cut (remove a slab on +X side)
      translate([flat_x + 50, 0, rim_thickness_mm + body_height_mm/2])
        cube([100, 100, body_height_mm + 2*rim_thickness_mm + 10], center=true);
    }

    // Rim flange (slightly overlaps into body for connectivity)
    color([0.85, 0.85, 0.8])
    translate([0, 0, z_rim_center])
      cylinder(r=r_rim, h=rim_thickness_mm + eps_mm, center=true);

    // Leads (connected into rim by lead_embed_mm)
    if (through_hole) {
      color([0.75, 0.75, 0.75])
      for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, z_lead_center])
          cube([lead_thickness_mm, lead_thickness_mm, lead_h + eps_mm], center=true);
      }
    }
  }
}

// Blue side tabs/blocks around the LED body - MUST be physically attached (overlap 1-2mm)
module side_tabs_connected() {
  r_body = led_diameter_mm/2;

  // Tab geometry (kept consistent with existing "bump" look)
  tab_r = grill_hole_mm/2;
  tab_h = max(0.6, rim_thickness_mm*0.9); // visible thickness

  // Ensure radial overlap into the LED barrel by ~1.2mm (clamped so we don't invert)
  overlap_rad = 1.2;
  tab_center_r = max(0, r_body + tab_r - overlap_rad);

  // Place tabs on the barrel region so they intersect the cylindrical body (not floating)
  dome_h   = min(r_body, body_height_mm*0.55);
  barrel_h = max(0.01, body_height_mm - dome_h);

  // Center within barrel; also overlap slightly into rim/body transition
  z_tab_center = rim_thickness_mm + barrel_h/2;

  color([0.1, 0.1, 0.6])
  union() {
    for (a = [0, 90, 180, 270]) {
      rotate([0, 0, a])
        translate([tab_center_r, 0, z_tab_center])
          cylinder(r=tab_r, h=tab_h + eps_mm, center=true, $fn=24);
    }
  }
}

// Assembly (single connected solid)
module assembly() {
  union() {
    LED3mm();
    side_tabs_connected();
  }
}

assembly();