$fn = 96;

// Parameters (mm)
body_diameter = 5.0;                 // LED lens diameter
body_height = 5.9;                   // Lens height above flange top
flange_diameter = 5.8;               // Typical 5mm LED flange OD
flange_thickness = 1.1;              // Typical flange thickness
lead_diameter = 0.5;
lead_pitch = 2.54;
lead_length_below_body = 25;
lead_length_into_body = 1.0;
overlap = 0.25;                      // small overlap to ensure one connected solid
flat_key_depth = 0.6;                // flat on rim
flat_key_height = 3.2;
internal_cup_radius = 1.2;
internal_cup_depth = 1.0;
marking_bump_radius = 0.25;

// Derived
r_body = body_diameter/2;
r_flange = flange_diameter/2;

// Place flange top at z=0, leads go negative, lens goes positive
z_flange_top = 0;
z_flange_center = z_flange_top - flange_thickness/2;
z_lens_base = z_flange_top - overlap;          // overlap into flange
z_lens_top = z_flange_top + body_height;
z_lens_center = (z_lens_base + z_lens_top)/2;
h_lens = z_lens_top - z_lens_base;

// Lens profile: cylinder + spherical cap (standard 5mm LED look)
cap_r = r_body;
cap_center_z = z_lens_top - cap_r;             // sphere center so top is at z_lens_top

module led_body() {
  color([0.85, 0.85, 0.8])
  difference() {
    union() {
      // Flange
      translate([0,0,z_flange_center])
        cylinder(r=r_flange, h=flange_thickness, center=true);

      // Lens cylinder portion (up to start of dome)
      // Choose a dome height that looks standard while keeping total height = body_height
      dome_h = min(1.8, max(1.2, body_height*0.30));
      cyl_h = max(0.1, body_height - dome_h);

      // Cylinder from z_lens_base to z_lens_base + cyl_h
      translate([0,0,z_lens_base + cyl_h/2])
        cylinder(r=r_body, h=cyl_h, center=true);

      // Dome (spherical cap) from z_lens_base + cyl_h to z_lens_top
      intersection() {
        translate([0,0,cap_center_z])
          sphere(r=cap_r);
        translate([0,0,(z_lens_base + cyl_h + z_lens_top)/2])
          cylinder(r=r_body+0.01, h=(z_lens_top - (z_lens_base + cyl_h)) + 0.02, center=true);
      }
    }

    // Flat key on rim (D-shape)
    translate([r_body - flat_key_depth/2, 0, z_flange_top + flat_key_height/2])
      cube([flat_key_depth, body_diameter + 0.2, flat_key_height], center=true);

    // Internal cup (slight recess from bottom)
    translate([0,0,z_flange_top - internal_cup_depth/2])
      cylinder(r=internal_cup_radius, h=internal_cup_depth, center=true);
  }
}

module led_leads() {
  // Make leads part of the same solid by slightly overlapping into flange
  // Leads extend from z = -(lead_length_below_body) up to z = lead_length_into_body (into body)
  z_lead_bottom = -lead_length_below_body;
  z_lead_top = lead_length_into_body;
  h_lead = (z_lead_top - z_lead_bottom);

  color([0.2, 0.2, 0.2])
  union() {
    for (sx = [-1, 1]) {
      translate([sx*lead_pitch/2, 0, (z_lead_bottom + z_lead_top)/2])
        cylinder(r=lead_diameter/2, h=h_lead, center=true);
    }

    // Small tie bar near the bottom to ensure a single connected solid even if slicers treat
    // touching cylinders as separate shells (kept very thin)
    tie_z = z_lead_bottom + lead_diameter/2;
    translate([0,0,tie_z])
      cube([lead_pitch + lead_diameter, lead_diameter*0.9, lead_diameter*0.9], center=true);
  }
}

module led_markings() {
  // Small bump on side of body
  color([0.2, 0.2, 0.2])
  translate([r_body - marking_bump_radius, 0, z_flange_top + body_height*0.45])
    sphere(r=marking_bump_radius, center=true);
}

module led_model() {
  union() {
    led_body();
    led_leads();
    led_markings();
  }
}

led_model();