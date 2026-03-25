$fn = 64;

// Parameters
faceplate_width_mm = 86; //[60:172:1]
faceplate_height_mm = 86; //[60:172:1]
overall_depth_mm = 12; //[6:24:1]
faceplate_thickness_mm = 3; //[2:6:1]
top_taper_width_mm = 80; //[50:160:1]
top_taper_height_mm = 80; //[50:160:1]
pin_hole_clearance_mm = 0.6; //[0.2:1.5:0.1]
pin_aperture_depth_mm = 8; //[4:16:1]
mounting_screw_hole_spacing_mm = 60.3; //[45:120:0.1]
mounting_hole_diameter_mm = 3.8; //[2.5:6:0.1]
counterbore_diameter_mm = 8.5; //[6:14:0.1]
counterbore_depth_mm = 2; //[1:5:0.1]
rear_cavity_wall_mm = 2; //[1:5:0.1]
rear_cavity_depth_mm = 8; //[4:20:1]
rear_cavity_corner_radius_mm = 6; //[2:15:0.5]
socket_offset_x_mm = 0; //[-10:10:0.1]
socket_offset_y_mm = -6; //[-20:20:0.1]
bs1363_live_neutral_x_mm = 11.1; //[9:14:0.1]
bs1363_ln_y_mm = -11.1; //[-14:-9:0.1]
bs1363_earth_y_mm = 11.1; //[9:14:0.1]
ln_hole_width_mm = 7; //[5:10:0.1]
ln_hole_height_mm = 4.5; //[3:7:0.1]
earth_hole_width_mm = 4.5; //[3:7:0.1]
earth_hole_height_mm = 8.5; //[6:12:0.1]
switch_offset_x_mm = 0; //[-15:15:0.1]
switch_offset_y_mm = 22; //[5:35:0.1]
switch_body_width_mm = 40; //[25:70:0.5]
switch_body_height_mm = 20; //[12:35:0.5]
switch_body_thickness_mm = 2; //[1:5:0.1]
switch_recess_depth_mm = 0.8; //[0:2:0.1]
switch_recess_margin_mm = 1.5; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// NEW: screw/fastener ring parameters (front-visible, physically attached)
screw_ring_outer_d_mm = 12;   //[8:20:0.1]
screw_ring_inner_d_mm = 6.5;  //[4:12:0.1]
screw_ring_height_mm  = 1.6;  //[0.8:4:0.1]
screw_ring_offset_x_mm = 0;
screw_ring_offset_y_mm = -mounting_screw_hole_spacing_mm/2; // bottom screw position

// Helpers
module rounded_rect_prism(size=[10,10,2], r=2, center=true) {
  x = size[0]; y = size[1]; z = size[2];
  r2 = min(r, min(x,y)/2 - 0.01);
  linear_extrude(height=z, center=center)
    offset(r=r2)
      square([x-2*r2, y-2*r2], center=true);
}

module faceplate_solid() {
  // Slightly domed/tapered faceplate using hull between two rectangles
  hull() {
    translate([0,0,0])
      rounded_rect_prism([faceplate_width_mm, faceplate_height_mm, overall_depth_mm], r=3, center=true);
    translate([0,0,0])
      rounded_rect_prism([top_taper_width_mm, top_taper_height_mm, overall_depth_mm], r=3, center=true);
  }
}

module rear_cavity_cut() {
  cavity_w = faceplate_width_mm - 2*rear_cavity_wall_mm;
  cavity_h = faceplate_height_mm - 2*rear_cavity_wall_mm;

  cavity_depth = min(rear_cavity_depth_mm, max(0.1, overall_depth_mm - faceplate_thickness_mm));
  zc = -overall_depth_mm/2 + cavity_depth/2;

  translate([0,0,zc])
    rounded_rect_prism([cavity_w, cavity_h, cavity_depth + overlap_mm], r=rear_cavity_corner_radius_mm, center=true);
}

module bs1363_pin_apertures_cut() {
  hole_zc = overall_depth_mm/2 - (pin_aperture_depth_mm + overlap_mm)/2;

  for (sx = [-1, 1]) {
    translate([socket_offset_x_mm + sx*bs1363_live_neutral_x_mm,
               socket_offset_y_mm + bs1363_ln_y_mm,
               hole_zc])
      rounded_rect_prism(
        [ln_hole_width_mm + 2*pin_hole_clearance_mm,
         ln_hole_height_mm + 2*pin_hole_clearance_mm,
         pin_aperture_depth_mm + overlap_mm],
        r=0.8,
        center=true
      );
  }

  translate([socket_offset_x_mm,
             socket_offset_y_mm + bs1363_earth_y_mm,
             hole_zc])
    rounded_rect_prism(
      [earth_hole_width_mm + 2*pin_hole_clearance_mm,
       earth_hole_height_mm + 2*pin_hole_clearance_mm,
       pin_aperture_depth_mm + overlap_mm],
      r=0.8,
      center=true
    );
}

module mounting_holes_cut() {
  for (sy = [-1, 1]) {
    translate([0, sy*mounting_screw_hole_spacing_mm/2, 0])
      cylinder(r=mounting_hole_diameter_mm/2, h=overall_depth_mm + 2*overlap_mm, center=true);

    translate([0, sy*mounting_screw_hole_spacing_mm/2,
               overall_depth_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
      cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
  }
}

module switch_recess_cut() {
  zc = overall_depth_mm/2 - (switch_recess_depth_mm + overlap_mm)/2;
  translate([switch_offset_x_mm, switch_offset_y_mm, zc])
    rounded_rect_prism(
      [switch_body_width_mm + 2*switch_recess_margin_mm,
       switch_body_height_mm + 2*switch_recess_margin_mm,
       switch_recess_depth_mm + overlap_mm],
      r=2,
      center=true
    );
}

module switch_rocker_solid() {
  // Ensure rocker is NOT floating:
  // Place it so its bottom face penetrates into the faceplate by overlap_mm.
  // Faceplate front surface is at +overall_depth_mm/2.
  zc = overall_depth_mm/2 - switch_body_thickness_mm/2 + overlap_mm;

  translate([switch_offset_x_mm, switch_offset_y_mm, zc])
    rounded_rect_prism(
      [switch_body_width_mm, switch_body_height_mm, switch_body_thickness_mm],
      r=2,
      center=true
    );
}

module screw_fastener_ring_solid() {
  // Create a visible ring around the bottom mounting screw and attach it by overlap.
  // Ring sits on the front face and penetrates into the plate by overlap_mm.
  zc = overall_depth_mm/2 - screw_ring_height_mm/2 + overlap_mm;

  translate([screw_ring_offset_x_mm, screw_ring_offset_y_mm, zc])
    difference() {
      cylinder(d=screw_ring_outer_d_mm, h=screw_ring_height_mm, center=true);
      cylinder(d=screw_ring_inner_d_mm, h=screw_ring_height_mm + 2*overlap_mm, center=true);
    }
}

// Assembly: ONE connected solid
module assembly() {
  union() {
    difference() {
      faceplate_solid();

      rear_cavity_cut();
      bs1363_pin_apertures_cut();
      mounting_holes_cut();
      switch_recess_cut();
    }

    // Add switch rocker as part of same solid (now guaranteed to intersect the faceplate)
    switch_rocker_solid();

    // Add screw/fastener ring as part of same solid (now guaranteed to intersect the faceplate)
    screw_fastener_ring_solid();
  }
}

assembly();