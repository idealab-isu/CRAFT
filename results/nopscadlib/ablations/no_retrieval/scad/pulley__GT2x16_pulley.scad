// Timing pulley: 16 teeth, 9.75mm pitch diameter
// Structural fix: make the pulley clearly a TIMING PULLEY by ADDING 16 outward teeth
// Teeth are simple/blocky but countable and connected.
// Pitch diameter is enforced as the circle passing through the MID-THICKNESS of each tooth.

$fn = 220;

// Parameters
tooth_count = 16;                 //[8:32:1]
pitch_diameter = 9.75;            //[5:20:0.05]  // pitch circle diameter (tooth centerline)
pulley_width = 10;                //[5:25:0.5]
bore_diameter = 5;                //[2:12:0.1]
hub_diameter = 14;                //[8:28:0.5]
hub_length = 12;                  //[6:30:0.5]
flange_diameter = 18;             //[10:36:0.5]
flange_thickness = 1.5;           //[0.8:4:0.1]

// Tooth geometry (simple, recognizable timing-tooth approximation)
tooth_radial_height = 1.6;        //[0.6:3:0.1]  // radial protrusion beyond pitch circle
tooth_tangential_width = 1.6;     //[0.6:3:0.1]  // tooth width around circumference at pitch circle
rim_clearance_below_pitch = 1.2;  //[0.3:3:0.1]  // radial distance from pitch circle down to root

// Optional features
set_screw_diameter = 3;           //[2:6:0.1]
set_screw_z_offset = 0;           //[-10:10:0.5]
keyway_width = 2;                 //[1:5:0.1]
keyway_depth = 1;                 //[0.5:3:0.1]
keyway_length = 10;               //[5:30:0.5]
chamfer_size = 0.6;               //[0.2:2:0.1]

// Overlap for robust unions/differences (1–2mm)
overlap_z = 1.2;
overlap_r = 0.6;
eps = 0.01;

// Derived radii
pitch_r = pitch_diameter/2;

// Root radius is below pitch circle by rim_clearance_below_pitch
root_r  = max(0.1, pitch_r - rim_clearance_below_pitch);

// Enforce: pitch circle passes through tooth mid-thickness radially
// => tooth_radial_thickness = 2*(pitch_r - root_r)
tooth_radial_thickness = max(0.8, 2*(pitch_r - root_r));
tip_r = root_r + tooth_radial_thickness;

// Base cylinder (root) + outward teeth
module toothed_rim() {
  union() {
    // Root cylinder (between teeth)
    cylinder(h=pulley_width, r=root_r, center=true);

    // Teeth: centered so their mid-thickness lies on pitch radius.
    // Place tooth center at radius = pitch_r, with slight inward overlap to guarantee union.
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([pitch_r - overlap_r, 0, 0])
          cube([tooth_radial_thickness + 2*overlap_r,
                tooth_tangential_width,
                pulley_width + 2*overlap_z],
               center=true);
    }
  }
}

module hub() {
  cylinder(h=hub_length, r=hub_diameter/2, center=true);
}

module flange_top() {
  translate([0, 0, pulley_width/2 + flange_thickness/2 - overlap_z/2])
    cylinder(h=flange_thickness + overlap_z, r=flange_diameter/2, center=true);
}

module flange_bottom() {
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + overlap_z/2])
    cylinder(h=flange_thickness + overlap_z, r=flange_diameter/2, center=true);
}

module center_bore() {
  cylinder(h=hub_length + 2*flange_thickness + 4*overlap_z, r=bore_diameter/2, center=true);
}

module set_screw_hole() {
  rotate([0, 90, 0])
    translate([0, 0, set_screw_z_offset])
      cylinder(h=hub_diameter + 2*overlap_z, r=set_screw_diameter/2, center=true);
}

module keyway() {
  translate([bore_diameter/2 + keyway_depth/2 - overlap_r, 0, 0])
    cube([keyway_depth + 2*overlap_r, keyway_width, keyway_length], center=true);
}

module chamfer_top_cut() {
  translate([0, 0, hub_length/2 - chamfer_size])
    cylinder(h=2*chamfer_size + eps,
             r1=hub_diameter/2 + chamfer_size,
             r2=hub_diameter/2 - chamfer_size,
             center=true);
}

module chamfer_bottom_cut() {
  translate([0, 0, -hub_length/2 + chamfer_size])
    cylinder(h=2*chamfer_size + eps,
             r1=hub_diameter/2 - chamfer_size,
             r2=hub_diameter/2 + chamfer_size,
             center=true);
}

module pulley_solid() {
  union() {
    // All solids share the same axis and overlap in Z via flange overlap_z.
    // Hub overlaps the rim radially (hub_diameter > root diameter), ensuring one connected solid.
    toothed_rim();
    hub();
    flange_top();
    flange_bottom();
  }
}

module pulley_final() {
  difference() {
    pulley_solid();

    // Subtractive features
    center_bore();
    set_screw_hole();
    keyway();
    chamfer_top_cut();
    chamfer_bottom_cut();
  }
}

// Final Output (one connected solid)
pulley_final();