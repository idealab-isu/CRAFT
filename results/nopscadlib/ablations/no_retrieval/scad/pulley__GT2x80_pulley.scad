$fn = 180;

// Parameters
tooth_count = 80; //[40:160:1]
pitch_diameter = 50.42; //[25.21:100.84:0.01]
pulley_width = 15; //[8:30:0.5]

outer_diameter = 56.42; //[40:90:0.01]
bore_diameter = 8; //[4:20:0.1]

hub_diameter = 24; //[12:48:0.1]
hub_length = 18; //[10:36:0.5]

flange_thickness = 1.5; //[0.8:3:0.1]
flange_diameter = 60; //[45:90:0.1]

tooth_radial_height = 1.2; //[0.6:2.5:0.05]
tooth_tangential_width = 1.0; //[0.5:2.0:0.05]
tooth_overlap = 0.8; //[0.3:2:0.05]

set_screw_diameter = 3; //[2:6:0.1]
set_screw_axis_z = 0; //[-20:20:0.5]

keyway_width = 2; //[1:6:0.1]
keyway_depth = 1; //[0.5:3:0.1]
keyway_length = 12; //[6:30:0.5]

chamfer_size = 0.8; //[0.3:2:0.05]
eps_overlap = 1; //[0.5:2:0.1]

// Derived (pitch diameter is honored by placing tooth centers on pitch radius)
pitch_r = pitch_diameter/2;
outer_r = outer_diameter/2;

// Tooth geometry
tooth_len = tooth_radial_height + tooth_overlap; // radial length of tooth block (includes overlap into rim)
root_r = outer_r - tooth_radial_height;          // tooth tip reaches outer_r
rim_base_r = root_r + tooth_overlap;             // rim under teeth so they connect

// Place tooth so its CENTER lies on pitch circle:
// tooth center radius = root_r + tooth_len/2
// enforce: root_r + tooth_len/2 == pitch_r  => adjust root_r accordingly
root_r = pitch_r - tooth_len/2;
rim_base_r = root_r + tooth_overlap;
outer_r = root_r + tooth_radial_height;          // implied outer radius from pitch + tooth height

// Base Shapes
module rim_base() {
  cylinder(h=pulley_width, r=rim_base_r, center=true);
}

module tooth_blank() {
  // Tooth protrudes outward; overlaps inward into rim_base by tooth_overlap
  translate([root_r + tooth_len/2, 0, 0])
    cube([tooth_len, tooth_tangential_width, pulley_width], center=true);
}

module toothed_rim() {
  union() {
    rim_base();
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        tooth_blank();
    }
  }
}

module flange(zsign=1) {
  translate([0, 0, zsign*(pulley_width/2 + flange_thickness/2 - eps_overlap/2)])
    cylinder(h=flange_thickness, r=flange_diameter/2, center=true);
}

module center_bore() {
  cylinder(h=hub_length + pulley_width + 2*flange_thickness + 6*eps_overlap,
           r=bore_diameter/2, center=true);
}

module set_screw_hole() {
  // Through hub radially (X axis), centered in Z by set_screw_axis_z
  rotate([0, 90, 0])
    translate([0, 0, set_screw_axis_z])
      cylinder(h=hub_diameter + 6*eps_overlap, r=set_screw_diameter/2, center=true);
}

module keyway_cut() {
  // Keyway referenced from bore radius; cut length along Z
  translate([bore_diameter/2 - (keyway_depth + eps_overlap)/2, 0, 0])
    cube([keyway_depth + eps_overlap, keyway_width, keyway_length], center=true);
}

module chamfer_cone_left() {
  translate([0, 0, -hub_length/2])
    cylinder(h=2*chamfer_size,
             r1=hub_diameter/2 + chamfer_size,
             r2=hub_diameter/2 - chamfer_size,
             center=true);
}

module chamfer_cone_right() {
  translate([0, 0, +hub_length/2])
    cylinder(h=2*chamfer_size,
             r1=hub_diameter/2 - chamfer_size,
             r2=hub_diameter/2 + chamfer_size,
             center=true);
}

// Assembly (ONE connected solid)
module pulley_solid() {
  union() {
    // Toothed rim is the main body
    toothed_rim();

    // Hub overlaps into rim to guarantee connectivity
    cylinder(h=hub_length, r=hub_diameter/2, center=true);

    // Flanges overlap into rim
    flange(-1);
    flange(+1);
  }
}

difference() {
  pulley_solid();

  // Bore + features
  center_bore();
  keyway_cut();
  set_screw_hole();

  // Chamfers (subtractive)
  chamfer_cone_left();
  chamfer_cone_right();
}