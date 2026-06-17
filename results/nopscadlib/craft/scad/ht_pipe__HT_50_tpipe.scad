$fn = 96;

// Parameters
nominal_diameter_mm = 50; //[25:100:1]
main_run_length_mm = 120; //[60:240:1]
branch_length_mm = 80; //[40:160:1]
socket_depth_mm = 35; //[18:70:1]
pipe_outer_diameter_mm = 50; //[25:100:0.5]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
branch_angle_deg = 90; //[45:90:1]
centerline_radius_mm = 0; //[0:20:1]
chamfer_mm = 1; //[0.5:3:0.1]
fillet_radius_mm = 2; //[0:6:0.5]
socket_clearance_mm = 0.4; //[0.1:1.2:0.1]
stop_thickness_mm = 2; //[1:5:0.5]
stop_radial_mm = 1.2; //[0.6:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
ht_pipe_insert_length_mm = 30; //[10:80:1]
ht_pipe_exposed_length_mm = 60; //[20:200:1]

// Derived
r_pipe = pipe_outer_diameter_mm/2;
r_outer = r_pipe + wall_thickness_mm;
r_bore  = max(0.01, r_pipe - wall_thickness_mm);
r_sock  = r_pipe + socket_clearance_mm;

module tube_x(r, h, center=true) { rotate([0,90,0]) cylinder(r=r, h=h, center=center); }
module tube_y(r, h, center=true) { rotate([90,0,0]) cylinder(r=r, h=h, center=center); }

module ht_pipe() {
  // HT pipe on LEFT end of main run, inserted into socket by ht_pipe_insert_length_mm
  pipe_total = ht_pipe_exposed_length_mm + ht_pipe_insert_length_mm;

  // Left socket mouth is at x = -main_run_length/2
  // Pipe spans x in [-main/2 - exposed, -main/2 + insert]
  pipe_center_x = (-main_run_length_mm/2 - ht_pipe_exposed_length_mm) + pipe_total/2;

  color([0.85, 0.85, 0.8])
  difference() {
    translate([pipe_center_x, 0, 0]) tube_x(r_pipe, pipe_total, center=true);
    translate([pipe_center_x, 0, 0]) tube_x(r_bore, pipe_total + 2*overlap_mm, center=true);
  }
}

module t_fitting() {
  color("Silver")
  difference() {
    union() {
      // Main run outer
      tube_x(r_outer, main_run_length_mm, center=true);

      // Branch outer: centered so it intersects main run at origin and extends +Y
      translate([0, branch_length_mm/2 - overlap_mm, 0])
        tube_y(r_outer, branch_length_mm + 2*overlap_mm, center=true);

      // Junction collar
      sphere(r=r_outer + fillet_radius_mm);

      // Socket stops (rings inside sockets)
      // Left stop
      translate([-main_run_length_mm/2 + socket_depth_mm - stop_thickness_mm/2, 0, 0])
        rotate([0,90,0])
        difference() {
          cylinder(r=r_sock, h=stop_thickness_mm, center=true);
          cylinder(r=max(0.01, r_sock - stop_radial_mm), h=stop_thickness_mm + 2*overlap_mm, center=true);
        }

      // Right stop
      translate([ main_run_length_mm/2 - socket_depth_mm + stop_thickness_mm/2, 0, 0])
        rotate([0,90,0])
        difference() {
          cylinder(r=r_sock, h=stop_thickness_mm, center=true);
          cylinder(r=max(0.01, r_sock - stop_radial_mm), h=stop_thickness_mm + 2*overlap_mm, center=true);
        }

      // Branch stop (near branch end, inside socket)
      translate([0, branch_length_mm - socket_depth_mm + stop_thickness_mm/2, 0])
        rotate([90,0,0])
        difference() {
          cylinder(r=r_sock, h=stop_thickness_mm, center=true);
          cylinder(r=max(0.01, r_sock - stop_radial_mm), h=stop_thickness_mm + 2*overlap_mm, center=true);
        }
    }

    // Internal flow bore (through main and branch)
    union() {
      tube_x(r_bore, main_run_length_mm + 2*overlap_mm, center=true);
      translate([0, branch_length_mm/2 - overlap_mm, 0])
        tube_y(r_bore, branch_length_mm + 4*overlap_mm, center=true);
    }

    // Socket bores (enlarged ends)
    union() {
      // Left socket bore spans x in [-main/2, -main/2 + socket_depth]
      translate([-main_run_length_mm/2 + (socket_depth_mm + overlap_mm)/2, 0, 0])
        rotate([0,90,0])
        cylinder(r=r_sock, h=socket_depth_mm + overlap_mm, center=true);

      // Right socket bore spans x in [main/2 - socket_depth, main/2]
      translate([ main_run_length_mm/2 - (socket_depth_mm + overlap_mm)/2, 0, 0])
        rotate([0,90,0])
        cylinder(r=r_sock, h=socket_depth_mm + overlap_mm, center=true);

      // Branch socket bore spans y in [branch_length - socket_depth, branch_length]
      translate([0, branch_length_mm - (socket_depth_mm + overlap_mm)/2, 0])
        rotate([90,0,0])
        cylinder(r=r_sock, h=socket_depth_mm + overlap_mm, center=true);
    }

    // Lead-in chamfers (conical cuts) - ensure they actually cut into the socket mouths
    union() {
      // Left end chamfer: spans x in [-main/2, -main/2 + chamfer]
      translate([-main_run_length_mm/2 + chamfer_mm/2, 0, 0])
        rotate([0,90,0])
        cylinder(r1=r_sock, r2=0, h=chamfer_mm, center=true);

      // Right end chamfer: spans x in [main/2 - chamfer, main/2]
      translate([ main_run_length_mm/2 - chamfer_mm/2, 0, 0])
        rotate([0,-90,0])
        cylinder(r1=r_sock, r2=0, h=chamfer_mm, center=true);

      // Branch end chamfer: spans y in [branch_length - chamfer, branch_length]
      translate([0, branch_length_mm - chamfer_mm/2, 0])
        rotate([-90,0,0])
        cylinder(r1=r_sock, r2=0, h=chamfer_mm, center=true);
    }
  }
}

module assembly() {
  // One connected solid: HT pipe overlaps into left socket by ht_pipe_insert_length_mm
  union() {
    t_fitting();
    ht_pipe();
  }
}

assembly();