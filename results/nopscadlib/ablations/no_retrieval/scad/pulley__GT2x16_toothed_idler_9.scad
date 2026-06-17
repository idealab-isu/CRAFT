$fn = 180;

// Parameters
tooth_count = 16; //[8:32:1]
pitch_diameter = 9.75; //[5:20:0.05]
pulley_width = 10; //[5:25:1]
tooth_height = 1.2; //[0.6:2.4:0.05]
tooth_tip_width = 1; //[0.5:2:0.05]
tooth_root_width = 1.6; //[0.8:3.2:0.05]
bore_diameter = 5; //[2:10:0.1]
hub_diameter = 16; //[10:32:0.1]
hub_length = 12; //[6:30:1]
flange_diameter = 18; //[12:40:0.1]
flange_thickness = 1; //[0.6:3:0.1]
set_screw_diameter = 3; //[2:6:0.1]
set_screw_z_offset = 0; //[-10:10:0.5]
keyway_width = 2; //[1:5:0.1]
keyway_depth = 1; //[0.5:3:0.1]
keyway_length = 10; //[5:25:1]
overlap = 1.2; //[0.5:2:0.1]

// Derived geometry (enforce pitch diameter + visible teeth)
pitch_r = pitch_diameter/2;

// Root circle below pitch circle by ~half tooth height (simple approximation)
tooth_root_r = max(pitch_r - tooth_height/2, bore_diameter/2 + 1.0);
tooth_outer_r = tooth_root_r + tooth_height;

// Ensure tooth width fits within circular pitch
tooth_arc = PI * pitch_diameter / tooth_count;           // circular pitch at pitch circle
tooth_tangential_w_root = min(tooth_root_width, 0.90*tooth_arc);
tooth_tangential_w_tip  = min(tooth_tip_width,  0.70*tooth_arc);

// Tooth radial length
tooth_len = tooth_outer_r - tooth_root_r;

// Base Shapes
module pulley_body() {
  // Root cylinder (teeth protrude beyond this)
  cylinder(r=tooth_root_r, h=pulley_width, center=true);
}

module hub() {
  // Hub overlaps into pulley body so union is one solid
  cylinder(r=hub_diameter/2, h=hub_length, center=true);
}

module flange_top() {
  // Touch/overlap the pulley body (centered model)
  translate([0, 0, pulley_width/2 + flange_thickness/2 - overlap])
    cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module flange_bottom() {
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + overlap])
    cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

// Tooth as a 3D wedge (trapezoid in tangential direction), placed by rotate+translate
module tooth() {
  // Place tooth so its inner face overlaps into the root cylinder for a single connected solid
  translate([tooth_root_r + tooth_len/2 - overlap, 0, 0])
    linear_extrude(height=pulley_width + 2*overlap, center=true, convexity=10)
      polygon(points=[
        [-tooth_len/2, -tooth_tangential_w_root/2],
        [-tooth_len/2,  tooth_tangential_w_root/2],
        [ tooth_len/2,  tooth_tangential_w_tip/2],
        [ tooth_len/2, -tooth_tangential_w_tip/2]
      ]);
}

// Tooth Array (16 teeth around circumference)
module tooth_array() {
  for (i = [0:tooth_count-1])
    rotate([0, 0, i * 360/tooth_count])
      tooth();
}

module center_bore() {
  // Cut through the entire assembled height (hub + flanges) with margin
  total_h = max(hub_length, pulley_width + 2*flange_thickness) + 6*overlap;
  cylinder(r=bore_diameter/2, h=total_h, center=true);
}

module set_screw_hole() {
  // Radial hole through hub; centered in Z with adjustable offset
  // Put the hole axis at the hub radius so it actually intersects the hub (not through the center)
  // and keep it fully cutting across the hub.
  hole_axis_r = hub_diameter/2 - set_screw_diameter/2 - overlap;

  translate([0, 0, set_screw_z_offset])
    rotate([0, 90, 0])
      translate([0, hole_axis_r, 0])
        cylinder(r=set_screw_diameter/2, h=hub_diameter + 6*overlap, center=true);
}

module keyway() {
  // Keyway cut inside bore, aligned to +X; ensure it spans the hub length
  // Place so it intersects the bore wall (starts at bore radius and cuts outward by keyway_depth)
  x_center = (bore_diameter/2 - overlap) + (keyway_depth + 2*overlap)/2;
  cube_h = max(keyway_length, hub_length) + 2*overlap;

  translate([x_center, 0, 0])
    cube([keyway_depth + 2*overlap, keyway_width, cube_h], center=true);
}

// Pulley Assembly
module pulley_with_teeth() {
  union() {
    pulley_body();
    tooth_array();
  }
}

module pulley_with_hub() {
  union() {
    pulley_with_teeth();
    hub();
  }
}

module pulley_with_flanges() {
  union() {
    pulley_with_hub();
    flange_top();
    flange_bottom();
  }
}

// Final Model
module complete_model() {
  difference() {
    pulley_with_flanges();
    center_bore();
    set_screw_hole();
    keyway();
  }
}

color("Silver") complete_model();