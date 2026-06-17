$fn = 96;

// Parameters
main_nominal_diameter_mm = 50; //[25:100:1]
branch_nominal_diameter_mm = 40; //[20:80:1]
main_run_length_mm = 200; //[100:400:1]
branch_length_mm = 120; //[60:240:1]
wall_thickness_mm = 2; //[1:4:0.1]
socket_depth_main_mm = 35; //[18:70:1]
socket_depth_branch_mm = 30; //[15:60:1]
junction_angle_deg = 90; //[45:90:1]
socket_wall_extra_mm = 1.5; //[0.5:4:0.1]
socket_clearance_mm = 0.4; //[0.1:1.2:0.05]
blend_radius_mm = 6; //[2:15:0.5]
overlap_mm = 1; //[0.5:2:0.1]
main_od_mm = 50; //[25:100:1]
branch_od_mm = 40; //[20:80:1]
main_id_mm = 46; //[20:96:0.1]
branch_id_mm = 36; //[16:76:0.1]

// Helpers
module cylX(r, h, center=true) { rotate([0,90,0]) cylinder(r=r, h=h, center=center); }
module cylZ(r, h, center=true) { cylinder(r=r, h=h, center=center); }

module ht_pipe() {
  // Radii
  r_main_od = main_od_mm/2;
  r_branch_od = branch_od_mm/2;

  r_main_socket_od = r_main_od + socket_wall_extra_mm;
  r_branch_socket_od = r_branch_od + socket_wall_extra_mm;

  r_main_id = main_id_mm/2;
  r_branch_id = branch_id_mm/2;

  r_main_socket_id = r_main_id + socket_clearance_mm;
  r_branch_socket_id = r_branch_id + socket_clearance_mm;

  // Effective inner radii (avoid inverted walls)
  r_main_id_eff         = min(r_main_id,         r_main_od        - 0.2);
  r_branch_id_eff       = min(r_branch_id,       r_branch_od      - 0.2);
  r_main_socket_id_eff  = min(r_main_socket_id,  r_main_socket_od - 0.2);
  r_branch_socket_id_eff= min(r_branch_socket_id,r_branch_socket_od-0.2);

  // --- Connectivity-driven placement (no arbitrary numbers) ---
  // Main run is centered at origin along X.
  // Branch is centered at origin along Z (so it passes through the main run).
  // Sockets are centered at the ends of their respective pipes.
  main_socket_center_x = main_run_length_mm/2 - socket_depth_main_mm/2 + overlap_mm;
  branch_socket_center_z = branch_length_mm/2 - socket_depth_branch_mm/2 + overlap_mm;

  // Blend: keep compact and guaranteed to intersect both cylinders
  blend_r = max(blend_radius_mm, 0.5);
  blend_sphere_r = max(r_main_od, r_branch_od) + blend_r;

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (one connected union)
    union() {
      // Main run
      cylX(r_main_od, main_run_length_mm, center=true);

      // Branch (through the main run)
      cylZ(r_branch_od, branch_length_mm, center=true);

      // Main sockets (both ends)
      translate([-main_socket_center_x, 0, 0])
        cylX(r_main_socket_od, socket_depth_main_mm, center=true);

      translate([ main_socket_center_x, 0, 0])
        cylX(r_main_socket_od, socket_depth_main_mm, center=true);

      // Branch socket (top end)
      translate([0, 0, branch_socket_center_z])
        cylZ(r_branch_socket_od, socket_depth_branch_mm, center=true);

      // Smooth junction blend (hull of spheres around intersection)
      hull() {
        sphere(r = blend_sphere_r);
        translate([0, 0, blend_r])
          sphere(r = r_branch_od + blend_r);
        translate([blend_r, 0, 0])
          sphere(r = r_main_od + blend_r);
      }
    }

    // INNER VOID (continuous bores)
    union() {
      // Main bore (long enough to cut through sockets too)
      cylX(r_main_id_eff,
           main_run_length_mm + 2*socket_depth_main_mm + 6*overlap_mm,
           center=true);

      // Branch bore (long enough to cut through socket too)
      cylZ(r_branch_id_eff,
           branch_length_mm + socket_depth_branch_mm + 6*overlap_mm,
           center=true);

      // Socket clearances (ensure openings)
      translate([-main_socket_center_x, 0, 0])
        cylX(r_main_socket_id_eff, socket_depth_main_mm + 4*overlap_mm, center=true);

      translate([ main_socket_center_x, 0, 0])
        cylX(r_main_socket_id_eff, socket_depth_main_mm + 4*overlap_mm, center=true);

      translate([0, 0, branch_socket_center_z])
        cylZ(r_branch_socket_id_eff, socket_depth_branch_mm + 4*overlap_mm, center=true);
    }
  }
}

ht_pipe();