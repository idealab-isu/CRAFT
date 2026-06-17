// Sheet MDF (single connected solid)

// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400;  //[200:800:1]
sheet_thickness = 18; //[9:36:1]

corner_radius = 8; //[2:20:1]

chamfer_size = 1.5; //[0.5:4:0.5]
chamfer_inset = 6;  //[2:20:1]

grain_depth = 0.3; //[0.1:1:0.1]
grain_pitch = 20;  //[8:60:1]
grain_groove_width = 1.2; //[0.6:3:0.1]
grain_margin = 12; //[5:30:1]

mark_diameter = 12; //[6:30:1]
mark_depth = 0.6;   //[0.2:2:0.1]
mark_offset_x = 30; //[10:120:1]
mark_offset_y = 30; //[10:120:1]

overlap = 1; //[0.5:2:0.5]
$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// MDF-like color (visual only; geometry unchanged)
mdf_col = [0.72, 0.62, 0.45];

// Base: rounded-rectangle prism (true rounded corners, no floating parts)
module rounded_sheet(L, W, T, R) {
  R2 = clamp(R, 0, min(L, W)/2);
  linear_extrude(height=T, center=true)
    offset(r=R2)
      square([L - 2*R2, W - 2*R2], center=true);
}

// Subtractive features (kept shallow so sheet remains one connected solid)
module edge_chamfer_recess() {
  // Top and bottom shallow recesses inset from edges
  recess_xy = [sheet_length - 2*chamfer_inset, sheet_width - 2*chamfer_inset];
  recess_z  = chamfer_size + overlap;

  translate([0, 0,  sheet_thickness/2 - recess_z/2])
    cube([recess_xy[0], recess_xy[1], recess_z], center=true);

  translate([0, 0, -sheet_thickness/2 + recess_z/2])
    cube([recess_xy[0], recess_xy[1], recess_z], center=true);
}

module surface_texture_grain() {
  // Grooves on top face only, within margins
  usable_w = sheet_width - 2*grain_margin;
  n = max(0, floor(usable_w / grain_pitch));

  groove_len = sheet_length - 2*grain_margin;
  groove_h   = grain_depth + overlap;

  for (i = [0 : n]) {
    y = -sheet_width/2 + grain_margin + i*grain_pitch;
    translate([0, y, sheet_thickness/2 - groove_h/2])
      cube([groove_len, grain_groove_width, groove_h], center=true);
  }
}

module marking() {
  // Small shallow circular pocket on top face
  pocket_h = mark_depth + overlap;
  translate([
      -sheet_length/2 + mark_offset_x,
      -sheet_width/2  + mark_offset_y,
      sheet_thickness/2 - pocket_h/2
    ])
    cylinder(r=mark_diameter/2, h=pocket_h, center=true);
}

module subtractive_features() {
  union() {
    edge_chamfer_recess();
    surface_texture_grain();
    marking();
  }
}

// Final Output
color(mdf_col)
difference() {
  rounded_sheet(sheet_length, sheet_width, sheet_thickness, corner_radius);
  subtractive_features();
}