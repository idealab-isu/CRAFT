$fn = 64;

// EPCOS B57560G104F style: small epoxy-coated bead/disc with two straight radial leads
// (Simplified, dimensioned, single connected solid)

// Parameters
body_diameter = 3.0;            //[1.5:6.0:0.1]
body_thickness = 2.0;           //[1.0:4.0:0.1]
lead_diameter = 0.5;            //[0.25:1.0:0.05]
lead_length = 25.0;             //[12.0:50.0:1]
lead_pitch = 2.5;               //[1.25:5.0:0.1]
fillet_radius = 0.25;           //[0.1:0.6:0.05]
entry_boss_d = 1.1;             //[0.6:2.0:0.05]
entry_boss_h = 0.6;             //[0.2:1.5:0.05]
tinning_length = 3.0;           //[1.0:8.0:0.5]
tinning_scale = 1.12;           //[1.0:1.3:0.01]
overlap = 0.6;                  //[0.2:1.5:0.05]

// Derived
body_r = body_diameter/2;
lead_r = lead_diameter/2;
lead_pitch_eff = max(lead_pitch, lead_diameter*1.4);
fillet_eff = min(fillet_radius, min(body_r*0.45, body_thickness*0.45));
boss_r = max(entry_boss_d/2, lead_r*1.2);
boss_h = max(entry_boss_h, lead_diameter*0.8);

// Rounded epoxy body (disc/bead)
module thermistor_body() {
  minkowski() {
    cylinder(
      r = max(0.01, body_r - fillet_eff),
      h = max(0.01, body_thickness - 2*fillet_eff),
      center = true
    );
    sphere(r = fillet_eff);
  }
}

// Small bosses where leads exit the epoxy (ensures robust connection)
module lead_entry_boss(xpos) {
  // Place on bottom face, slightly embedded into body for guaranteed union
  zc = -body_thickness/2 + boss_h/2 - overlap*0.35;
  translate([xpos, 0, zc])
    cylinder(r = boss_r, h = boss_h + overlap, center = true);
}

// Straight radial lead (downwards from body)
module lead_straight(xpos) {
  // Lead starts slightly inside body and extends to tip
  z_top = -body_thickness/2 + overlap*0.35;
  z_bot = -body_thickness/2 - lead_length;
  h = (z_top - z_bot) + overlap;
  zc = (z_top + z_bot)/2;
  translate([xpos, 0, zc])
    cylinder(r = lead_r, h = h, center = true);
}

// Slightly thicker tinning sleeve near the tip (still one solid)
module lead_tinning_sleeve(xpos) {
  sleeve_r = lead_r * tinning_scale;
  z_tip = -body_thickness/2 - lead_length;
  zc = z_tip + tinning_length/2;
  translate([xpos, 0, zc])
    cylinder(r = sleeve_r, h = tinning_length + overlap*0.25, center = true);
}

module complete_model() {
  union() {
    thermistor_body();

    for (sx = [-lead_pitch_eff/2, lead_pitch_eff/2]) {
      lead_entry_boss(sx);
      lead_straight(sx);
      lead_tinning_sleeve(sx);
    }
  }
}

complete_model();