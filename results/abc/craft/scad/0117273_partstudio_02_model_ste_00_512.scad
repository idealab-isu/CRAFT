// Dimension-calibrated (target: 0.02 x 0.02 x 0.05 mm)
scale([1.167921, 1.218975, 0.940015])
{
// Faceted lantern/pendant shell (single connected solid)
// Fixes: ensure a coherent faceted spherical/tapered shell, connected cap+tip+loop,
// and cutouts that carve into the shell (not fragment it).

// -------------------- Parameters --------------------
bbox_x = 0.02; //[0.01:0.04:0.001]
bbox_y = 0.02; //[0.01:0.04:0.001]
bbox_z = 0.05; //[0.025:0.1:0.001]

shell_t = 0.0012; //[0.0006:0.0024:0.0001]

taper_top_scale = 0.85; //[0.6:1.0:0.01]
taper_bottom_scale = 0.55; //[0.3:0.9:0.01]

tip_h = 0.008; //[0.004:0.016:0.0005]
tip_base_r = 0.006; //[0.003:0.012:0.0005]

cap_h = 0.004; //[0.002:0.008:0.0005]
cap_sides = 6; //[3:12:1]
cap_inset = 0.001; //[0.0005:0.002:0.0001]

hslot_len = 0.018; //[0.009:0.02:0.0005]
hslot_h = 0.004; //[0.002:0.008:0.0005]
hslot_depth = 0.012; //[0.003:0.02:0.0005]
hslot_z = 0.0; //[-0.01:0.01:0.0005]

vcut_count = 6; //[1:12:1]
vcut_w = 0.003; //[0.0015:0.006:0.0005]
vcut_len = 0.07; //[0.02:0.09:0.001]
vcut_depth = 0.02; //[0.004:0.03:0.0005]
vcut_tilt_deg = 0; //[-45:45:1]

dcut_count = 4; //[1:12:1]
dcut_w = 0.003; //[0.0015:0.006:0.0005]
dcut_len = 0.07; //[0.02:0.09:0.001]
dcut_depth = 0.02; //[0.004:0.03:0.0005]
dcut_tilt_deg = 25; //[0:60:1]

overlap = 0.001; //[0.0005:0.002:0.0001]
facet_scale_xy = 0.92; //[0.8:1.0:0.01]

loop_major_r = 0.003; //[0.0015:0.006:0.0005]
loop_minor_r = 0.0007; //[0.0004:0.0014:0.0001]
loop_hole_r  = 0.0009; //[0.0005:0.0018:0.0001]

// -------------------- Derived --------------------
outer_r = min(bbox_x, bbox_y, bbox_z) * 0.52;
z_top =  bbox_z/2;
z_bot = -bbox_z/2;
r_edge = min(bbox_x,bbox_y)/2;

// -------------------- Helpers --------------------
module faceted_ellipsoid(r=outer_r, fn=14) {
  scale([bbox_x/(2*r), bbox_y/(2*r), bbox_z/(2*r)])
    sphere(r=r, $fn=fn);
}

module tapered_profile() {
  cylinder(
    h=bbox_z + 2*overlap,
    r1=r_edge * taper_bottom_scale,
    r2=r_edge * taper_top_scale,
    center=true,
    $fn=12
  );
}

module shell_body() {
  // Coherent faceted spherical/tapered shell (hollow)
  difference() {
    intersection() {
      scale([facet_scale_xy, facet_scale_xy, 1])
        faceted_ellipsoid(fn=14);
      tapered_profile();
    }
    // inner cavity: slightly smaller and slightly more tapered to preserve wall
    intersection() {
      scale([facet_scale_xy, facet_scale_xy, 1])
        faceted_ellipsoid(r=max(outer_r - shell_t, outer_r*0.65), fn=14);
      scale([0.97,0.97,1])
        tapered_profile();
    }
  }
}

module top_cap_connected() {
  cap_r = max(r_edge - cap_inset, shell_t*2);
  // Overlap into shell to guarantee connectivity
  translate([0,0, z_top - cap_h/2 - overlap])
    cylinder(h=cap_h + 2*overlap, r=cap_r, center=true, $fn=cap_sides);
}

module bottom_tip_connected() {
  // Overlap into shell to guarantee connectivity
  translate([0,0, z_bot + tip_h/2 + overlap])
    cylinder(h=tip_h + 2*overlap, r1=tip_base_r, r2=0, center=true, $fn=4);
}

module mounting_loop_connected() {
  // Place loop so it intersects the cap (not floating)
  loop_z = z_top - cap_h + loop_minor_r; // intersects cap volume
  translate([0,0, loop_z])
    rotate([90,0,0])
      rotate_extrude($fn=64)
        translate([loop_major_r,0,0])
          circle(r=loop_minor_r, $fn=24);
}

module mounting_loop_hole() {
  loop_z = z_top - cap_h + loop_minor_r;
  translate([0,0, loop_z])
    rotate([90,0,0])
      cylinder(r=loop_hole_r,
               h=2*(loop_major_r + loop_minor_r + 2*overlap),
               center=true, $fn=40);
}

// -------------------- Cutouts / Grooves --------------------
module long_horizontal_slot_cut() {
  // Long horizontal recessed/through slot across the shell
  // Depth spans beyond body so it reliably cuts into the curved surface.
  translate([0,0,hslot_z])
    cube([hslot_len, max(hslot_depth, 2*r_edge + 2*overlap), hslot_h], center=true);
}

module radial_vertical_cutouts() {
  // Planar cutouts around the body; positioned to bite into shell (not separate parts)
  // Use a large Z length so they cut through the shell height.
  for (i=[0:vcut_count-1]) {
    ang = i*360/vcut_count;
    rotate([0,0,ang])
      rotate([0,vcut_tilt_deg,0])
        translate([r_edge - vcut_depth/2 + overlap, 0, 0])
          cube([vcut_depth, vcut_w, vcut_len], center=true);
  }
}

module radial_diagonal_cutouts() {
  for (i=[0:dcut_count-1]) {
    ang = i*360/dcut_count + 360/(2*dcut_count);
    rotate([0,0,ang])
      rotate([0,dcut_tilt_deg,45])
        translate([r_edge - dcut_depth/2 + overlap, 0, 0])
          cube([dcut_depth, dcut_w, dcut_len], center=true);
  }
}

module recessed_groove_rings() {
  // Recessed circumferential grooves (shallow pockets)
  groove_r = max(shell_t*0.55, 0.00035);
  major = r_edge * 0.78;

  for (zpos = [bbox_z*0.18, -bbox_z*0.12]) {
    translate([0,0,zpos])
      rotate_extrude($fn=84)
        translate([major,0,0])
          circle(r=groove_r, $fn=24);
  }
}

module symmetry_break_cut() {
  translate([bbox_x*0.18, 0, bbox_z*0.10])
    rotate([0,0,20])
      cube([bbox_x*0.25, bbox_y*0.18, bbox_z*0.18], center=true);
}

// -------------------- Final Model --------------------
module pendant_shell() {
  difference() {
    // One connected solid: shell + cap + tip + loop
    union() {
      shell_body();
      top_cap_connected();
      bottom_tip_connected();
      mounting_loop_connected();
    }

    // Openings / slots carved into the shell
    long_horizontal_slot_cut();
    radial_vertical_cutouts();
    radial_diagonal_cutouts();

    // Recessed grooves
    recessed_groove_rings();

    // Loop hole
    mounting_loop_hole();

    // Asymmetry pocket
    symmetry_break_cut();
  }
}

pendant_shell();
}
