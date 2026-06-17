// IEC fused inlet module (JR-101-1F style) - panel cutout 36.0mm x 27.0mm
// One connected solid; all translate() values derived from dimensions (no arbitrary offsets).

$fn = 72;

// ---------------- Parameters ----------------
cutout_W = 36.0;                 // panel cutout width (X)
cutout_H = 27.0;                 // panel cutout height (Y)

body_D   = 45.0;                 // depth behind panel (Z-)
flange_W = 44.0;
flange_H = 35.0;
flange_t = 2.5;

front_bezel_t = 3.0;             // thickness in front of panel plane (Z+)

panel_t = 2.0;                   // reference panel thickness (kept connected)
clip_clearance = 0.5;

wall_t = 2.0;
overlap = 1.0;                   // intentional overlap to guarantee connectivity

round_r = 0.6;                   // small edge rounding (avoid distorting openings)

// --- IEC C14 opening (recognizable) ---
c14_opening_W = 28.0;
c14_opening_H = 20.0;
c14_opening_corner_r = 2.2;

// C14 pin apertures (front face)
pin_slot_w = 6.2;
pin_slot_h = 4.2;
pin_slot_corner_r = 1.0;
pin_pitch_x = 10.0;              // L-N spacing
pin_pitch_y = 8.0;               // Earth offset

// --- Fuse drawer (front, above C14) ---
drawer_W = 18.0;
drawer_H = 10.0;
drawer_D = 16.0;

// Fuse drawer handle notch (front)
handle_notch_W = 10.0;
handle_notch_H = 2.2;

// Fuse cylinder detail (inside drawer)
fuse_cyl_r = 2.6;
fuse_cyl_L = 20.0;

// Rear terminal block volume
rear_block_W = 30.0;
rear_block_H = 22.0;
rear_block_D = 18.0;

// Terminal blades (rear)
blade_W = 6.3;
blade_t = 0.8;
blade_L = 12.0;
blade_spacing_X = 10.0;
blade_spacing_Y = 8.0;

// Screw holes in flange
screw_hole_r = 1.6;
screw_hole_edge_margin = 6.0;

// ---------------- Derived Z references (panel plane at z=0) ----------------
// Positive Z is "front/outside"; negative Z is "rear/inside".
z_bezel_center  =  front_bezel_t/2;
z_flange_center = -flange_t/2;
z_body_center   = -(flange_t + body_D/2 - overlap);
z_rear_center   = -(flange_t + body_D - rear_block_D/2 - overlap);

// ---------------- Helpers ----------------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  offset(r=r2) square([w-2*r2, h-2*r2], center=true);
}

module rounded_slot_3d(w, h, r, t) {
  linear_extrude(height=t, center=true)
    rounded_rect_2d(w, h, r);
}

// ---------------- Base solids ----------------
module inlet_main_body_raw() {
  // Body sized to fit through cutout with clearance
  translate([0, 0, z_body_center])
    cube([cutout_W - 2*clip_clearance, cutout_H - 2*clip_clearance, body_D], center=true);
}

module panel_mount_flange_raw() {
  translate([0, 0, z_flange_center])
    cube([flange_W, flange_H, flange_t], center=true);
}

module front_bezel_raw() {
  // Bezel protrudes in front of panel plane
  translate([0, 0, z_bezel_center])
    cube([flange_W - 2*wall_t, flange_H - 2*wall_t, front_bezel_t], center=true);
}

module rear_terminal_block_volume_raw() {
  translate([0, 0, z_rear_center])
    cube([rear_block_W, rear_block_H, rear_block_D], center=true);
}

// Fuse drawer body (protrudes behind front bezel into the body)
module fuse_drawer_body_raw() {
  y_drawer =  cutout_H/2 - drawer_H/2 - wall_t; // top area
  z_drawer_center = -(drawer_D/2 - overlap);     // starts at panel plane and goes rearward
  translate([0, y_drawer, z_drawer_center])
    cube([drawer_W, drawer_H, drawer_D], center=true);
}

// Retention clips (small tabs near drawer, connected to body)
module retention_clip_left_raw() {
  y_drawer =  cutout_H/2 - drawer_H/2 - wall_t;
  x_clip = -(cutout_W/2 - wall_t/2 - clip_clearance);
  z_clip = -(wall_t - overlap);
  translate([x_clip, y_drawer, z_clip])
    cube([wall_t, drawer_H, wall_t*2], center=true);
}

module retention_clip_right_raw() {
  y_drawer =  cutout_H/2 - drawer_H/2 - wall_t;
  x_clip =  (cutout_W/2 - wall_t/2 - clip_clearance);
  z_clip = -(wall_t - overlap);
  translate([x_clip, y_drawer, z_clip])
    cube([wall_t, drawer_H, wall_t*2], center=true);
}

// Rear terminal blades (connected to rear block)
module terminal_blade_raw(x, y) {
  z_blade_center = -(flange_t + body_D + blade_L/2 - overlap);
  translate([x, y, z_blade_center])
    cube([blade_W, blade_t, blade_L], center=true);
}

module terminal_blades_raw() {
  terminal_blade_raw(-blade_spacing_X/2, -blade_spacing_Y/2); // L
  terminal_blade_raw( blade_spacing_X/2, -blade_spacing_Y/2); // N
  terminal_blade_raw(0,                 blade_spacing_Y/2);   // E
}

// Fuse cylinder detail (inside drawer)
module fuse_detail_cyl_raw() {
  y_drawer =  cutout_H/2 - drawer_H/2 - wall_t;
  z_drawer_center = -(drawer_D/2 - overlap);
  translate([0, y_drawer, z_drawer_center])
    rotate([0, 90, 0])
      cylinder(r=fuse_cyl_r, h=fuse_cyl_L, center=true);
}

// Panel cutout reference (kept connected via overlap into bezel)
module panel_cutout_reference_raw() {
  z_panel_center = panel_t/2 - overlap; // overlaps into bezel by overlap
  translate([0, 0, z_panel_center])
    cube([cutout_W, cutout_H, panel_t], center=true);
}

// ---------------- Subtractions (openings/holes) ----------------
module c14_opening_profile_2d() {
  // C14 outline with small "key" notches at top corners (recognizable silhouette)
  // Built as union of a rounded rectangle + two small top-corner bumps.
  union() {
    rounded_rect_2d(c14_opening_W, c14_opening_H, c14_opening_corner_r);

    // Corner key bumps (inside the opening silhouette)
    bump_w = 4.0;
    bump_h = 3.0;
    x_b = c14_opening_W/2 - bump_w/2;
    y_b = c14_opening_H/2 - bump_h/2;
    translate([ x_b, y_b]) square([bump_w, bump_h], center=true);
    translate([-x_b, y_b]) square([bump_w, bump_h], center=true);
  }
}

module c14_opening_3d_raw() {
  // Place C14 opening in lower portion (below fuse drawer)
  y_c14 = -(cutout_H/2 - c14_opening_H/2 - wall_t);
  // Cut through bezel + flange (front to panel plane and slightly beyond)
  t = front_bezel_t + flange_t + 2*overlap;
  z_open_center = (front_bezel_t - flange_t)/2; // centered across bezel+flange stack
  translate([0, y_c14, z_open_center])
    linear_extrude(height=t, center=true)
      c14_opening_profile_2d();
}

module c14_pin_apertures_raw() {
  y_c14 = -(cutout_H/2 - c14_opening_H/2 - wall_t);
  t = front_bezel_t + flange_t + 2*overlap;
  z_open_center = (front_bezel_t - flange_t)/2;

  // L and N (bottom row)
  for (sx = [-1, 1]) {
    translate([sx*pin_pitch_x/2, y_c14 - pin_pitch_y/2, z_open_center])
      rounded_slot_3d(pin_slot_w, pin_slot_h, pin_slot_corner_r, t);
  }
  // Earth (top center)
  translate([0, y_c14 + pin_pitch_y/2, z_open_center])
    rounded_slot_3d(pin_slot_w, pin_slot_h, pin_slot_corner_r, t);
}

module fuse_drawer_opening_raw() {
  y_drawer =  cutout_H/2 - drawer_H/2 - wall_t;
  t = front_bezel_t + flange_t + 2*overlap;
  z_open_center = (front_bezel_t - flange_t)/2;

  // Main drawer opening
  translate([0, y_drawer, z_open_center])
    cube([drawer_W + 2*clip_clearance, drawer_H + 2*clip_clearance, t], center=true);

  // Small handle notch at top edge of drawer opening (adds recognizability)
  y_notch = y_drawer + (drawer_H + 2*clip_clearance)/2 - handle_notch_H/2;
  translate([0, y_notch, z_open_center])
    cube([handle_notch_W, handle_notch_H, t], center=true);
}

module screw_holes_raw() {
  xL = -(flange_W/2 - screw_hole_edge_margin);
  xR =  (flange_W/2 - screw_hole_edge_margin);
  translate([xL, 0, z_flange_center])
    cylinder(r=screw_hole_r, h=flange_t + 2*overlap, center=true);
  translate([xR, 0, z_flange_center])
    cylinder(r=screw_hole_r, h=flange_t + 2*overlap, center=true);
}

// ---------------- Assembly ----------------
module raw_solid() {
  union() {
    panel_mount_flange_raw();
    front_bezel_raw();
    inlet_main_body_raw();
    rear_terminal_block_volume_raw();

    fuse_drawer_body_raw();
    retention_clip_left_raw();
    retention_clip_right_raw();

    terminal_blades_raw();
    fuse_detail_cyl_raw();

    panel_cutout_reference_raw();
  }
}

module with_openings() {
  difference() {
    raw_solid();

    screw_holes_raw();

    // Front features
    fuse_drawer_opening_raw();
    c14_opening_3d_raw();
    c14_pin_apertures_raw();
  }
}

// Rounded outer edges (small; keep openings crisp)
module final_module() {
  minkowski() {
    with_openings();
    sphere(r=round_r);
  }
}

final_module();