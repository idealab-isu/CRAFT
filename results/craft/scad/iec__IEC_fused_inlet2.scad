// IEC fused inlet (old style) - 36.0mm x 27.0mm panel cutout module
// One connected solid, with IEC C14 opening + fuse drawer recess + flange + bosses

$fn = 64;

// -------------------- Parameters --------------------
overall_width  = 36.0;   // panel cutout width (X)
overall_height = 27.0;   // panel cutout height (Y)

overlap = 0.6;           // small overlap to guarantee connectivity / robust booleans

// Front flange (visible bezel)
flange_width     = 44.0;
flange_height    = 34.0;
flange_thickness = 3.0;

// Panel interface lip (goes through panel cutout)
interface_lip_depth = 6.0;

// Main body behind panel
body_depth = 30.0;
body_wall  = 2.5;

// Fuse drawer bulge (side) - on RIGHT side (positive X)
fuse_bulge_width  = 14.0;
fuse_bulge_height = 18.0;
fuse_bulge_depth  = 16.0;

// Rear terminal zone
terminal_zone_width  = 28.0;
terminal_zone_height = 16.0;
terminal_zone_depth  = 10.0;

// Mounting
screw_pitch_x       = 32.0;
screw_pitch_y       = 22.0;
screw_hole_diameter = 3.2;
screw_boss_diameter = 7.0;
screw_boss_height   = 2.0;

// IEC C14 inlet opening (front face cut)
iec_open_w = 27.5;
iec_open_h = 20.0;
iec_open_corner_r = 2.0;
iec_open_depth = flange_thickness + interface_lip_depth + 2*overlap;

// IEC C14 "key" details (front face shallow recesses to look like a C14 inlet)
iec_key_recess_depth = 1.6;   // shallow recess into front face
iec_key_side_w       = 3.2;   // side key width
iec_key_top_h        = 2.6;   // top key height

// Fuse access recess (front face cut into fuse bulge)
fuse_access_recess_depth = 2.2;

// Fuse drawer opening size (front face cut)
fuse_open_w = fuse_bulge_width * 0.86;
fuse_open_h = fuse_bulge_height * 0.62;

// Fuse drawer "frame" recess (shallow, larger than opening)
fuse_frame_recess_depth = 1.2;
fuse_frame_margin = 1.2;

// Optional switch/holder detail (old fused inlet often has a small rectangular feature)
switch_feat_w = 10.0;
switch_feat_h = 6.0;
switch_feat_depth = 1.2;

// -------------------- Helpers --------------------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    for (sx = [-1, 1], sy = [-1, 1])
      translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
  }
}

module rounded_rect_prism(w, h, r, d, center=false) {
  linear_extrude(height=d, center=center)
    rounded_rect_2d(w, h, r);
}

// -------------------- Derived positions --------------------
flange_front_z = 0;
flange_center_z = -flange_thickness/2;

lip_center_z  = -(flange_thickness + interface_lip_depth/2) + overlap;
body_center_z = -(flange_thickness + interface_lip_depth + body_depth/2) + overlap;

body_outer_w = overall_width  + 2*body_wall;
body_outer_h = overall_height + 2*body_wall;

fuse_bulge_center_x = body_outer_w/2 + fuse_bulge_width/2 - overlap;
fuse_bulge_center_z = -(flange_thickness + interface_lip_depth + fuse_bulge_depth/2) + overlap;

terminal_center_z = -(flange_thickness + interface_lip_depth + body_depth) + terminal_zone_depth/2 + overlap;

// -------------------- Main solid (outer) --------------------
module outer_solid() {
  // Coordinate system:
  // Front face of flange at z=0, body extends to negative Z.
  union() {
    // Front flange bezel (z from -flange_thickness .. 0)
    translate([0, 0, flange_center_z])
      cube([flange_width, flange_height, flange_thickness], center=true);

    // Panel cutout interface lip (z from -flange_thickness-interface_lip_depth .. -flange_thickness)
    translate([0, 0, lip_center_z])
      cube([overall_width, overall_height, interface_lip_depth + 2*overlap], center=true);

    // Main body (z from -flange_thickness-interface_lip_depth-body_depth .. -flange_thickness-interface_lip_depth)
    translate([0, 0, body_center_z])
      cube([body_outer_w, body_outer_h, body_depth + 2*overlap], center=true);

    // Fuse bulge on right side (connected to body)
    translate([fuse_bulge_center_x, 0, fuse_bulge_center_z])
      cube([fuse_bulge_width, fuse_bulge_height, fuse_bulge_depth + 2*overlap], center=true);

    // Rear terminal zone (connected at back)
    translate([0, 0, terminal_center_z])
      cube([terminal_zone_width, terminal_zone_height, terminal_zone_depth + 2*overlap], center=true);

    // Screw bosses on front flange (connected)
    for (x = [-screw_pitch_x/2, screw_pitch_x/2])
      for (y = [-screw_pitch_y/2, screw_pitch_y/2])
        translate([x, y, -flange_thickness + screw_boss_height/2 + overlap])
          cylinder(d=screw_boss_diameter, h=screw_boss_height + 2*overlap, center=true);
  }
}

// -------------------- Subtractions (openings/recesses/holes) --------------------
module cutouts() {
  // IEC C14 opening through flange + lip (front)
  translate([0, 0, -iec_open_depth/2 + overlap])
    rounded_rect_prism(iec_open_w, iec_open_h, iec_open_corner_r, iec_open_depth + 2*overlap, center=true);

  // IEC C14 "key" recesses (shallow, only into flange face) to make it recognizable
  // Left and right side key recesses
  for (sx = [-1, 1]) {
    translate([
        sx*(iec_open_w/2 - iec_key_side_w/2),
        0,
        -iec_key_recess_depth/2 + overlap
      ])
      cube([iec_key_side_w, iec_open_h*0.78, iec_key_recess_depth + 2*overlap], center=true);
  }
  // Top key recess
  translate([0, (iec_open_h/2 - iec_key_top_h/2), -iec_key_recess_depth/2 + overlap])
    cube([iec_open_w*0.55, iec_key_top_h, iec_key_recess_depth + 2*overlap], center=true);

  // Fuse drawer frame recess (shallow, larger than opening) on front face into fuse bulge
  translate([
      fuse_bulge_center_x,
      0,
      -fuse_frame_recess_depth/2 + overlap
    ])
    cube([fuse_open_w + 2*fuse_frame_margin, fuse_open_h + 2*fuse_frame_margin, fuse_frame_recess_depth + 2*overlap], center=true);

  // Fuse drawer opening on front face into fuse bulge
  translate([
      fuse_bulge_center_x,
      0,
      -fuse_access_recess_depth/2 + overlap
    ])
    cube([fuse_open_w, fuse_open_h, fuse_access_recess_depth + 2*overlap], center=true);

  // Deeper pocket behind fuse opening (gives drawer depth impression)
  translate([
      fuse_bulge_center_x,
      0,
      -(flange_thickness + 0.35*interface_lip_depth)
    ])
    cube([fuse_open_w*0.95, fuse_open_h*0.95, flange_thickness + 0.9*interface_lip_depth], center=true);

  // Small switch/holder detail recess on flange (below IEC opening, centered)
  // (kept shallow so it reads as a feature without breaking the solid)
  translate([
      0,
      -(iec_open_h/2 - switch_feat_h/2) - 1.0,
      -switch_feat_depth/2 + overlap
    ])
    cube([switch_feat_w, switch_feat_h, switch_feat_depth + 2*overlap], center=true);

  // Mounting screw holes through flange + bosses
  for (x = [-screw_pitch_x/2, screw_pitch_x/2])
    for (y = [-screw_pitch_y/2, screw_pitch_y/2])
      translate([x, y, -flange_thickness/2])
        cylinder(d=screw_hole_diameter, h=flange_thickness + screw_boss_height + 4*overlap, center=true);
}

// -------------------- Assembly --------------------
difference() {
  outer_solid();
  cutouts();
}