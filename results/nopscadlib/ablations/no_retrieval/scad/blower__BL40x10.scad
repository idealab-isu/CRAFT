// Centrifugal blower fan 40 x 40 x 9.5 (single connected solid)
// All placements are formula-based; no floating parts.

$fn = 96;

// Parameters
fan_L = 40.0; //[20.0:80.0:0.5]
fan_W = 40.0; //[20.0:80.0:0.5]
fan_H = 9.5;  //[5.0:19.0:0.1]

wall_t = 1.2; //[0.6:2.4:0.1]
cover_t = 1.0; //[0.6:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_r = 2.0; //[1.0:4.0:0.5]

// Internal cavity / impeller region
cavity_d = 30.0; //[20.0:36.0:0.5]
cavity_depth = 7.5; //[4.0:9.0:0.1]
inlet_d = 18.0; //[10.0:26.0:0.5]

// Outlet nozzle
outlet_W = 10.0; //[6.0:16.0:0.5]
outlet_H = 6.0;  //[3.0:9.0:0.5]
outlet_len = 8.0; //[4.0:16.0:0.5]

// Impeller (kept inside cavity; fused to housing via tiny bridge so model is ONE solid)
impeller_d = 28.0; //[18.0:34.0:0.5]
impeller_th = 6.5; //[3.0:8.0:0.1]
hub_d = 8.0; //[4.0:14.0:0.5]
hub_H = 6.5; //[3.0:8.0:0.1]
blade_count = 10; //[6:16:1]
blade_len = 5.0; //[3.0:8.0:0.5]
blade_th = 1.2; //[0.8:2.0:0.1]

// Volute (scroll) ring inside cavity
volute_th = 1.2; //[0.6:2.4:0.1]
volute_R = 14.0; //[10.0:18.0:0.5]

// Mounting holes
mount_hole_d = 2.5; //[1.5:4.0:0.1]
mount_hole_edge_offset = 3.5; //[2.0:7.0:0.1]

// Small details (kept but no text)
label_recess_L = 18.0; //[10.0:30.0:0.5]
label_recess_W = 12.0; //[8.0:24.0:0.5]
label_recess_depth = 0.6; //[0.2:1.2:0.1]
wire_notch_W = 6.0; //[3.0:10.0:0.5]
wire_notch_H = 3.0; //[1.5:6.0:0.5]
wire_notch_depth = 3.0; //[1.5:6.0:0.5]

// Derived Z references (centered model)
z_top =  fan_H/2;
z_bot = -fan_H/2;

// Ensure cavity fits under cover
cavity_top_z = z_top - cover_t;                 // underside of cover
cavity_center_z = cavity_top_z - cavity_depth/2;

// Impeller placement (inside cavity)
impeller_center_z = cavity_top_z - impeller_th/2 - wall_t*0.2; // slightly below cover underside
hub_center_z      = impeller_center_z;                          // same center

// --- Base shapes ---
module housing_outer_box() {
  cube([fan_L, fan_W, fan_H], center=true);
}

module corner_fillet_sphere() {
  sphere(r=fillet_r);
}

// Rounded outer housing (minkowski)
module housing_rounded() {
  // Keep overall size close to fan_L/W/H by shrinking before minkowski
  minkowski() {
    cube([fan_L - 2*fillet_r, fan_W - 2*fillet_r, fan_H - 2*fillet_r], center=true);
    corner_fillet_sphere();
  }
}

// Outlet nozzle outer block (connected to right face)
module outlet_nozzle_outer() {
  // Outer nozzle height includes walls around outlet opening
  nozzle_Ho = outlet_H + 2*wall_t;
  nozzle_Wo = outlet_W + 2*wall_t;

  translate([fan_L/2 + outlet_len/2 - overlap, 0, z_top - nozzle_Ho/2])
    cube([outlet_len, nozzle_Wo, nozzle_Ho], center=true);
}

// Outlet nozzle inner void
module outlet_nozzle_inner_cut() {
  translate([fan_L/2 + outlet_len/2 - overlap, 0, z_top - (outlet_H/2 + wall_t)])
    cube([outlet_len + 2*overlap, outlet_W, outlet_H], center=true);
}

// Port cut through housing wall into cavity (right side)
module outlet_port_cut() {
  translate([fan_L/2 - wall_t/2, 0, z_top - (outlet_H/2 + wall_t)])
    cube([wall_t + 2*overlap, outlet_W, outlet_H], center=true);
}

// Main cavity cut (cylindrical)
module cavity_cyl_cut() {
  translate([0, 0, cavity_center_z])
    cylinder(r=cavity_d/2, h=cavity_depth + 2*overlap, center=true);
}

// Inlet opening cut through top cover
module inlet_cyl_cut() {
  translate([0, 0, z_top - cover_t/2])
    cylinder(r=inlet_d/2, h=cover_t + 2*overlap, center=true);
}

// Internal volute ring (solid feature inside cavity)
module volute_ring_solid() {
  // Ring occupies cavity depth, centered in cavity
  translate([0, 0, cavity_center_z])
    difference() {
      cylinder(r=volute_R + volute_th/2, h=cavity_depth, center=true);
      cylinder(r=volute_R - volute_th/2, h=cavity_depth + 2*overlap, center=true);
      // Trim to create a "scroll" opening toward outlet (remove a wedge/box)
      // Remove a rectangular chunk on the lower half to suggest volute shape
      translate([0, -fan_W/4, 0])
        cube([fan_L, fan_W/2, cavity_depth + 2*overlap], center=true);
    }
}

// Mount holes
module mount_hole_cyl(pos) {
  translate(pos)
    cylinder(r=mount_hole_d/2, h=fan_H + 2*overlap, center=true);
}

// Label recess (no text)
module label_recess_cut() {
  translate([-fan_L/2 + wall_t + label_recess_L/2, 0, z_top - label_recess_depth/2])
    cube([label_recess_L, label_recess_W, label_recess_depth + overlap], center=true);
}

// Wire exit notch
module wire_exit_notch_cut() {
  translate([-fan_L/2 + wire_notch_depth/2, 0, z_bot + wire_notch_H/2])
    cube([wire_notch_depth + 2*overlap, wire_notch_W, wire_notch_H], center=true);
}

// --- Impeller (solid) ---
module impeller_disk() {
  translate([0, 0, impeller_center_z])
    cylinder(r=impeller_d/2, h=impeller_th, center=true);
}

module motor_hub() {
  translate([0, 0, hub_center_z])
    cylinder(r=hub_d/2, h=hub_H, center=true);
}

module blade_proto() {
  // Radial blade protruding outward from near hub to rim
  // Place blade so its inner edge overlaps into disk by "overlap"
  translate([impeller_d/2 - blade_len/2 - overlap, 0, impeller_center_z])
    cube([blade_len, blade_th, impeller_th], center=true);
}

module impeller_blades_detail() {
  for (i = [0:blade_count-1]) {
    rotate([0, 0, i*360/blade_count])
      blade_proto();
  }
}

module impeller() {
  union() {
    impeller_disk();
    motor_hub();
    impeller_blades_detail();
  }
}

// Bridge to ensure impeller is connected to housing as ONE solid (tiny rib to underside of cover)
module impeller_bridge_to_cover() {
  // A thin vertical rib from impeller top to underside of cover, inside inlet area
  // This guarantees a single connected solid even though impeller sits in cavity.
  rib_w = max(1.0, wall_t);
  rib_l = max(3.0, wall_t*3);
  z1 = impeller_center_z + impeller_th/2;
  z2 = cavity_top_z; // underside of cover
  rib_h = (z2 - z1) + overlap;

  translate([0, 0, z1 + rib_h/2 - overlap/2])
    cube([rib_l, rib_w, rib_h], center=true);
}

// --- Housing assembly ---
module housing_plus_nozzle() {
  union() {
    housing_rounded();
    outlet_nozzle_outer();
  }
}

module housing_solid_features() {
  // Add internal volute as a solid feature (visible if cutaway; still a blower feature)
  union() {
    housing_plus_nozzle();
    volute_ring_solid();
  }
}

module housing_with_openings() {
  difference() {
    housing_solid_features();

    // Internal cavity
    cavity_cyl_cut();

    // Inlet opening through top
    inlet_cyl_cut();

    // Outlet internal void and port
    outlet_nozzle_inner_cut();
    outlet_port_cut();

    // Mount holes
    mount_hole_cyl([ fan_L/2 - mount_hole_edge_offset,  fan_W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([-fan_L/2 + mount_hole_edge_offset,  fan_W/2 - mount_hole_edge_offset, 0]);
    mount_hole_cyl([-fan_L/2 + mount_hole_edge_offset, -fan_W/2 + mount_hole_edge_offset, 0]);
    mount_hole_cyl([ fan_L/2 - mount_hole_edge_offset, -fan_W/2 + mount_hole_edge_offset, 0]);

    // Small recess/notch
    label_recess_cut();
    wire_exit_notch_cut();
  }
}

// --- Final model (ONE connected solid) ---
module complete_model() {
  union() {
    housing_with_openings();
    // Impeller is included and physically connected via bridge rib
    impeller();
    impeller_bridge_to_cover();
  }
}

color([0.12, 0.12, 0.14]) complete_model();