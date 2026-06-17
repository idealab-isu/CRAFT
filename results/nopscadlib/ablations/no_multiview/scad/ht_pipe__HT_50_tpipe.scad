// Parameters
nominal_diameter_mm = 50; //[25:100:1]
port_count = 3; //[3:3:1]
main_run_angle_deg = 180; //[180:180:1]
branch_angle_deg = 90; //[45:90:1]
pipe_od = 50; //[25:100:1]
pipe_wall = 2.4; //[1.2:4.8:0.1]
socket_wall_extra = 1.6; //[0.8:3.2:0.1]
socket_length = 35; //[18:70:1]
hub_length_each_side = 18; //[9:36:1]
branch_hub_length = 18; //[9:36:1]
overlap = 1; //[0.5:2:0.1]
ht_pipe_stub_length = 80; //[40:160:1]
flow_clearance = 0.4; //[0.2:1.0:0.1]

$fn = 64;

// HT Pipe - complete geometry (hollow stub)
module ht_pipe() {
  difference() {
    cylinder(r=pipe_od/2, h=ht_pipe_stub_length, center=true);
    translate([0,0,-overlap])
      cylinder(r=(pipe_od/2) - pipe_wall, h=ht_pipe_stub_length + 2*overlap, center=true);
  }
}

// Tee fitting - complete geometry (single solid via difference of outer - inner)
module tee_fitting() {

  // Key lengths along axes (centered cylinders)
  main_outer_len   = 2*hub_length_each_side + 2*socket_length;
  branch_outer_len = branch_hub_length + socket_length;

  main_inner_len   = main_outer_len   + 2*overlap;
  branch_inner_len = branch_outer_len + 2*overlap;

  outer_r = (pipe_od/2) + socket_wall_extra;
  inner_r = (pipe_od/2) - pipe_wall + flow_clearance;

  difference() {
    // OUTER SOLID (unioned)
    union() {
      // Main run outer body
      rotate([0,90,0])
        cylinder(r=outer_r, h=main_outer_len, center=true);

      // Branch outer body (centered at origin so it intersects main run)
      rotate([90,0,0])
        cylinder(r=outer_r, h=branch_outer_len, center=true);

      // Socket end reinforcements (kept, but ensured to overlap with main/branch)
      translate([-(hub_length_each_side + socket_length/2 - overlap), 0, 0])
        rotate([0,90,0])
          cylinder(r=outer_r, h=socket_length + 2*overlap, center=true);

      translate([(hub_length_each_side + socket_length/2 - overlap), 0, 0])
        rotate([0,90,0])
          cylinder(r=outer_r, h=socket_length + 2*overlap, center=true);

      translate([0, (branch_hub_length + socket_length/2 - overlap), 0])
        rotate([90,0,0])
          cylinder(r=outer_r, h=socket_length + 2*overlap, center=true);
    }

    // INNER FLOW PASSAGE (subtracted)
    union() {
      rotate([0,90,0])
        cylinder(r=inner_r, h=main_inner_len, center=true);

      rotate([90,0,0])
        cylinder(r=inner_r, h=branch_inner_len, center=true);
    }
  }
}

// Assembly: attach the previously floating stub to the right socket with 1-2mm overlap
module assembly() {
  color([0.85, 0.85, 0.8])
  union() {
    tee_fitting();

    // Place stub so its left end penetrates into the right socket by `overlap`
    // Tee rightmost outer face is at +main_outer_len/2
    // Stub half-length is ht_pipe_stub_length/2
    main_outer_len = 2*hub_length_each_side + 2*socket_length;

    translate([ main_outer_len/2 + ht_pipe_stub_length/2 - overlap, 0, 0 ])
      rotate([0,90,0])  // align stub axis with main run (X axis)
        ht_pipe();
  }
}

assembly();