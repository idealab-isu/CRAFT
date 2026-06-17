// Old unswitched mains socket (UK-style) — simplified but recognizable
// Single connected solid; all translate() values derived from dimensions

$fn = 64;

// ---------------- Parameters ----------------
plate_W = 86;
plate_H = 86;
plate_T = 3;

edge_bevel_inset = 2;
edge_bevel_drop  = 0.6;

// Shallow front dish (kept subtle so apertures remain visible)
recess_W = 62;
recess_H = 62;
recess_D = 0.9;

// Back housing (depth)
housing_W = 70;
housing_H = 70;
housing_D = 28;
housing_wall = 2.2;

// Socket cavity behind apertures (front-to-back)
cavity_W = 46;
cavity_H = 46;
cavity_D = 18;

// UK apertures (rectangular slots)
slot_w = 6.5;
slot_h = 14;
slot_depth = 12;

earth_w = 6.5;
earth_h = 10;
earth_depth = 12;

// Slot positions (UK: earth above, L/N below)
slot_x  = 12.7;
slot_y  = 9.5;
earth_y = 18;

// Mounting screws
screw_hole_d = 3.8;
screw_cbore_d = 7.5;
screw_cbore_depth = 1.2;
screw_hole_spacing = 60.3;

// Back-side screw bosses
boss_od = 10;
boss_id = 3.2;
boss_h  = 8;

// Raised front detailing (frame around apertures)
aperture_frame_T = 0.8;
aperture_frame_margin = 3.2;
aperture_frame_r = 2.0;

// Small overlap for robust booleans / unions
overlap = 1.2;

// ---------------- Helpers ----------------
module rounded_box(size=[10,10,10], r=1, center=true) {
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
    sphere(r=r);
  }
}

module faceplate_beveled() {
  hull() {
    cube([plate_W, plate_H, plate_T], center=true);
    translate([0,0,edge_bevel_drop/2])
      cube([plate_W-2*edge_bevel_inset, plate_H-2*edge_bevel_inset, plate_T-edge_bevel_drop], center=true);
  }
}

module front_recess_cut() {
  // Cut from the front face inward
  translate([0,0, plate_T/2 - recess_D/2])
    cube([recess_W, recess_H, recess_D + overlap], center=true);
}

module housing_outer() {
  // Plate back face is at z = -plate_T/2
  // Housing front face slightly overlaps into plate by overlap
  // => housing center z = (-plate_T/2 + overlap) - housing_D/2
  zc = (-plate_T/2 + overlap) - housing_D/2;
  translate([0,0, zc])
    rounded_box([housing_W, housing_H, housing_D], r=2, center=true);
}

module housing_inner_cut() {
  // Hollow from the back, leaving a front wall thickness = housing_wall
  inner_W = housing_W - 2*housing_wall;
  inner_H = housing_H - 2*housing_wall;
  inner_D = housing_D - housing_wall;

  // housing front face = (-plate_T/2 + overlap)
  // inner front face = housing front - housing_wall
  inner_front = (-plate_T/2 + overlap) - housing_wall;
  zc = inner_front - inner_D/2;

  translate([0,0, zc])
    cube([inner_W, inner_H, inner_D + overlap], center=true);
}

module socket_cavity_cut() {
  // Cavity starts at the front face and goes inward
  translate([0,0, plate_T/2 - cavity_D/2])
    cube([cavity_W, cavity_H, cavity_D + overlap], center=true);
}

module slot_cut(pos=[0,0], w=6, h=14, d=10) {
  // Cut from the front face inward
  translate([pos[0], pos[1], plate_T/2 - d/2])
    cube([w, h, d + overlap], center=true);
}

module screw_counterbore_cut(ypos) {
  translate([0, ypos, plate_T/2 - screw_cbore_depth/2])
    cylinder(h=screw_cbore_depth + overlap, r=screw_cbore_d/2, center=true);
}

module boss_at(ypos) {
  // Place bosses just behind the housing inner front wall so they survive inner hollowing
  housing_front = (-plate_T/2 + overlap);
  inner_front   = housing_front - housing_wall;

  // Boss should be behind inner_front by a small amount, but still inside housing
  zc = inner_front - overlap - boss_h/2;

  translate([0, ypos, zc])
    difference() {
      cylinder(h=boss_h, r=boss_od/2, center=true);
      cylinder(h=boss_h + overlap, r=boss_id/2, center=true);
    }
}

module aperture_frame() {
  // Raised frame around the three apertures (front detailing)
  frame_W = 2*slot_x + slot_w + 2*aperture_frame_margin;
  frame_H = (earth_y + earth_h/2) - (-slot_y - slot_h/2) + 2*aperture_frame_margin;

  // Sit on the front face with slight overlap into plate
  zc = plate_T/2 + aperture_frame_T/2 - overlap/2;

  translate([0, 0, zc])
    difference() {
      rounded_box([frame_W, frame_H, aperture_frame_T], r=aperture_frame_r, center=true);
      rounded_box([frame_W - 2*aperture_frame_margin,
                   frame_H - 2*aperture_frame_margin,
                   aperture_frame_T + overlap],
                  r=max(0.5, aperture_frame_r-0.8), center=true);
    }
}

// ---------------- Build ----------------
module socket_solid() {
  union() {
    faceplate_beveled();
    housing_outer();

    // Raised frame (makes it read as a socket, not a rocker)
    aperture_frame();

    // Back bosses aligned with screw holes
    boss_at( screw_hole_spacing/2);
    boss_at(-screw_hole_spacing/2);
  }
}

module socket_model() {
  difference() {
    socket_solid();

    // Shallow front recess (dish)
    front_recess_cut();

    // Hollow housing from back (keeps walls)
    housing_inner_cut();

    // Socket cavity behind apertures
    socket_cavity_cut();

    // UK apertures: L/N vertical slots, earth vertical slot above
    slot_cut([ -slot_x, -slot_y], slot_w, slot_h, slot_depth);
    slot_cut([  slot_x, -slot_y], slot_w, slot_h, slot_depth);
    slot_cut([0, earth_y], earth_w, earth_h, earth_depth);

    // Mounting screw holes through + shallow counterbore on front
    translate([0,  screw_hole_spacing/2, 0])
      cylinder(h=plate_T + housing_D + 2*overlap, r=screw_hole_d/2, center=true);
    translate([0, -screw_hole_spacing/2, 0])
      cylinder(h=plate_T + housing_D + 2*overlap, r=screw_hole_d/2, center=true);

    screw_counterbore_cut( screw_hole_spacing/2);
    screw_counterbore_cut(-screw_hole_spacing/2);
  }
}

// Final
color("Silver") socket_model();