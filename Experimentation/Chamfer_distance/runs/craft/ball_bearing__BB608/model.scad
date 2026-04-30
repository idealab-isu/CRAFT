// Parameters (mm)
primary_dimension_mm = 8; //[4:16:0.1]
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 22; //[11:44:0.1]
width_mm = 7; //[3.5:14:0.1]
shield_type = 1; //[0:1:1]
material_color_outer = 0; //[0:1:1]
material_color_shield = 0; //[0:1:1]
eps_mm = 0.6; //[0.2:1.2:0.1]
outer_ring_radial_thk_mm = 2.4; //[1.2:4.8:0.1]
inner_ring_radial_thk_mm = 1.6; //[0.8:3.2:0.1]
shield_thickness_mm = 0.8; //[0.4:1.6:0.1]
ball_diameter_mm = 2.4; //[1.2:4.8:0.1]
ball_count = 8; //[6:12:1]

// Quality
$fn=32;

// Derived
outer_r = outer_diameter_mm/2;
bore_r = bore_diameter_mm/2;

outer_bore_r = outer_diameter_mm/2 - outer_ring_radial_thk_mm;
inner_outer_r = bore_diameter_mm/2 + inner_ring_radial_thk_mm;

shield_outer_r = outer_diameter_mm/2 - outer_ring_radial_thk_mm - eps_mm;
shield_inner_r = bore_diameter_mm/2 + inner_ring_radial_thk_mm + eps_mm;

ball_r = ball_diameter_mm/2;
ball_pitch_r = ((bore_diameter_mm/2 + inner_ring_radial_thk_mm) + (outer_diameter_mm/2 - outer_ring_radial_thk_mm))/2;

shield_z = width_mm/2 - shield_thickness_mm/2 - eps_mm/2;

// ---------- Mandatory components ----------

module bearing_ball() {
  // Realistic ball: sphere with subtle "polished" flat hint (very slight)
  color([0.72, 0.72, 0.75])  // steel-ish
  difference() {
    sphere(r=ball_r);
    // tiny opposing flats to suggest contact points (kept minimal)
    translate([0,0, ball_r*0.92]) cylinder(h=ball_r, r=ball_r*0.55, center=false, $fn=32);
    translate([0,0,-ball_r*1.92]) cylinder(h=ball_r, r=ball_r*0.55, center=false, $fn=32);
  }
}

module ball_bearing() {
  // Outer ring
  color([0.45, 0.45, 0.48])  // steel
  difference() {
    cylinder(r=outer_r, h=width_mm, center=true);
    cylinder(r=outer_bore_r, h=width_mm + 2*eps_mm, center=true);
  }

  // Inner ring
  color([0.50, 0.50, 0.53])  // slightly different steel tone
  difference() {
    cylinder(r=inner_outer_r, h=width_mm, center=true);
    cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
  }

  // Shields / seals (same geometry; color differs by shield_type)
  shield_col = (shield_type == 0) ? [0.60,0.60,0.62] : [0.12,0.12,0.12];
  color(shield_col) {
    // front
    translate([0,0, shield_z])
    difference() {
      cylinder(r=shield_outer_r, h=shield_thickness_mm, center=true);
      cylinder(r=shield_inner_r, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
    // back
    translate([0,0,-shield_z])
    difference() {
      cylinder(r=shield_outer_r, h=shield_thickness_mm, center=true);
      cylinder(r=shield_inner_r, h=shield_thickness_mm + 2*eps_mm, center=true);
    }
  }

  // Representative ball ring (connected/contained within bearing envelope)
  // Place balls at pitch radius; keep centered in Z.
  for (i = [0:ball_count-1]) {
    rotate([0,0,i*360/ball_count])
      translate([ball_pitch_r, 0, 0])
        bearing_ball();
  }
}

// ---------- Assembly ----------

module assembly() {
  // Primary component at origin
  ball_bearing();
}

assembly();