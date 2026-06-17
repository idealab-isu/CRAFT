$fn = 128;

// Parameters (match given bounding box and requested features)
bbox_X = 45.0;          // overall X bound
bbox_Y = 44.62;         // overall Y bound (also used as outer_D)
H = 115.0;              // height

outer_D = 44.62;        // outer diameter (Y bound)
bore_D  = 20.0;         // central bore diameter

notch_count = 6;        // several notches around circumference
notch_ang_offset_deg = 0.0;

notch_depth_radial = 4.0;       // how far notch cuts into OD
notch_width_tangential = 8.0;   // notch width along tangent
notch_height_Z = 20.0;          // notch height along Z
notch_Z_center = 0.0;           // notch vertical position

// Split/key feature (a slit through the wall)
split_width_tangential = 2.0;   // slit width (tangential)
split_depth_radial = notch_depth_radial; // cut into OD similarly
split_ang_deg = 0.0;            // angle of split

overlap = 1.0;                  // boolean robustness

// Derived
outer_R = outer_D/2;

// Base body: cylinder trimmed to bbox_X in X (gives slightly "circular/square" cross-section)
module outer_profile() {
  intersection() {
    cylinder(r=outer_R, h=H, center=true);
    // Trim in X to hit bbox_X exactly, keep Y unconstrained (outer_D already sets Y)
    cube([bbox_X, outer_D*2, H + 2*overlap], center=true);
  }
}

module central_through_bore() {
  cylinder(r=bore_D/2, h=H + 2*overlap, center=true);
}

// Rectangular notch cutter placed at OD and rotated around Z
module notch_cut_at_angle(a_deg) {
  rotate([0,0,a_deg])
    translate([outer_R - notch_depth_radial/2 + overlap, 0, notch_Z_center])
      cube([notch_depth_radial + 2*overlap,
            notch_width_tangential,
            notch_height_Z],
           center=true);
}

module circumferential_notches() {
  for (i = [0:notch_count-1])
    notch_cut_at_angle(notch_ang_offset_deg + i*360/notch_count);
}

// Split/key slit cutter (a deeper/continuous-looking interruption)
module split_slit() {
  rotate([0,0,split_ang_deg])
    translate([outer_R - split_depth_radial/2 + overlap, 0, 0])
      cube([split_depth_radial + 2*overlap,
            split_width_tangential,
            H + 2*overlap],
           center=true);
}

module all_subtractive_features() {
  union() {
    central_through_bore();
    circumferential_notches();
    split_slit();
  }
}

// Final
difference() {
  outer_profile();
  all_subtractive_features();
}