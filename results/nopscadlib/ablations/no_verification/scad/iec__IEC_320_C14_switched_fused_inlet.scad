$fn = 64;

// IEC switched fused inlet module (approximate), panel cutout 40.0 x 27.0 mm
// Model is ONE connected solid. Front face at z=0, body extends to -Z.

// -------------------- Parameters --------------------
panel_cutout_width  = 40.0;
panel_cutout_height = 27.0;

flange_width     = 50.0;
flange_height    = 35.0;
flange_thickness = 2.5;
bezel_thickness  = 1.5;

body_depth = 30.0;
body_wall  = 2.0;

mount_hole_diameter = 3.2;
mount_hole_pitch_x  = 44.0;
mount_hole_pitch_y  = 0.0;   // 0 => left/right holes

// Front features (visual/functional approximations)
switch_window_width  = 19.0;
switch_window_height = 13.0;

fuse_window_width    = 22.0;
fuse_window_height   = 12.0;

front_opening_depth  = 6.0;
switch_fuse_gap      = 2.0;

overlap = 1.0;

// IEC C14 inlet opening (approx)
inlet_w = 28.0;
inlet_h = 20.0;
inlet_chamfer = 2.2;

// Terminals (rear spades)
terminal_count     = 3;
terminal_width     = 6.3;
terminal_thickness = 0.8;
terminal_length    = 12.0;
terminal_pitch_x   = 8.0;
terminal_offset_y  = -6.0;

// -------------------- Helpers --------------------
module rrect(size=[10,10,2], r=1, center=true){
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, min(sx,sy)/2);
  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull(){
      for (x = [-sx/2+rr, sx/2-rr])
        for (y = [-sy/2+rr, sy/2-rr])
          translate([x,y,0]) cylinder(r=rr, h=sz, center=true);
    }
}

module chamfered_inlet_cavity(w=28, h=20, depth=10, chamfer=2){
  w2 = max(1, w - 2*chamfer);
  h2 = max(1, h - 2*chamfer);
  hull(){
    translate([0,0,-depth/2]) rrect([w,  h,  0.2], r=2.0, center=true);
    translate([0,0, depth/2]) rrect([w2, h2, 0.2], r=1.2, center=true);
  }
}

// -------------------- Main Solid --------------------
module iec_module_solid(){
  front_t = flange_thickness + bezel_thickness;

  body_w  = panel_cutout_width  + 2*body_wall;
  body_h  = panel_cutout_height + 2*body_wall;

  // Rear bulge (keeps silhouette closer to typical modules)
  bulge_w = body_w * 0.92;
  bulge_h = body_h * 0.92;
  bulge_d = body_depth * 0.35;

  union(){
    // Front flange/bezel
    translate([0,0, front_t/2])
      rrect([flange_width, flange_height, front_t], r=2.0, center=true);

    // Rear body (snap-in housing)
    translate([0,0, -body_depth/2])
      rrect([body_w, body_h, body_depth], r=1.5, center=true);

    // Front lip around cutout (bezel detail)
    lip_t = 1.2;
    lip_w = panel_cutout_width  + 6;
    lip_h = panel_cutout_height + 6;
    translate([0,0, lip_t/2])
      rrect([lip_w, lip_h, lip_t], r=1.5, center=true);

    // Rear bulge (connected with overlap)
    translate([0,0, -body_depth + bulge_d/2 - overlap])
      rrect([bulge_w, bulge_h, bulge_d], r=2.0, center=true);

    // Rear terminals (connected by overlap into rear body)
    term_z = -body_depth - terminal_length/2 + overlap;
    for (i = [0:terminal_count-1]){
      x = (i - (terminal_count-1)/2) * terminal_pitch_x;
      translate([x, terminal_offset_y, term_z])
        cube([terminal_width, terminal_thickness, terminal_length], center=true);
    }
  }
}

// -------------------- Cutouts (difference) --------------------
module iec_module_cutouts(){
  front_t = flange_thickness + bezel_thickness;

  // 1) Panel cutout opening through the front thickness (40x27)
  cutout_depth = front_t + 2*overlap;
  translate([0,0, front_t/2])
    rrect([panel_cutout_width, panel_cutout_height, cutout_depth], r=1.0, center=true);

  // 2) IEC C14 inlet cavity behind face (starts at z=0, goes into -Z)
  inlet_depth = min(14.0, body_depth - 4.0);
  translate([0,0, -inlet_depth/2 - overlap])
    chamfered_inlet_cavity(
      w=inlet_w, h=inlet_h,
      depth=inlet_depth + 2*overlap,
      chamfer=inlet_chamfer
    );

  // 3) Pin holes (3) inside cavity, extend deeper
  pin_r = 2.0;
  pin_pitch_x = 8.0;
  pin_y = -2.0;
  pin_depth = inlet_depth + 8.0;

  for (px = [-pin_pitch_x/2, pin_pitch_x/2]){
    translate([px, pin_y, -pin_depth/2 - overlap])
      cylinder(r=pin_r, h=pin_depth + 2*overlap, center=true);
  }
  translate([0, pin_y + 6.0, -pin_depth/2 - overlap])
    cylinder(r=pin_r, h=pin_depth + 2*overlap, center=true);

  // 4) Switch + fuse drawer windows on front face (open into body)
  sw_y =  (fuse_window_height/2 + switch_window_height/2 + switch_fuse_gap/2);
  fu_y = -(switch_window_height/2 + fuse_window_height/2 + switch_fuse_gap/2);

  translate([0, sw_y, front_opening_depth/2 - overlap])
    rrect([switch_window_width, switch_window_height, front_opening_depth + 2*overlap], r=1.0, center=true);

  translate([0, fu_y, front_opening_depth/2 - overlap])
    rrect([fuse_window_width, fuse_window_height, front_opening_depth + 2*overlap], r=1.0, center=true);

  // 5) Mounting holes through flange
  hole_h = front_t + 2*overlap;

  if (mount_hole_pitch_y == 0){
    for (sx = [-1, 1]){
      translate([sx*mount_hole_pitch_x/2, 0, front_t/2])
        cylinder(r=mount_hole_diameter/2, h=hole_h, center=true);
    }
  } else {
    for (sx = [-1, 1], sy = [-1, 1]){
      translate([sx*mount_hole_pitch_x/2, sy*mount_hole_pitch_y/2, front_t/2])
        cylinder(r=mount_hole_diameter/2, h=hole_h, center=true);
    }
  }
}

// -------------------- Assembly --------------------
difference(){
  iec_module_solid();
  iec_module_cutouts();
}