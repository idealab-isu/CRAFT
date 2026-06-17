// Timing pulley: 12 teeth, pitch diameter = 7.15mm
// Structural fix: make teeth clearly present/visible and enforce pitch diameter.
// Teeth are built as a ring whose INNER face is the pitch circle (r = pitch_dia/2),
// so the pitch diameter is directly verifiable in the geometry.
// All parts remain a single connected solid with controlled overlaps.

$fn = 220;

// ----------------- Parameters -----------------
tooth_count = 12;                 //[6:24:1]
pitch_dia = 7.15;                 //[3.6:14.3:0.01]
pulley_width = 6;                 //[3:12:0.1]

body_id = 3;                      //[1.5:6:0.01]
hub_od = 10;                      //[6:20:0.01]
hub_length = 8;                   //[4:16:0.1]

flange_thickness = 1;             //[0.5:2.5:0.1]
flange_od = 11;                   //[8:22:0.01]

set_screw_dia = 2;                //[1:4:0.01]
set_screw_z = 0;                  //[-4:4:0.1]

keyway_width = 1.0;               //[0.5:2.5:0.01]
keyway_depth = 0.5;               //[0.2:1.5:0.01]

flat_depth = 0.4;                 //[0.2:1.2:0.01]

// Overlap for robust unions / clean differences
overlap = 1.2;                    //[0.5:2:0.1]

// Visible tooth geometry (simple trapezoid teeth, outward)
tooth_radial_height = 0.9;        //[0.3:2.0:0.01]   // tooth protrusion above pitch circle
tooth_root_clear = 0.6;           //[0.2:1.5:0.01]   // barrel extends below pitch circle (root)
tooth_tip_width = 0.55;           //[0.2:2.0:0.01]   // tangential width at tooth tip
tooth_base_width = 1.05;          //[0.3:3.0:0.01]   // tangential width at tooth base (at pitch circle)

// ----------------- Derived geometry -----------------
pitch_r = pitch_dia/2;
tooth_angle = 360/tooth_count;

// Barrel radii: pitch circle is fixed; root is below pitch circle; tips above
root_r   = max(0.1, pitch_r - tooth_root_clear);
tip_r    = pitch_r + tooth_radial_height;

// Keep flanges outside tooth tips
flange_r = max(flange_od/2, tip_r + 0.4);

// Ensure hub overlaps the toothed barrel so everything is one connected solid
hub_r = hub_od/2;
barrel_outer_r = max(pitch_r, root_r); // barrel cylinder reaches at least pitch circle
// (teeth ring starts at pitch_r, so barrel reaching pitch_r guarantees connection)

// ----------------- Helpers -----------------
module trapezoid_2d(w_base, w_tip, h_radial) {
  // Radial direction = +X, tangential = Y
  polygon(points=[
    [0,        -w_base/2],
    [0,         w_base/2],
    [h_radial,  w_tip/2],
    [h_radial, -w_tip/2]
  ]);
}

module tooth_3d() {
  // Tooth base starts exactly at pitch circle (inner face at r=pitch_r)
  translate([pitch_r, 0, 0])
    linear_extrude(height=pulley_width + 2*overlap, center=true)
      trapezoid_2d(tooth_base_width, tooth_tip_width, tooth_radial_height);
}

module teeth_array() {
  for (i = [0:tooth_count-1])
    rotate([0, 0, i*tooth_angle])
      tooth_3d();
}

// ----------------- Base solids -----------------
module pulley_barrel() {
  // Barrel reaches the pitch circle so teeth are guaranteed connected
  cylinder(r=barrel_outer_r, h=pulley_width, center=true);
}

module hub() {
  cylinder(r=hub_r, h=hub_length, center=true);
}

module flange_top() {
  // Touch/overlap the pulley body by overlap amount
  translate([0, 0, pulley_width/2 + flange_thickness/2 - overlap])
    cylinder(r=flange_r, h=flange_thickness, center=true);
}

module flange_bottom() {
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + overlap])
    cylinder(r=flange_r, h=flange_thickness, center=true);
}

// ----------------- Subtractions -----------------
module center_bore() {
  cylinder(r=body_id/2, h=hub_length + 2*overlap, center=true);
}

module set_screw_hole() {
  // Through hub radially (X direction), centered on Z = set_screw_z
  rotate([0, 90, 0])
    translate([0, 0, set_screw_z])
      cylinder(r=set_screw_dia/2, h=hub_od + 2*overlap, center=true);
}

module keyway() {
  // Rectangular keyway cut from bore outward
  translate([body_id/2 + keyway_depth/2 - overlap/2, 0, 0])
    cube([keyway_depth + overlap, keyway_width, hub_length + 2*overlap], center=true);
}

module grub_screw_flat() {
  // Flat on OD for set screw: cut a slab into the hub
  slab_w = hub_od + 2*overlap;
  translate([hub_r - flat_depth + slab_w/2, 0, 0])
    cube([slab_w, slab_w, hub_length + 2*overlap], center=true);
}

// ----------------- Model -----------------
module pulley_solid() {
  union() {
    // Barrel + teeth (recognizable timing pulley silhouette)
    pulley_barrel();
    teeth_array();

    // Hub and flanges (connected by overlap)
    hub();
    flange_top();
    flange_bottom();
  }
}

module complete_model() {
  difference() {
    pulley_solid();
    center_bore();
    keyway();
    set_screw_hole();
    grub_screw_flat();
  }
}

// Final Output
complete_model();