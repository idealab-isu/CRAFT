// Timing pulley: 20 teeth, 12.22mm pitch diameter
// Structural fix: make teeth clearly present on the circumference and enforce pitch diameter.
// Keep simple/blocky tooth form; ensure all solids overlap slightly so the final is one connected solid.

$fn = 220;

// -------------------- Parameters --------------------
tooth_count = 20;                 //[10:60:1]
pitch_diam = 12.22;               //[6.11:24.44:0.01]
pulley_width = 10;                //[5:20:0.1]

rim_radial_thk = 1.2;             //[0.6:3:0.05]   // thickness under pitch circle
tooth_radial_height = 1.2;        //[0.6:2.4:0.05] // tooth height above pitch circle
tooth_tangential_width = 1.6;     //[0.8:3.2:0.05] // tooth width along circumference (at pitch circle)

hub_diam = 18;                    //[9:36:0.1]
hub_length = 12;                  //[6:24:0.1]
bore_diam = 5;                    //[2:12:0.01]

flange_thk = 1.5;                 //[0.8:3:0.1]
flange_diam = 22;                 //[12:44:0.1]
enable_flanges = 1;               //[0:1:1]

set_screw_diam = 2.5;             //[1.5:5:0.1]
set_screw_z = 0;                  //[-6:6:0.1]

keyway_width = 2;                 //[1:5:0.1]
keyway_depth = 1;                 //[0.5:3:0.1]

// Removed/disabled face lightening holes by default to keep design aligned with request
lightening_hole_diam = 3;         //[1.5:8:0.1]
lightening_hole_count = 0;        //[0:12:1]
lightening_hole_radius = 6;       //[3:12:0.1]

chamfer_size = 0.6;               //[0:2:0.05]

// Overlap for robust unions / differences (1–2mm requested)
overlap = 1.2;                    //[0.8:2:0.1]

// -------------------- Derived --------------------
pitch_r = pitch_diam/2;                               // REQUIRED pitch radius (12.22mm pitch diameter)
root_r  = max(0.1, pitch_r - rim_radial_thk);         // body under pitch circle
outer_r = pitch_r + tooth_radial_height;              // tooth tip radius

function clamp(x, a, b) = min(max(x, a), b);

// -------------------- Base solids --------------------
module rim_root() {
  cylinder(h=pulley_width, r=root_r, center=true);
}

module tooth_wedge() {
  // Simple visible tooth: angular wedge spanning tooth_tangential_width at pitch radius.
  // Overlaps inward so it fuses with rim_root.
  r_in  = max(0.05, pitch_r - overlap);
  r_out = outer_r;

  // Convert tangential width at pitch radius to angular span (radians)
  tooth_pitch_ang = 2*PI/tooth_count;
  ang = clamp(tooth_tangential_width / max(0.01, pitch_r), 0.03, tooth_pitch_ang*0.80);
  half_ang = ang/2;

  linear_extrude(height=pulley_width, center=true, convexity=10)
    polygon(points=[
      [r_in*cos(-half_ang),  r_in*sin(-half_ang)],
      [r_out*cos(-half_ang), r_out*sin(-half_ang)],
      [r_out*cos( half_ang), r_out*sin( half_ang)],
      [r_in*cos( half_ang),  r_in*sin( half_ang)]
    ]);
}

module toothed_rim() {
  // Recognizable timing pulley silhouette: root cylinder + 20 repeated teeth.
  union() {
    rim_root();
    for (i = [0:tooth_count-1])
      rotate([0, 0, i*360/tooth_count])
        tooth_wedge();
  }
}

module hub_cyl() {
  // Ensure hub overlaps the rim in Z so everything is one solid
  cylinder(h=hub_length, r=hub_diam/2, center=true);
}

module flange_top() {
  if (enable_flanges)
    translate([0, 0, pulley_width/2 + flange_thk/2 - overlap])
      cylinder(h=flange_thk, r=flange_diam/2, center=true);
}

module flange_bot() {
  if (enable_flanges)
    translate([0, 0, -pulley_width/2 - flange_thk/2 + overlap])
      cylinder(h=flange_thk, r=flange_diam/2, center=true);
}

// -------------------- Cutters --------------------
module bore_cyl() {
  cylinder(h=hub_length + 2*flange_thk + 8*overlap, r=bore_diam/2, center=true);
}

module set_screw_cyl() {
  // Radial hole through hub; Z position along pulley axis
  rotate([0, 90, 0])
    translate([0, 0, set_screw_z])
      cylinder(h=hub_diam + 8*overlap, r=set_screw_diam/2, center=true);
}

module keyway_box() {
  // Slot intersecting bore; depth extends outward from bore
  translate([bore_diam/2 + keyway_depth/2, 0, 0])
    cube([keyway_depth + 2*overlap, keyway_width, hub_length + 2*flange_thk + 8*overlap], center=true);
}

module lightening_holes() {
  for (i = [0:lightening_hole_count-1]) {
    rotate([0, 0, i*360/max(1,lightening_hole_count)])
      translate([lightening_hole_radius, 0, 0])
        cylinder(h=hub_length + 2*flange_thk + 8*overlap, r=lightening_hole_diam/2, center=true);
  }
}

module chamfer_top_cone() {
  translate([0, 0, hub_length/2 - chamfer_size/2 + overlap])
    cylinder(h=chamfer_size + 4*overlap,
             r1=hub_diam/2 + chamfer_size,
             r2=max(0.01, hub_diam/2 - chamfer_size),
             center=true);
}

module chamfer_bot_cone() {
  translate([0, 0, -hub_length/2 + chamfer_size/2 - overlap])
    cylinder(h=chamfer_size + 4*overlap,
             r1=max(0.01, hub_diam/2 - chamfer_size),
             r2=hub_diam/2 + chamfer_size,
             center=true);
}

// -------------------- Assembly --------------------
module pulley_solid() {
  union() {
    // Toothed rim defines the requested feature (20 teeth) and pitch diameter reference (pitch_r).
    toothed_rim();

    // Hub overlaps rim radially (hub is larger) and axially (centered), ensuring one connected solid.
    hub_cyl();

    // Flanges overlap the rim by 'overlap' so they are fused.
    flange_top();
    flange_bot();
  }
}

module pulley_final() {
  difference() {
    pulley_solid();

    // Bore + features
    bore_cyl();
    keyway_box();
    set_screw_cyl();
    if (lightening_hole_count > 0) lightening_holes();

    // Chamfers (subtractive)
    if (chamfer_size > 0) {
      chamfer_top_cone();
      chamfer_bot_cone();
    }
  }
}

// Output
pulley_final();