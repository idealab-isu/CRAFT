// Parameters (mm)
total_length_mm = 8; //[4:16:0.5]
shaft_bore_diameter_mm = 1.6; //[0.8:3.2:0.1]
shaft_centerline_offset_mm = 2.6; //[1.3:5.2:0.1]
height_to_shaft_center_mm = 5.2; //[2.6:10.4:0.1]
base_flange_height_mm = 4.2; //[2.1:8.4:0.1]
mounting_pattern_x_mm = 4.5; //[2.25:9:0.1]
mounting_pattern_y_mm = 2.8; //[1.4:5.6:0.1]
mounting_hole_diameter_mm = 0.8; //[0.4:1.6:0.05]
mounting_hole_count = 4; //[4:4:1]
block_length_mm = 8; //[4:16:0.5]
block_width_mm = 5.3333333333; //[2.6666666667:10.6666666667:0.1]
block_total_height_mm = 6; //[3:12:0.1]
flange_thickness_mm = 0.8; //[0.4:1.6:0.05]
edge_fillet_radius_mm = 0.3; //[0.1:0.6:0.05]
bore_length_mm = 8.4; //[4.2:16.8:0.1]
mounting_hole_depth_mm = 1.2; //[0.6:2.4:0.05]
counterbore_diameter_mm = 1.2; //[0.6:2.4:0.05]
counterbore_depth_mm = 0.4; //[0.2:0.8:0.05]
overlap_mm = 0.6; //[0.2:1.2:0.05]

// Quality
$fn=32;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  if (r2 <= 0) square([w, h], center=true);
  else offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module screw_hole_with_counterbore(hole_d, hole_h, cb_d, cb_h) {
  // Oriented along Z, centered in Z by caller if desired
  union() {
    cylinder(d=hole_d, h=hole_h, center=true);
    cylinder(d=cb_d, h=cb_h, center=true);
  }
}

// ---------- Base shapes (as modules) ----------
module base_flange() {
  color([0.15, 0.15, 0.17])  // black anodized-ish
    translate([0, 0, -block_total_height_mm/2 + flange_thickness_mm/2])
      cube([block_length_mm, block_width_mm, flange_thickness_mm], center=true);
}

module main_body() {
  color([0.15, 0.15, 0.17])
    translate([0, 0, 0])
      cube([block_length_mm, block_width_mm, block_total_height_mm], center=true);
}

// [MANDATORY] Right Trapezoid - detailed geometry
module right_trapezoid() {
  // A reinforcing rib/wedge with slight relief and a small lightening slot
  rib_h = block_total_height_mm * 0.55;
  rib_w0 = block_width_mm * 0.55;
  rib_w1 = block_width_mm * 0.35;
  rib_len = block_length_mm;

  zpos = -block_total_height_mm/2 + flange_thickness_mm + block_total_height_mm*0.275;

  color([0.12, 0.12, 0.14])  // slightly different dark tone
  translate([0, 0, zpos])
  rotate([0, 90, 0])
  difference() {
    // Main wedge
    linear_extrude(height=rib_len, center=true, convexity=10)
      polygon(points=[
        [0, 0],
        [rib_w0, 0],
        [rib_w1, rib_h],
        [0, rib_h]
      ]);

    // Lightening slot (keeps it recognizable as a rib feature)
    translate([0, 0, 0])
      linear_extrude(height=rib_len + 0.2, center=true, convexity=10)
        polygon(points=[
          [rib_w0*0.18, rib_h*0.18],
          [rib_w0*0.78, rib_h*0.18],
          [rib_w0*0.62, rib_h*0.78],
          [rib_w0*0.18, rib_h*0.78]
        ]);

    // Small chamfer-like relief at the bottom edge (approx)
    translate([rib_w0*0.02, -0.01, 0])
      linear_extrude(height=rib_len + 0.2, center=true, convexity=10)
        polygon(points=[
          [0, 0],
          [rib_w0*0.25, 0],
          [0, rib_h*0.18]
        ]);
  }
}

module shaft_bore() {
  translate([0, 0, -block_total_height_mm/2 + height_to_shaft_center_mm])
    rotate([0, 90, 0])
      cylinder(r=shaft_bore_diameter_mm/2, h=bore_length_mm, center=true);
}

module mounting_hole() {
  translate([0, 0, -block_total_height_mm/2 + flange_thickness_mm/2])
    cylinder(r=mounting_hole_diameter_mm/2, h=mounting_hole_depth_mm, center=true);
}

module mounting_hole_counterbore_or_clearance() {
  translate([0, 0, -block_total_height_mm/2 + flange_thickness_mm - counterbore_depth_mm/2])
    cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm, center=true);
}

module fillets_or_chamfers() {
  // Proxy relief cylinder along length near one top edge (as in plan)
  translate([0, block_width_mm/2 - edge_fillet_radius_mm, -block_total_height_mm/2 + flange_thickness_mm + edge_fillet_radius_mm])
    rotate([0, 90, 0])
      cylinder(r=edge_fillet_radius_mm, h=block_length_mm, center=true);
}

// [MANDATORY] Linear Bearing - detailed geometry
module linear_bearing() {
  // Visible sleeve inside bore with grooves and slight lead-in chamfers
  od = shaft_bore_diameter_mm + shaft_bore_diameter_mm*0.5; // matches plan radius: d/2 + d*0.25 => OD = d*1.5
  id = shaft_bore_diameter_mm * 1.02; // tiny clearance
  len = block_length_mm - overlap_mm;

  zpos = -block_total_height_mm/2 + height_to_shaft_center_mm;

  color([0.72, 0.72, 0.75])  // steel-ish
  translate([0, 0, zpos])
  rotate([0, 90, 0])
  difference() {
    union() {
      // Outer sleeve
      cylinder(d=od, h=len, center=true);

      // Two shallow outer grooves (recognizable bearing detail)
      for (sx = [-1, 1]) {
        translate([sx*(len*0.28), 0, 0])
          difference() {
            cylinder(d=od*1.02, h=len*0.10, center=true);
            cylinder(d=od*0.92, h=len*0.12, center=true);
          }
      }

      // End collars (very small)
      for (sx = [-1, 1]) {
        translate([sx*(len/2 - len*0.06), 0, 0])
          cylinder(d=od*1.03, h=len*0.06, center=true);
      }
    }

    // Through ID
    cylinder(d=id, h=len + 0.4, center=true);

    // Lead-in chamfers (approx via conical cuts)
    for (sx = [-1, 1]) {
      translate([sx*(len/2), 0, 0])
        rotate([0, 90, 0])
          cylinder(h=od*0.35, r1=id/2, r2=od/2, center=true);
    }
  }
}

// [MANDATORY] Veroboard Base - detailed geometry
module veroboard_base() {
  // Small board with copper strip hints and mounting holes; placed per plan
  L = block_length_mm*0.6;
  W = block_width_mm*0.6;
  T = flange_thickness_mm*0.5;

  zpos = -block_total_height_mm/2 + flange_thickness_mm/2;

  color([0.55, 0.35, 0.18])  // phenolic/brown perfboard
  translate([0, 0, zpos])
  difference() {
    // Board with slightly rounded corners (2D offset, no minkowski)
    linear_extrude(height=T, center=true)
      rounded_rect_2d(L, W, min(0.35, min(L, W)*0.08));

    // Two tiny mounting holes
    for (sx = [-1, 1], sy = [-1, 1]) {
      if ((sx == sy))  // only two corners to keep it distinct from PCB base
        translate([sx*(L*0.35), sy*(W*0.35), 0])
          cylinder(d=0.6, h=T+0.4, center=true);
    }

    // Shallow "strip" grooves on top face (visual detail)
    for (i = [-2:2]) {
      translate([0, i*(W/6), T*0.15])
        cube([L*0.92, W*0.03, T*0.35], center=true);
    }
  }

  // Copper strips as raised thin features (connected to board)
  color([0.72, 0.45, 0.2])
  translate([0, 0, zpos + T*0.25])
  for (i = [-2:2]) {
    translate([0, i*(W/6), 0])
      cube([L*0.90, W*0.02, T*0.10], center=true);
  }
}

// [MANDATORY] PCB Base - detailed geometry
module pcb_base() {
  // Small green PCB with pads and 4 holes; placed per plan (same location)
  L = block_length_mm*0.6;
  W = block_width_mm*0.6;
  T = flange_thickness_mm*0.5;

  zpos = -block_total_height_mm/2 + flange_thickness_mm/2;

  color([0.0, 0.4, 0.2])  // PCB green
  translate([0, 0, zpos])
  difference() {
    linear_extrude(height=T, center=true)
      rounded_rect_2d(L, W, min(0.35, min(L, W)*0.08));

    // 4 corner holes (small)
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(L*0.38), sy*(W*0.38), 0])
        cylinder(d=0.5, h=T+0.4, center=true);
    }
  }

  // Pads (gold) on top face
  color([0.85, 0.7, 0.25])
  translate([0, 0, zpos + T*0.25])
  for (ix = [-3:3], iy = [-1:1]) {
    translate([ix*(L/10), iy*(W/5), 0])
      cylinder(d=min(0.55, W*0.10), h=T*0.10, center=true);
  }
}

// ---------- Operation results ----------
module mounting_hole_pos_1() { translate([mounting_pattern_x_mm/2,  mounting_pattern_y_mm/2, 0]) mounting_hole(); }
module mounting_hole_pos_2() { translate([-mounting_pattern_x_mm/2, mounting_pattern_y_mm/2, 0]) mounting_hole(); }
module mounting_hole_pos_3() { translate([mounting_pattern_x_mm/2,  -mounting_pattern_y_mm/2, 0]) mounting_hole(); }
module mounting_hole_pos_4() { translate([-mounting_pattern_x_mm/2, -mounting_pattern_y_mm/2, 0]) mounting_hole(); }

module counterbore_pos_1() { translate([mounting_pattern_x_mm/2,  mounting_pattern_y_mm/2, 0]) mounting_hole_counterbore_or_clearance(); }
module counterbore_pos_2() { translate([-mounting_pattern_x_mm/2, mounting_pattern_y_mm/2, 0]) mounting_hole_counterbore_or_clearance(); }
module counterbore_pos_3() { translate([mounting_pattern_x_mm/2,  -mounting_pattern_y_mm/2, 0]) mounting_hole_counterbore_or_clearance(); }
module counterbore_pos_4() { translate([-mounting_pattern_x_mm/2, -mounting_pattern_y_mm/2, 0]) mounting_hole_counterbore_or_clearance(); }

module mounting_holes_pattern() {
  union() {
    mounting_hole_pos_1();
    mounting_hole_pos_2();
    mounting_hole_pos_3();
    mounting_hole_pos_4();
  }
}

module mounting_counterbores_pattern() {
  union() {
    counterbore_pos_1();
    counterbore_pos_2();
    counterbore_pos_3();
    counterbore_pos_4();
  }
}

module block_union() {
  union() {
    main_body();
    base_flange();
    right_trapezoid();
  }
}

module block_with_bore() {
  difference() {
    block_union();
    shaft_bore();
  }
}

module block_with_mounting() {
  difference() {
    block_with_bore();
    mounting_holes_pattern();
    mounting_counterbores_pattern();
    fillets_or_chamfers();
  }
}

module final_model() {
  union() {
    block_with_mounting();
    linear_bearing();

    // Stack the two boards slightly so both are visible and still connected to the flange
    translate([0, 0, flange_thickness_mm*0.26]) veroboard_base();
    translate([0, 0, -flange_thickness_mm*0.26]) pcb_base();
  }
}

// ---------- Assembly ----------
module assembly() {
  // Primary at origin
  final_model();
}

assembly();