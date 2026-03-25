// Dimension-calibrated (target: 0.03 x 0.02 x 0.03 mm)
scale([0.000500, 0.000929, 0.000276])
{
// U-frame bracket with circular end plates and windowed crossbar
// Units: mm

$fn = 128;

// -------------------- Parameters --------------------
crossbar_len = 60;
crossbar_w   = 12;
crossbar_h   = 4;

plate_D      = 28;
plate_th     = 6;
plate_rise   = 26;   // height of cheeks above crossbar top

hole_D       = 16;

small_cutout_D        = 4;
small_cutout_offset_r = 8;

win_len   = 16;
win_w     = 6;

diamond_w = 10;
diamond_h = 10;

overlap   = 0.4;   // ensures connectivity / robust booleans
cut_depth = 200;   // through-cuts

// -------------------- Derived --------------------
plate_r = plate_D/2;

x_left  = -crossbar_len/2 + plate_th/2;
x_right =  crossbar_len/2 - plate_th/2;

// Place crossbar so its TOP is at z=0, and cheeks rise upward (+z)
z_crossbar_center = -crossbar_h/2;

// End plates: their centers sit at z = plate_r so their bottom is at z=0
z_plate_center = plate_r;

// -------------------- Helpers --------------------
module diamond_prism(w, h, t, center=true) {
  linear_extrude(height=t, center=center)
    polygon(points=[
      [ 0,  h/2],
      [ w/2, 0],
      [ 0, -h/2],
      [-w/2, 0]
    ]);
}

module end_plate_at(xpos) {
  // Plate is a disk in YZ plane (extruded along X)
  translate([xpos, 0, z_plate_center])
    rotate([0, 90, 0])
      cylinder(r=plate_r, h=plate_th, center=true);
}

module end_plate_cuts_at(xpos) {
  translate([xpos, 0, z_plate_center])
    rotate([0, 90, 0]) {
      // central opening
      cylinder(r=hole_D/2, h=cut_depth, center=true);

      // small cutouts (3)
      translate([0,  small_cutout_offset_r, 0])
        cylinder(r=small_cutout_D/2, h=cut_depth, center=true);
      translate([0, -small_cutout_offset_r, 0])
        cylinder(r=small_cutout_D/2, h=cut_depth, center=true);
      translate([0, 0,  small_cutout_offset_r])
        cylinder(r=small_cutout_D/2, h=cut_depth, center=true);
    }
}

module crossbar_solid() {
  translate([0, 0, z_crossbar_center])
    cube([crossbar_len, crossbar_w, crossbar_h], center=true);
}

module crossbar_windows() {
  // Cut windows through crossbar thickness (Z)
  // Left and right rectangular windows
  translate([-crossbar_len/4, 0, z_crossbar_center])
    cube([win_len, win_w, cut_depth], center=true);

  translate([ crossbar_len/4, 0, z_crossbar_center])
    cube([win_len, win_w, cut_depth], center=true);

  // Center diamond window
  translate([0, 0, z_crossbar_center])
    rotate([0, 0, 45])
      diamond_prism(diamond_w, diamond_h, cut_depth, center=true);
}

module cheeks() {
  // Two vertical side cheeks rising from crossbar top (z=0) to z=plate_rise
  // They overlap slightly into the crossbar for a single connected solid.
  cheek_h = plate_rise + overlap;
  cheek_z = cheek_h/2 - overlap/2; // bottom slightly below z=0

  union() {
    translate([x_left, 0, cheek_z])
      cube([plate_th, plate_D, cheek_h], center=true);

    translate([x_right, 0, cheek_z])
      cube([plate_th, plate_D, cheek_h], center=true);
  }
}

// -------------------- Final Model --------------------
difference() {
  union() {
    crossbar_solid();
    cheeks();

    // Circular end plates at the top of cheeks
    // Centered at z=plate_rise + plate_r so their bottom touches z=plate_rise
    translate([0, 0, plate_rise])
      union() {
        end_plate_at(x_left);
        end_plate_at(x_right);
      }
  }

  // Crossbar windows
  crossbar_windows();

  // End plate openings/cutouts
  translate([0, 0, plate_rise]) {
    end_plate_cuts_at(x_left);
    end_plate_cuts_at(x_right);
  }
}
}
