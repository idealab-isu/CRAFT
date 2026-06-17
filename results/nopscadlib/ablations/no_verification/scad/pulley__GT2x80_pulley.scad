$fn = 220;

// --- Target spec (must match) ---
tooth_count = 80;
pitch_diameter_mm = 50.42;                 // exact
pitch_radius_mm = pitch_diameter_mm/2;

// --- Derived belt pitch from pitch diameter + tooth count ---
belt_pitch_mm = PI * pitch_diameter_mm / tooth_count;   // circular pitch at pitch circle

// --- Tooth geometry (printable approximation; count + pitch diameter preserved) ---
tooth_radial_height_mm = 1.2;              // radial add above pitch circle
root_clearance_mm = 0.6;                   // radial below pitch circle
tooth_tangential_width_mm = 0.55 * belt_pitch_mm;

// --- Pulley body ---
pulley_width_mm = 16;

// --- Bore / hub / flanges ---
bore_diameter_mm = 5;

hub_diameter_mm = 20;
hub_length_mm = 10;

flange_diameter_mm = 60;
flange_thickness_mm = 1.5;

set_screw_count = 1;
set_screw_size = 3;
set_screw_z_mm = 5;

tolerance_mm = 0.2;
overlap_mm = 1;

// --- Derived radii (pitch diameter preserved by construction) ---
root_radius_mm  = pitch_radius_mm - root_clearance_mm;
outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// --- Modules ---
module pulley_body() {
  union() {
    // Root cylinder (tooth base)
    cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

    // Hub (connected with overlap)
    if (hub_length_mm > 0)
      translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges (connected with overlap)
    if (flange_thickness_mm > 0) {
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

      translate([0, 0,  pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
  }
}

module pulley_teeth() {
  // Teeth protrude outward from root_radius to outer_radius, overlapping into root for connectivity
  tooth_len = (outer_radius_mm - root_radius_mm) + overlap_mm;
  tooth_center_r = root_radius_mm + tooth_len/2 - overlap_mm;

  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      translate([tooth_center_r, 0, 0])
        cube([tooth_len, tooth_tangential_width_mm, pulley_width_mm], center=true);
  }
}

module cuts() {
  // Through bore (covers full stack)
  total_h = pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 8*overlap_mm;
  cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=total_h, center=true);

  // Set screw holes (in hub region)
  if (set_screw_count > 0 && hub_length_mm > 0) {
    hub_center_z = -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm;
    screw_z = hub_center_z + (-hub_length_mm/2 + set_screw_z_mm);

    for (i = [0:set_screw_count-1]) {
      rotate([0, 0, i*360/set_screw_count])
        translate([hub_diameter_mm/4, 0, screw_z])
          rotate([0, 90, 0])
            cylinder(r=(set_screw_size + tolerance_mm)/2,
                     h=hub_diameter_mm + 6*overlap_mm, center=true);
    }
  }
}

// --- Assembly (single connected solid) ---
difference() {
  union() {
    pulley_body();
    pulley_teeth();
  }
  cuts();
}