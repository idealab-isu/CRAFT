$fn = 200;

// Parameters (requested)
tooth_count     = 10;     //[5:40:1]
pitch_diameter  = 15.0;   //[7.5:30.0:0.1]

// Main dimensions
pulley_width    = 12.0;   //[6.0:24.0:0.1]
tooth_height    = 1.6;    //[0.8:3.2:0.05]
tooth_tip_width = 2.0;    //[1.0:4.0:0.05]
bore_diameter   = 5.0;    //[2.5:10.0:0.1]

// Hub / flanges
hub_diameter    = 22.0;   //[11.0:44.0:0.1]
hub_length      = 10.0;   //[5.0:20.0:0.1]
flange_thickness= 1.5;    //[0.8:3.0:0.1]
flange_od       = 20.0;   //[10.0:40.0:0.1]

// Optional features
set_screw_diameter       = 3.0; //[2.0:6.0:0.1]
keyway_width             = 2.0; //[1.0:4.0:0.1]
keyway_depth             = 1.0; //[0.5:2.5:0.1]
keyway_length            = 10.0; //[5.0:20.0:0.1]
grub_flat_depth          = 0.6; //[0.2:1.5:0.05]
grub_flat_width          = 3.0; //[1.5:6.0:0.1]
overlap                  = 1.2; //[0.3:2.0:0.1]
chamfer_amount           = 0.6; //[0.2:1.5:0.05]

// ---------------- Derived geometry ----------------
// Pitch radius is where belt pitch line runs.
// Keep tooth CENTER at pitch radius so pitch diameter is correct.
pitch_r = pitch_diameter/2;

// Tooth spans radially: [pitch_r - tooth_height/2, pitch_r + tooth_height/2]
root_r  = pitch_r - tooth_height/2;
tip_r   = pitch_r + tooth_height/2;

// Base cylinder reaches tooth root so teeth protrude outward visibly
body_r  = root_r;

// ---------------- Base Shapes ----------------
module pulley_body() {
  cylinder(h=pulley_width, r=body_r, center=true);
}

module hub() {
  // Centered hub; overlaps pulley body automatically (same origin)
  cylinder(h=hub_length, r=hub_diameter/2, center=true);
}

// Simplified timing tooth: trapezoid-like prism (recognizable teeth silhouette)
// IMPORTANT: place teeth by rotate + translate (radial), not by polar polygon at origin.
module tooth_proto() {
  // Tooth radial length includes overlap into body for a single solid
  tooth_radial_len = tooth_height + overlap;
  tooth_pitch = 2*PI*pitch_r/tooth_count;

  // Keep within pitch so gaps are visible
  w_tip  = min(tooth_tip_width, tooth_pitch*0.65);
  w_root = w_tip*1.25;

  // Tooth thickness along Z: match pulley width and overlap slightly into flanges if present
  z_h = pulley_width + overlap*2;

  // Radial placement:
  // inner face pushed into body by overlap; outer face reaches beyond tip radius
  inner_r = root_r - overlap;
  outer_r = inner_r + tooth_radial_len;
  tooth_center_r = (inner_r + outer_r)/2;

  // Build tooth centered at origin, then translate radially outward
  translate([tooth_center_r, 0, 0])
    linear_extrude(height=z_h, center=true, convexity=10)
      polygon(points=[
        [-w_root/2, inner_r - tooth_center_r],
        [-w_tip /2, outer_r - tooth_center_r],
        [ w_tip /2, outer_r - tooth_center_r],
        [ w_root/2, inner_r - tooth_center_r]
      ]);
}

module flange_left() {
  // Overlap into pulley body by 'overlap' so it is one solid
  translate([0, 0, -(pulley_width/2 + flange_thickness/2 - overlap)])
    cylinder(h=flange_thickness, r=flange_od/2, center=true);
}

module flange_right() {
  translate([0, 0,  (pulley_width/2 + flange_thickness/2 - overlap)])
    cylinder(h=flange_thickness, r=flange_od/2, center=true);
}

module center_bore() {
  cylinder(h=hub_length + pulley_width + flange_thickness*2 + overlap*8,
           r=bore_diameter/2, center=true);
}

module set_screw_hole() {
  // Radial through hub; positioned so it always intersects hub
  rotate([0, 90, 0])
    cylinder(h=hub_diameter + overlap*8, r=set_screw_diameter/2, center=true);
}

module keyway() {
  // Cut into bore wall (along Z)
  translate([bore_diameter/2 - (keyway_depth + overlap)/2 + overlap, 0, 0])
    cube([keyway_depth + overlap, keyway_width, keyway_length], center=true);
}

module grub_screw_flat() {
  // Flat on bore wall (along Z)
  translate([bore_diameter/2 - (grub_flat_depth + overlap)/2 + overlap, 0, 0])
    cube([grub_flat_depth + overlap, grub_flat_width, hub_length + overlap*2], center=true);
}

module chamfer_cut_top() {
  translate([0, 0, hub_length/2 - chamfer_amount])
    cylinder(h=chamfer_amount*2,
             r1=hub_diameter/2 + chamfer_amount,
             r2=hub_diameter/2 - chamfer_amount,
             center=true);
}

module chamfer_cut_bottom() {
  translate([0, 0, -hub_length/2 + chamfer_amount])
    rotate([180, 0, 0])
      cylinder(h=chamfer_amount*2,
               r1=hub_diameter/2 + chamfer_amount,
               r2=hub_diameter/2 - chamfer_amount,
               center=true);
}

// ---------------- Tooth Array ----------------
module tooth_array() {
  for (i = [0:tooth_count-1])
    rotate([0, 0, i * 360/tooth_count])
      tooth_proto();
}

// ---------------- Pulley Assembly ----------------
module pulley_with_teeth() {
  union() {
    pulley_body();
    tooth_array();     // 10 evenly spaced teeth at pitch_diameter
    hub();
    flange_left();
    flange_right();
  }
}

// ---------------- Final Pulley ----------------
module final_pulley() {
  difference() {
    pulley_with_teeth();
    center_bore();
    set_screw_hole();
    keyway();
    grub_screw_flat();
    chamfer_cut_top();
    chamfer_cut_bottom();
  }
}

color("Silver") final_pulley();