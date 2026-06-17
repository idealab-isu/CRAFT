// Dimension-calibrated (target: 0.03 x 0.03 x 0.02 mm)
scale([0.001000, 0.001000, 0.001020])
{
// Handwheel / hub with rim, 4 curved rectangular cutouts, raised hub, hex through-bore, and short post
// Units: mm

$fn = 128;

// -------------------- Parameters --------------------
disk_D = 30;
disk_t = 12;

rim_radial_w = 3;     // radial thickness of rim ring
rim_extra_t  = 4;     // extra thickness on one face (top)

hub_D = 14;
hub_h = 4;

post_D = 8;
post_h = 4;

hex_flat_AF = 6;      // across flats

cutout_count = 4;
cutout_len_tangential = 8;
cutout_w_radial = 3;
cutout_depth_z = 20;  // must exceed total thickness to guarantee through-cut
cutout_corner_r = 1;

cutout_radial_pos = (disk_D/2 - rim_radial_w/2); // near perimeter, centered in rim

overlap = 0.2;        // small overlap to ensure watertight unions/differences

// -------------------- Helpers --------------------
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for a regular hex given across-flats

module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
  }
}

module hex_prism_through(h) {
  R = hex_R_from_AF(hex_flat_AF);
  linear_extrude(height=h, center=true)
    polygon(points=[ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

// -------------------- Main solids --------------------
module base_disk() {
  cylinder(r=disk_D/2, h=disk_t, center=true);
}

module top_rim_ring() {
  // ring sits on top face of disk
  zc = disk_t/2 + rim_extra_t/2 - overlap;
  difference() {
    translate([0,0,zc]) cylinder(r=disk_D/2, h=rim_extra_t, center=true);
    translate([0,0,zc]) cylinder(r=disk_D/2 - rim_radial_w, h=rim_extra_t + 2*overlap, center=true);
  }
}

module raised_hub() {
  zc = disk_t/2 + hub_h/2 - overlap;
  translate([0,0,zc]) cylinder(r=hub_D/2, h=hub_h, center=true);
}

module bottom_post() {
  zc = -disk_t/2 - post_h/2 + overlap;
  translate([0,0,zc]) cylinder(r=post_D/2, h=post_h, center=true);
}

module curved_cutout() {
  // A rounded rectangle placed tangentially, then slightly curved by intersecting with an annulus sector
  // (keeps it "curved rectangular" near the perimeter)
  zc = 0;
  translate([0,0,zc])
    linear_extrude(height=cutout_depth_z, center=true)
      intersection() {
        // rounded rectangle in local coordinates
        translate([cutout_radial_pos, 0, 0])
          rounded_rect_2d(cutout_w_radial, cutout_len_tangential, cutout_corner_r);

        // annulus band to impart curvature (keeps cutout near rim)
        difference() {
          circle(r=disk_D/2 - rim_radial_w*0.15);
          circle(r=disk_D/2 - rim_radial_w*1.85);
        }
      }
}

module all_cutouts() {
  for (i = [0:cutout_count-1])
    rotate([0,0,i*360/cutout_count]) curved_cutout();
}

// -------------------- Final model --------------------
module model() {
  total_h = disk_t + rim_extra_t + hub_h + post_h + 10;

  difference() {
    union() {
      base_disk();
      top_rim_ring();
      raised_hub();
      bottom_post();
    }

    // four perimeter cutouts
    all_cutouts();

    // through hex bore
    hex_prism_through(total_h);
  }
}

model();
}
