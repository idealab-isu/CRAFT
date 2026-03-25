// Small U-shaped bracket/clip with rounded outer back, open front channel,
// opposing internal bosses/holes, and front-edge tabs/lips.
// Bounding box target: 22.1 x 24.3 x 79.0 mm (X x Y x Z)

$fn = 96;

// Parameters
bbox_x = 22.15;
bbox_y = 24.3;
bbox_z = 79;

wall_t = 1.6;

channel_w = 14;          // inner channel width (X)
channel_d = 16;          // inner channel depth from front opening inward (Y)

back_outer_r = 11;       // outer back rounding radius (approx bbox_x/2)

front_opening_w = 12;    // opening width at front (X), leaves lips

boss_outer_d = 6;
boss_hole_d  = 3.2;
boss_len_each_side = 3;  // boss protrusion into channel from each side wall

boss_z_offset_top = 14;
boss_z_offset_bottom = 14;

tab_thickness = 1.2;     // along Y at the front edge
tab_depth_inward = 1.5;  // along X (lip width)
tab_height = 6;          // along Z

clearance = 0.3;
overlap = 0.6;           // small overlap to ensure watertight unions/differences

// Derived
outer_x = bbox_x;
outer_y = bbox_y;
outer_z = bbox_z;

inner_x = channel_w;
inner_y = channel_d;
inner_z = outer_z + 2*overlap;

// Place the inner channel so it opens at the front face ( +Y )
inner_center_y = outer_y/2 - inner_y/2 + overlap;

// Rounded back: add a cylinder at the back ( -Y ) to make the exterior rounded
back_cyl_r = back_outer_r;
back_cyl_center_y = -outer_y/2 + back_cyl_r;

// Boss centerline Y: inside the channel, near the back of the channel
boss_center_y = (outer_y/2 - inner_y) + boss_outer_d/2 + wall_t;

// Boss Z positions
boss_z_top =  outer_z/2 - boss_z_offset_top;
boss_z_bot = -outer_z/2 + boss_z_offset_bottom;

// Boss X positions (inside faces of side walls)
boss_x_left  = -inner_x/2 + boss_len_each_side/2 - overlap;
boss_x_right =  inner_x/2 - boss_len_each_side/2 + overlap;

// Front tabs: small lips at the open end, near +Y face, centered around Z=0
tab_center_y = outer_y/2 - tab_thickness/2 + overlap;
tab_z_center = 0;

// --- Base solids/cutters ---

module outer_shell() {
  // Outer body with rounded back
  union() {
    cube([outer_x, outer_y, outer_z], center=true);
    translate([0, back_cyl_center_y, 0])
      cylinder(r=back_cyl_r, h=outer_z, center=true);
  }
}

module inner_channel_cut() {
  // Main U-channel void (open at +Y)
  translate([0, inner_center_y, 0])
    cube([inner_x, inner_y, inner_z], center=true);
}

module front_opening_relief_cut() {
  // Widen the opening slightly to make the "U" read clearly in silhouette
  // (keeps lips by using front_opening_w < channel_w)
  translate([0, 0, 0])
    translate([0, outer_y/2 - inner_y/2 + overlap, 0])
      cube([front_opening_w, inner_y + 2*overlap, inner_z], center=true);
}

module boss_solid_at(zpos) {
  // Two opposing cylindrical bosses protruding inward from side walls
  union() {
    translate([boss_x_left,  boss_center_y, zpos])
      rotate([0,90,0])
        cylinder(d=boss_outer_d, h=boss_len_each_side + 2*overlap, center=true);

    translate([boss_x_right, boss_center_y, zpos])
      rotate([0,90,0])
        cylinder(d=boss_outer_d, h=boss_len_each_side + 2*overlap, center=true);
  }
}

module boss_hole_cut_at(zpos) {
  // Through-hole across the channel (X direction), passing through both bosses
  translate([0, boss_center_y, zpos])
    rotate([0,90,0])
      cylinder(d=boss_hole_d, h=inner_x + 2*boss_len_each_side + 6*overlap, center=true);
}

module front_tabs() {
  // Two small lips at the front opening edges (left/right)
  union() {
    translate([-front_opening_w/2 + tab_depth_inward/2 - overlap, tab_center_y, tab_z_center])
      cube([tab_depth_inward + 2*overlap, tab_thickness + 2*overlap, tab_height], center=true);

    translate([ front_opening_w/2 - tab_depth_inward/2 + overlap, tab_center_y, tab_z_center])
      cube([tab_depth_inward + 2*overlap, tab_thickness + 2*overlap, tab_height], center=true);
  }
}

module lead_in_taper_cut() {
  // Small lead-in chamfer at the front opening to emphasize the open channel
  // Implemented as a wedge cut that removes material just inside the front face.
  taper_len = 8;
  taper_h = wall_t + tab_thickness;

  translate([0, outer_y/2 - taper_h/2 + overlap, 0])
    rotate([90,0,90])
      linear_extrude(height=front_opening_w + 2*tab_depth_inward + 4*overlap, center=true)
        polygon(points=[
          [0, 0],
          [taper_len, 0],
          [taper_len, taper_h],
          [0, wall_t]
        ]);
}

module lightening_cutout() {
  // Optional internal window from the back side (kept conservative to avoid breaking walls)
  lighten_window_w = 10;
  lighten_window_h = 18;
  lighten_window_depth = 6;

  translate([0, -outer_y/2 + (lighten_window_depth/2 + wall_t), 0])
    cube([lighten_window_w, lighten_window_depth, lighten_window_h], center=true);
}

// --- Final model ---

module model() {
  difference() {
    union() {
      // Main outer shell
      outer_shell();

      // Add bosses and tabs as positive features (connected to shell)
      boss_solid_at(boss_z_top);
      boss_solid_at(boss_z_bot);
      front_tabs();
    }

    // Carve the U-channel and opening
    inner_channel_cut();
    front_opening_relief_cut();

    // Boss holes
    boss_hole_cut_at(boss_z_top);
    boss_hole_cut_at(boss_z_bot);

    // Lead-in taper at opening
    lead_in_taper_cut();

    // Lightening window (kept inside)
    lightening_cutout();
  }
}

model();