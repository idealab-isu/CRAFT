// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Structural fix: add clearly visible timing teeth (20x) around circumference,
// enforce pitch diameter at tooth mid-height, keep one connected solid with overlaps.
// No text/labels added.

$fn = 220;

// ---------------- Parameters ----------------
tooth_count    = 20;      //[10:60:1]
pitch_d        = 12.22;   //[6.11:24.44:0.01]
pulley_width   = 10;      //[5:20:0.1]

tooth_height   = 1.6;     //[0.8:3.2:0.05]
tooth_top_w    = 0.9;     //[0.4:2.5:0.05]   // tangential width at tip (visible)
tooth_base_w   = 2.0;     //[0.8:4.0:0.05]   // tangential width at root (visible)

bore_d         = 5;       //[2.5:10:0.01]

hub_d          = 18;      //[9:36:0.01]
hub_len        = 12;      //[6:24:0.1]

flange_thk     = 1;       //[0.5:2:0.05]
flange_d       = 20;      //[10:40:0.01]
flange_enabled = 1;       //[0:1:1]

set_screw_d    = 3;       //[2:6:0.1]
set_screw_z    = 0;       //[-6:6:0.1]

keyway_w       = 2;       //[1:4:0.05]
keyway_depth   = 1;       //[0.5:2.5:0.05]
keyway_len     = 12;      //[6:24:0.1]

overlap        = 1.2;     //[0.5:2:0.1]  // overlap for robust unions/differences

// ---------------- Derived geometry ----------------
// Pitch circle passes through tooth mid-height (simplified timing pulley convention)
pitch_r = pitch_d/2;
tip_r   = pitch_r + tooth_height/2;
root_r  = pitch_r - tooth_height/2;

// Ensure root radius stays positive and leaves some material
root_r_safe = max(root_r, bore_d/2 + 1.5);

// Tooth radial length from root cylinder surface to tip (with overlap into root)
tooth_len = tip_r - (root_r_safe - overlap);

// ---------------- Base solids ----------------
module pulley_body() {
  cylinder(h=pulley_width, r=root_r_safe, center=true);
}

module hub() {
  cylinder(h=hub_len, r=hub_d/2, center=true);
}

module flange_top() {
  // Centered so it overlaps into the pulley body by 'overlap'
  translate([0, 0, pulley_width/2 + flange_thk/2 - overlap])
    cylinder(h=flange_thk*flange_enabled, r=flange_d/2, center=true);
}

module flange_bottom() {
  translate([0, 0, -(pulley_width/2 + flange_thk/2 - overlap)])
    cylinder(h=flange_thk*flange_enabled, r=flange_d/2, center=true);
}

// ---------------- Teeth ----------------
// 2D trapezoid in X (radial) / Y (tangential), extruded along Z (pulley width).
module tooth_2d() {
  polygon(points=[
    [0,         -tooth_base_w/2],
    [0,          tooth_base_w/2],
    [tooth_len,  tooth_top_w/2],
    [tooth_len, -tooth_top_w/2]
  ]);
}

module tooth_at(angle) {
  rotate([0,0,angle])
    // Place tooth so its inner face starts at (root_r_safe - overlap) to guarantee union connectivity
    translate([root_r_safe - overlap, 0, 0])
      linear_extrude(height=pulley_width, center=true, convexity=10)
        tooth_2d();
}

module tooth_ring() {
  for (i=[0:tooth_count-1])
    tooth_at(i*360/tooth_count);
}

// ---------------- Cuts ----------------
module center_bore() {
  cylinder(h=hub_len + 2*overlap, r=bore_d/2, center=true);
}

module set_screw_hole() {
  // Through hub, intersects bore
  translate([hub_d/2 - overlap, 0, set_screw_z])
    rotate([0,90,0])
      cylinder(h=hub_d + 2*overlap, r=set_screw_d/2, center=true);
}

module keyway() {
  // Slot cut into bore
  translate([bore_d/2 - (keyway_depth + overlap)/2, 0, 0])
    cube([keyway_depth + overlap, keyway_w, keyway_len], center=true);
}

// ---------------- Assembly ----------------
module pulley_solid() {
  difference() {
    union() {
      // Root + teeth (recognizable timing pulley silhouette)
      pulley_body();
      tooth_ring();

      // Hub overlaps into pulley body for a single connected solid
      hub();

      // Flanges overlap into pulley body
      if (flange_enabled) {
        flange_top();
        flange_bottom();
      }
    }

    // Subtractions
    center_bore();
    set_screw_hole();
    keyway();
  }
}

pulley_solid();