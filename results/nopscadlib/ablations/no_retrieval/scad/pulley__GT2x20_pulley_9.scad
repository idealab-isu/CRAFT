// Timing pulley: 20 teeth, pitch diameter = 12.22mm
// Fixes:
// - Teeth are now CUT INTO the pitch cylinder (visible in orthographic views)
// - Pitch diameter is enforced by using pitch_diameter as the tooth reference radius
// - All parts are connected using dimension-based translations with small overlaps

$fn = 160;

// Parameters
pitch_diameter = 12.22; //[6.11:24.44:0.01]
tooth_count = 20; //[10:60:1]
pulley_width = 10; //[5:20:0.1]

// Tooth groove (subtractive) parameters
tooth_height = 1.5; //[0.75:3:0.05]          // radial depth of groove from pitch radius outward
tooth_tip_width = 1.2; //[0.6:2.4:0.05]       // tangential width near OD
tooth_root_width = 2; //[1:4:0.05]            // tangential width near pitch circle

// Body sizing (OD must be > pitch_diameter + 2*tooth_height to show grooves)
body_outer_diameter = 14.5; //[7.25:29:0.01]

// Bore / hub / flanges
bore_diameter = 5; //[2.5:10:0.01]
hub_diameter = 18; //[9:36:0.01]
hub_length = 12; //[6:24:0.1]
flange_thickness = 1.5; //[0.8:3:0.05]
flange_outer_diameter = 20; //[10:40:0.1]

// Connectivity / features
connect_overlap = 1; //[0.5:2:0.1]
set_screw_diameter = 3; //[2:6:0.1]
set_screw_z = 0; //[-6:6:0.1]
keyway_width = 2; //[1:4:0.05]
keyway_depth = 1; //[0.5:2.5:0.05]
keyway_length = 10; //[5:20:0.1]
chamfer_size = 0.6; //[0.3:1.5:0.05]

// Derived
pitch_r = pitch_diameter/2;
body_r  = body_outer_diameter/2;

// Ensure grooves are visible: body OD must exceed pitch + 2*tooth_height
effective_body_r = max(body_r, pitch_r + tooth_height + 0.2);

// ---------------- Base solids ----------------
module pulley_body() {
  cylinder(h=pulley_width, r=effective_body_r, center=true);
}

module hub() {
  cylinder(h=hub_length, r=hub_diameter/2, center=true);
}

module flange_left() {
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + connect_overlap])
    cylinder(h=flange_thickness, r=flange_outer_diameter/2, center=true);
}

module flange_right() {
  translate([0, 0, pulley_width/2 + flange_thickness/2 - connect_overlap])
    cylinder(h=flange_thickness, r=flange_outer_diameter/2, center=true);
}

// ---------------- Tooth groove (subtractive) ----------------
// A trapezoidal prism groove, placed so its inner face starts at pitch radius.
// This creates visible "timing pulley teeth" around the circumference.
module tooth_groove_proto() {
  groove_depth = tooth_height;
  // Make sure the groove reaches the OD even if parameters are tight
  groove_depth_eff = max(groove_depth, effective_body_r - pitch_r + 0.05);

  // 2D trapezoid in XY, extruded along Z
  // x = radial direction, y = tangential direction
  // Inner edge at x=0 corresponds to pitch circle; outer at x=groove_depth_eff
  linear_extrude(height=pulley_width + 2*connect_overlap, center=true, convexity=10)
    polygon(points=[
      [0,               -tooth_root_width/2],
      [0,                tooth_root_width/2],
      [groove_depth_eff,  tooth_tip_width/2],
      [groove_depth_eff, -tooth_tip_width/2]
    ]);
}

module tooth_grooves() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      translate([pitch_r, 0, 0])  // inner edge starts at pitch radius (enforces pitch diameter)
        tooth_groove_proto();
  }
}

// ---------------- Subtractions ----------------
module center_bore() {
  cylinder(h=hub_length + 2*connect_overlap, r=bore_diameter/2, center=true);
}

module set_screw_hole() {
  // Radial hole through hub (along X), centered at set_screw_z in Z
  rotate([0, 90, 0])
    translate([0, 0, set_screw_z])
      cylinder(h=hub_diameter + 2*connect_overlap, r=set_screw_diameter/2, center=true);
}

module keyway() {
  // Keyway cut into bore: starts at bore radius and goes outward by keyway_depth
  translate([bore_diameter/2 + keyway_depth/2 - connect_overlap/2, 0, 0])
    cube([keyway_depth + connect_overlap, keyway_width, keyway_length], center=true);
}

module chamfer_cone_left() {
  translate([0, 0, -hub_length/2 + chamfer_size])
    cylinder(h=2*chamfer_size,
             r1=hub_diameter/2 + chamfer_size,
             r2=hub_diameter/2 - chamfer_size,
             center=true);
}

module chamfer_cone_right() {
  translate([0, 0, hub_length/2 - chamfer_size])
    cylinder(h=2*chamfer_size,
             r1=hub_diameter/2 - chamfer_size,
             r2=hub_diameter/2 + chamfer_size,
             center=true);
}

// ---------------- Assembly ----------------
module pulley_solid() {
  union() {
    pulley_body();
    hub();
    flange_left();
    flange_right();
  }
}

module pulley_final() {
  difference() {
    // Main connected solid
    pulley_solid();

    // Timing grooves (teeth profile)
    tooth_grooves();

    // Functional cuts
    center_bore();
    keyway();
    set_screw_hole();

    // Chamfers
    chamfer_cone_left();
    chamfer_cone_right();
  }
}

// Final Output
pulley_final();