// Timing pulley: 16 teeth, 12.16mm pitch diameter (pitch circle)
// One connected solid; all placements are formula-based.

// ---------- Parameters ----------
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 12.16; //[6.08:24.32:0.01]
pulley_width_mm = 7; //[4:20:0.5]

bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 14; //[8:28:0.5]
hub_length_mm = 10; //[4:30:0.5]

flange_diameter_mm = 16; //[10:32:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]

set_screw_count = 1; //[0:2:1]
set_screw_size = 3; //[2:5:0.5]
set_screw_z_offset_mm = 0; //[-10:10:0.5]

tolerance_mm = 0.2; //[0:0.6:0.05]

// Tooth geometry (simple printable tooth blocks positioned from pitch circle)
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_root_offset_mm = 0.6; //[0.2:1.5:0.05]
tooth_tangential_width_factor = 0.55; //[0.35:0.8:0.01]
tooth_overlap_mm = 0.6; //[0.2:1.5:0.05]

// General overlap to guarantee manifold unions
overlap_mm = 0.8; //[0.2:2:0.1]

// ---------- Derived ----------
pitch_radius_mm = pitch_diameter_mm/2;
tooth_pitch_mm = PI * pitch_diameter_mm / tooth_count;

// Root cylinder radius (teeth sit on this)
root_r_mm = pitch_radius_mm - tooth_root_offset_mm;

// Tooth block dimensions
tooth_size_x_mm = tooth_radial_height_mm + tooth_overlap_mm;                 // radial thickness (includes overlap into root)
tooth_size_y_mm = tooth_pitch_mm * tooth_tangential_width_factor;            // tangential width
tooth_size_z_mm = pulley_width_mm;

// Outer radius of teeth (for sanity/clearance)
tooth_outer_r_mm = root_r_mm + tooth_radial_height_mm;

// Z extents (centered pulley body at z=0)
pulley_z_min = -pulley_width_mm/2;
pulley_z_max =  pulley_width_mm/2;

// Hub placed below pulley, overlapping into it
hub_z_center = pulley_z_min - hub_length_mm/2 + overlap_mm;
hub_z_min = hub_z_center - hub_length_mm/2;
hub_z_max = hub_z_center + hub_length_mm/2;

// Flanges overlap into pulley at both ends
top_flange_z_center = pulley_z_max + flange_thickness_mm/2 - overlap_mm;
bot_flange_z_center = pulley_z_min - flange_thickness_mm/2 + overlap_mm;

// Total height for through-holes
total_z_min = min(hub_z_min, bot_flange_z_center - flange_thickness_mm/2);
total_z_max = max(pulley_z_max, top_flange_z_center + flange_thickness_mm/2);
total_h = (total_z_max - total_z_min) + 2*overlap_mm;

// Ensure hub is not smaller than toothed OD (keeps one continuous silhouette like the views)
hub_r_mm = max(hub_diameter_mm/2, tooth_outer_r_mm - overlap_mm);

// ---------- Modules ----------
module pulley_body() {
  cylinder(r = root_r_mm,
           h = pulley_width_mm,
           center = true,
           $fn = 160);
}

module tooth_blank() {
  // Place tooth so its inner face is inside the root cylinder by tooth_overlap_mm
  translate([root_r_mm + tooth_size_x_mm/2 - tooth_overlap_mm, 0, 0])
    cube([tooth_size_x_mm, tooth_size_y_mm, tooth_size_z_mm], center=true);
}

module printed_pulley_teeth() {
  for (i = [0:tooth_count-1])
    rotate([0, 0, i*360/tooth_count])
      tooth_blank();
}

module hub() {
  translate([0, 0, hub_z_center])
    cylinder(r = hub_r_mm,
             h = hub_length_mm,
             center = true,
             $fn = 160);
}

module flanges() {
  translate([0, 0, top_flange_z_center])
    cylinder(r = flange_diameter_mm/2,
             h = flange_thickness_mm,
             center = true,
             $fn = 160);

  translate([0, 0, bot_flange_z_center])
    cylinder(r = flange_diameter_mm/2,
             h = flange_thickness_mm,
             center = true,
             $fn = 160);
}

module center_bore() {
  translate([0, 0, (total_z_min + total_z_max)/2])
    cylinder(r = (bore_diameter_mm + tolerance_mm)/2,
             h = total_h,
             center = true,
             $fn = 120);
}

module set_screw_holes() {
  if (set_screw_count > 0) {
    translate([0, 0, hub_z_center + set_screw_z_offset_mm])
      rotate([0, 90, 0])
        cylinder(r = (set_screw_size + tolerance_mm)/2,
                 h = 2*hub_r_mm + 4*overlap_mm,
                 center = true,
                 $fn = 80);
  }

  if (set_screw_count > 1) {
    translate([0, 0, hub_z_center + set_screw_z_offset_mm])
      rotate([0, 90, 90])
        cylinder(r = (set_screw_size + tolerance_mm)/2,
                 h = 2*hub_r_mm + 4*overlap_mm,
                 center = true,
                 $fn = 80);
  }
}

module pulley_solid() {
  union() {
    pulley_body();
    printed_pulley_teeth();
    hub();
    flanges();
  }
}

difference() {
  pulley_solid();
  center_bore();
  set_screw_holes();
}