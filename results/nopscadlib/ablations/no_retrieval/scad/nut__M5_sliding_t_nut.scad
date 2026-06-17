// T-slot nut for 5.0mm screw, 6.0mm across-flats hex, 3.7mm thick
// Structural fix: make the part recognizable as a T-slot nut by adding a stepped/undercut profile
// and a centered M5 through-hole + hex socket. All solids are connected with explicit overlap.

$fn = 96;

// -------- Parameters (mm) --------
nut_thickness = 3.7;      // total Z thickness
screw_d       = 5.0;      // through hole diameter representation (M5 clearance-style)
hex_af        = 6.0;      // across flats for hex socket
hex_depth     = 2.2;      // depth of hex socket from top face

// Overall planform (X length) and widths (Y) for a simplified T-slot nut
t_len     = 12.0;         // overall length (X)
head_w    = 8.0;          // top/head width (Y) - engages slot lips
tongue_w  = 6.0;          // bottom/tongue width (Y) - slides in slot channel (<= head_w)
step_h    = 1.4;          // height of the bottom tongue (Z). Remaining is head height.

chamfer   = 0.25;         // small edge chamfer
overlap   = 1.2;          // overlap for robust solid connections (1-2mm as requested)

// -------- Helpers --------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// across-flats -> circumradius for regular hex
function hex_R_from_AF(af) = af / sqrt(3);

module hex2d(af){
  R = hex_R_from_AF(af);
  polygon([ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// Rounded rectangle outline using offset on a rectangle
module rect2d(len, wid, r=0){
  rr = clamp(r, 0, min(len, wid)/2 - 0.01);
  if (rr <= 0)
    square([len, wid], center=true);
  else
    offset(r=rr) square([len-2*rr, wid-2*rr], center=true);
}

// Chamfered extrusion by blending offsets along Z (robust)
module chamfered_extrude_2d(h, c){
  c2 = clamp(c, 0, h/2 - 0.001);

  if (c2 <= 0){
    linear_extrude(height=h, center=true) children();
  } else {
    // Middle straight section
    linear_extrude(height=h-2*c2, center=true)
      offset(delta=-c2) children();

    // Top chamfer blend
    hull(){
      translate([0,0, (h/2 - c2) - overlap/2])
        linear_extrude(height=overlap, center=true)
          offset(delta=-c2) children();
      translate([0,0, (h/2) - overlap/2])
        linear_extrude(height=overlap, center=true)
          offset(delta=0) children();
    }

    // Bottom chamfer blend
    hull(){
      translate([0,0, (-h/2) + overlap/2])
        linear_extrude(height=overlap, center=true)
          offset(delta=0) children();
      translate([0,0, (-h/2 + c2) + overlap/2])
        linear_extrude(height=overlap, center=true)
          offset(delta=-c2) children();
    }
  }
}

// -------- Model --------
module tslot_nut(){
  // Keep a clear T-profile: narrower tongue + wider head, total thickness fixed at 3.7mm
  step_h_eff = clamp(step_h, 0.8, nut_thickness - 0.8);
  head_h     = nut_thickness - step_h_eff;

  corner_r = 0.6;

  c_head   = clamp(chamfer, 0, head_h/2 - 0.001);
  c_tongue = clamp(chamfer, 0, step_h_eff/2 - 0.001);

  // Z placement: make the union exactly span [-nut_thickness/2, +nut_thickness/2]
  // and ensure head and tongue overlap by "overlap" for a single watertight solid.
  z_tongue = -nut_thickness/2 + step_h_eff/2;
  z_head   =  nut_thickness/2 - head_h/2;

  difference(){
    union(){
      // Bottom/tongue block (narrower) - slides in slot channel
      translate([0,0, z_tongue])
        chamfered_extrude_2d(step_h_eff + overlap, c_tongue)
          rect2d(t_len, tongue_w, corner_r);

      // Top/head block (wider) - captures under slot lips
      translate([0,0, z_head])
        chamfered_extrude_2d(head_h + overlap, c_head)
          rect2d(t_len, head_w, corner_r);
    }

    // Through hole for 5.0mm screw (centered)
    cylinder(h=nut_thickness + 2*overlap, r=screw_d/2, center=true);

    // Hex socket from top face (6.0mm AF), cut into the head
    // Place so its top is flush with the top surface, and it extends downward by hex_depth.
    translate([0,0, nut_thickness/2 - hex_depth/2])
      linear_extrude(height=hex_depth + overlap, center=true)
        hex2d(hex_af);

    // Lead-in chamfers for the hole (top and bottom)
    lead = min(0.45, nut_thickness/2 - 0.05);

    // Top lead-in (touching top face)
    translate([0,0, nut_thickness/2 - lead])
      cylinder(h=2*lead + overlap, r1=screw_d/2 + lead, r2=screw_d/2, center=true);

    // Bottom lead-in (touching bottom face)
    translate([0,0, -nut_thickness/2 + lead])
      cylinder(h=2*lead + overlap, r1=screw_d/2, r2=screw_d/2 + lead, center=true);
  }
}

tslot_nut();