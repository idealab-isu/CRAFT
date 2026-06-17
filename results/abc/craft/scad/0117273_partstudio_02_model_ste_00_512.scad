// Dimension-calibrated (target: 0.02 x 0.02 x 0.05 mm)
scale([0.001411, 0.000534, 0.000284])
{
// Faceted lantern/pendant shell with deep cutouts (render-safe, no minkowski)

$fn = 48;

// -------------------- Parameters (mm) --------------------
shell_h = 50;
outer_r = 18;                 // overall "sphere-ish" radius
facet_sides = 8;              // low-poly feel
wall_t = 1.6;

taper_top_r = 16;
taper_bottom_r = 13;

cap_h = 6;
cap_sides = 6;

tip_h = 10;
tip_base_r = 9;

overlap = 0.6;                // boolean overlap (slightly larger for robustness)

// Openings
slot_h = 6;
slot_w = 30;
slot_depth = 44;              // exceed diameter to cut through
slot_z = 0;                   // centered

cutout_count = 6;
cutout_w = 5;
cutout_h = 34;
cutout_depth = 54;
cutout_tilt_deg = 22;

// Grooves (recessed pockets)
groove_w = 2.2;
groove_h = 3.0;
groove_depth = 10;

// Eyelet
eyelet_major_r = 4.2;         // ring centerline radius
eyelet_tube_r  = 1.4;         // ring thickness
eyelet_clear_r = 1.0;         // inner hole radius (subtracted)

// -------------------- Helpers --------------------
module ngon2d(r, n) {
  polygon(points=[for (i=[0:n-1]) [r*cos(360*i/n), r*sin(360*i/n)]]);
}

// Faceted "spherical" body: hull of three thin extrusions (tapered + bulge)
module faceted_body_outer() {
  hull() {
    translate([0,0, shell_h/2 - overlap])
      linear_extrude(height=overlap*2, center=true)
        ngon2d(taper_top_r, facet_sides);

    translate([0,0,-shell_h/2 + overlap])
      linear_extrude(height=overlap*2, center=true)
        ngon2d(taper_bottom_r, facet_sides);

    linear_extrude(height=overlap*2, center=true)
      ngon2d(outer_r, facet_sides);
  }
}

module faceted_body_inner() {
  inner_h = shell_h - 2*wall_t;
  hull() {
    translate([0,0, inner_h/2 - overlap])
      linear_extrude(height=overlap*2, center=true)
        ngon2d(max(taper_top_r - wall_t, 0.2), facet_sides);

    translate([0,0,-inner_h/2 + overlap])
      linear_extrude(height=overlap*2, center=true)
        ngon2d(max(taper_bottom_r - wall_t, 0.2), facet_sides);

    linear_extrude(height=overlap*2, center=true)
      ngon2d(max(outer_r - wall_t, 0.2), facet_sides);
  }
}

module main_shell() {
  difference() {
    faceted_body_outer();
    faceted_body_inner();
  }
}

// -------------------- Add-ons (cap, tip, eyelet) --------------------
module top_polygonal_cap() {
  translate([0,0, shell_h/2 - cap_h/2 - overlap])
    linear_extrude(height=cap_h, center=true)
      ngon2d(taper_top_r*0.92, cap_sides);
}

module bottom_pyramidal_tip() {
  translate([0,0, -shell_h/2 - tip_h/2 + overlap])
    cylinder(h=tip_h, r1=tip_base_r, r2=0, center=true, $fn=cap_sides);
}

module hanging_loop_eyelet() {
  z0 = shell_h/2 + eyelet_tube_r + overlap;
  difference() {
    translate([0,0,z0])
      rotate([90,0,0])
        rotate_extrude($fn=64)
          translate([eyelet_major_r,0,0])
            circle(r=eyelet_tube_r, $fn=24);

    translate([0,0,z0])
      rotate([90,0,0])
        rotate_extrude($fn=64)
          translate([eyelet_major_r,0,0])
            circle(r=eyelet_clear_r, $fn=24);
  }
}

// -------------------- Subtractive openings --------------------
module primary_horizontal_slot_cut() {
  translate([0,0,slot_z])
    cube([slot_w, slot_depth, slot_h], center=true);
}

module vertical_planar_cutouts() {
  union() {
    for (i=[0:cutout_count-1]) {
      ang = i*360/cutout_count;
      rotate([0,0,ang])
        translate([outer_r*0.55, 0, 0])
          cube([cutout_w, cutout_depth, cutout_h], center=true);
    }

    rotate([ cutout_tilt_deg, 0, 30])
      cube([cutout_w, cutout_depth, cutout_h*1.05], center=true);

    rotate([-cutout_tilt_deg, 0, 110])
      cube([cutout_w, cutout_depth, cutout_h*1.05], center=true);
  }
}

module recessed_grooves() {
  union() {
    translate([0,0,-shell_h/2 + tip_h + groove_h/2 + wall_t])
      cube([outer_r*1.6, groove_depth, groove_h], center=true);

    translate([0,0, shell_h/2 - cap_h - groove_h/2 - wall_t])
      cube([outer_r*1.6, groove_depth, groove_h], center=true);

    translate([outer_r*0.75, 0, 0])
      cube([groove_w, outer_r*1.6, cutout_h*0.7], center=true);
  }
}

module all_openings() {
  union() {
    primary_horizontal_slot_cut();
    vertical_planar_cutouts();
    recessed_grooves();
  }
}

// -------------------- Assembly --------------------
module lantern() {
  union() {
    difference() {
      main_shell();
      all_openings();
    }
    top_polygonal_cap();
    bottom_pyramidal_tip();
    hanging_loop_eyelet();
  }
}

// -------------------- Final (no minkowski) --------------------
lantern();
}
