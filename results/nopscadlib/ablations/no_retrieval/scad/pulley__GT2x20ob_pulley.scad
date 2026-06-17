// Timing pulley: 20 teeth, pitch diameter 12.22mm
// Structural fix: make it clearly a timing pulley (20 teeth around OD),
// keep pitch diameter as the reference pitch circle, and ensure all parts
// are connected with small overlaps. Single connected solid output.

$fn = 220;

// ---------------- Parameters ----------------
tooth_count     = 20;      // must be 20
pitch_diameter  = 12.22;   // must be 12.22mm (reference pitch circle)
pulley_width    = 10;

bore_diameter   = 5;

hub_diameter    = 18;
hub_length      = 12;

flange_diameter   = 16;
flange_thickness  = 1.5;

set_screw_diameter = 3;
keyway_width       = 2;
keyway_depth       = 1;

eps = 0.05;

// Overlap to guarantee watertight unions (1–2mm)
join_ol = 1.2;

// ---------------- Tooth geometry (simple/blocky but clearly toothed) ----------------
// Pitch circle is a reference: tooth mid-radius sits at pitch radius.
tooth_radial_height    = 2.0;   // outward tooth height (visible)
tooth_tangential_width = 1.6;   // tooth width along tangent
tooth_root_overlap     = 0.8;   // tooth penetrates base ring for connection

// ---------------- Derived ----------------
pitch_r = pitch_diameter/2;

// Tooth radii: pitch circle passes through tooth mid-thickness radially
tooth_mid_r  = pitch_r;
tooth_root_r = max(0.2, tooth_mid_r - tooth_radial_height/2);
tooth_tip_r  = tooth_mid_r + tooth_radial_height/2;

// Base ring radius: ensure it is INSIDE tooth root so teeth protrude,
// but also ensure it is not smaller than the bore + wall thickness.
min_wall = 2.0; // simple, robust wall so pulley doesn't collapse into bore
base_r_nominal = max(0.2, tooth_root_r - 0.6);
base_r = max(base_r_nominal, bore_diameter/2 + min_wall);

// Tooth radial length includes overlap into base
tooth_len = (tooth_tip_r - tooth_root_r) + tooth_root_overlap;

// Place tooth so inner face penetrates base by tooth_root_overlap
tooth_center_r = base_r + tooth_len/2 - tooth_root_overlap;

// ---------------- Modules ----------------
module base_pulley_ring() {
  cylinder(r=base_r, h=pulley_width, center=true);
}

module tooth() {
  // Rectangular tooth, extruded along Z (pulley width)
  cube([tooth_len, tooth_tangential_width, pulley_width], center=true);
}

module teeth_ring() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      translate([tooth_center_r, 0, 0])
        tooth();
  }
}

module pulley_with_teeth() {
  union() {
    base_pulley_ring();
    teeth_ring();
  }
}

module hub() {
  // Hub centered; overlaps pulley body automatically (hub_length >= pulley_width)
  cylinder(r=hub_diameter/2, h=hub_length, center=true);
}

module flange_top() {
  // Overlap into pulley body by join_ol
  translate([0, 0, pulley_width/2 + flange_thickness/2 - join_ol])
    cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module flange_bottom() {
  // Overlap into pulley body by join_ol
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + join_ol])
    cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module center_bore() {
  // Cut through entire hub + pulley + flanges
  total_h = max(hub_length, pulley_width + 2*flange_thickness) + 2*join_ol + 2*eps;
  cylinder(r=bore_diameter/2, h=total_h, center=true);
}

module set_screw_hole() {
  // Through hub, radial direction (X axis), centered on Z
  rotate([0, 90, 0])
    cylinder(r=set_screw_diameter/2, h=hub_diameter + 2*join_ol + 2*eps, center=true);
}

module keyway() {
  // Keyway cut into bore (simple rectangular notch)
  translate([bore_diameter/2 - keyway_depth/2, 0, 0])
    cube([bore_diameter + 2*join_ol + 2*eps, keyway_width, hub_length + 2*join_ol + 2*eps], center=true);
}

module final_pulley() {
  difference() {
    union() {
      // Pulley body with teeth (recognizable 20-tooth silhouette)
      pulley_with_teeth();

      // Hub overlaps pulley body (single connected solid)
      hub();

      // Flanges overlap into pulley body by join_ol
      flange_top();
      flange_bottom();
    }

    // Subtractive features
    center_bore();
    set_screw_hole();
    keyway();
  }
}

// ---------------- Final Output (one connected solid) ----------------
final_pulley();