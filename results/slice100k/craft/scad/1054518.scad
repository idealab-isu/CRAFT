// Stepped bushing/spacer with through cylindrical bore and C-shaped side opening on upper boss
// Bounding box target: ~10.14 x 10.16 x 8.01 mm

// Parameters
bbox_x = 10.14; //[5.07:20.28:0.01]
bbox_y = 10.16; //[5.08:20.32:0.01]
bbox_z = 8.01;  //[4.0:16.02:0.01]

flange_d = 10.14; //[5.07:20.28:0.01]
flange_h = 3.0;   //[1.5:6.0:0.01]

boss_d = 7.0;     //[3.5:14.0:0.01]
boss_h = 5.01;    //[2.5:10.02:0.01]

bore_d = 4.0;     //[2.0:8.0:0.01]

// Side opening (flat) that opens the bore to exterior on the upper boss
cutout_w = 3.0;       //[1.0:6.0:0.01]   // width in Y
cutout_depth = 4.0;   //[1.0:8.0:0.01]   // how far the flat cuts into boss from OD toward center
cutout_z0 = 3.0;      //[0.0:8.0:0.01]   // start height from bottom of part
cutout_h = 5.01;      //[1.0:10.02:0.01]

overlap = 0.5;        //[0.2:2.0:0.1]

// Smoothness (kept moderate for fast rendering)
$fn = 48;

// Helpers
z_bottom = -bbox_z/2;

module base_flange() {
  translate([0,0, z_bottom + flange_h/2])
    cylinder(d=flange_d, h=flange_h, center=true);
}

module upper_boss() {
  translate([0,0, z_bottom + flange_h + boss_h/2])
    cylinder(d=boss_d, h=boss_h, center=true);
}

module through_bore() {
  cylinder(d=bore_d, h=bbox_z + 2*overlap, center=true);
}

module upper_c_opening() {
  // Flat cut on upper boss that intersects the bore, creating a C-shaped opening.
  boss_r = boss_d/2;
  x_inner = boss_r - cutout_depth;

  // Make cutter large enough to guarantee full cut without excessive size.
  cutter_len_x = boss_r + cutout_depth + 2*overlap;
  cutter_x = x_inner + cutter_len_x/2;

  translate([cutter_x, 0, z_bottom + cutout_z0 + cutout_h/2])
    cube([cutter_len_x, cutout_w, cutout_h + 2*overlap], center=true);
}

difference() {
  union() {
    base_flange();
    upper_boss();
  }
  through_bore();
  upper_c_opening();
}