$fn = 128;

// Parameters
nominal_diameter_mm = 32; //[16:64:1]
pipe_od = 32; //[16:64:1]
pipe_wall = 2.0; //[1.0:4.0:0.1]
socket_clearance = 0.4; //[0.1:1.0:0.1]
cap_wall = 3.0; //[1.5:6.0:0.1]
socket_depth = 25; //[12:50:1]
end_wall_thickness = 4.0; //[2.0:8.0:0.1]
stop_lip_thickness = 2.0; //[1.0:4.0:0.1]
stop_lip_radial = 1.5; //[0.5:3.0:0.1]
cap_outer_extra = 6.0; //[3.0:12.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
pipe_stub_length = 40; //[20:120:1]

// Derived
cap_h = socket_depth + end_wall_thickness;
cap_r_outer = (pipe_od + cap_outer_extra) / 2;
socket_r = (pipe_od + 2 * socket_clearance) / 2;
pipe_r_outer = pipe_od / 2;
pipe_r_inner = pipe_r_outer - pipe_wall;

module ht_pipe() {
  difference() {
    cylinder(r=pipe_r_outer, h=pipe_stub_length, center=true);
    cylinder(r=pipe_r_inner, h=pipe_stub_length + overlap, center=true);
  }
}

module ht_32_cap_body() {
  union() {
    // Cap shell with socket bore (open at bottom)
    difference() {
      cylinder(r=cap_r_outer, h=cap_h, center=true);

      // Bore: from bottom face upward socket_depth
      translate([0, 0, -cap_h/2 + socket_depth/2 - overlap/2])
        cylinder(r=socket_r, h=socket_depth + overlap, center=true);
    }

    // Internal stop lip near the closed end (top), inside the bore
    translate([0, 0, cap_h/2 - end_wall_thickness - stop_lip_thickness/2 + overlap/2])
      cylinder(r=socket_r - stop_lip_radial, h=stop_lip_thickness + overlap, center=true);
  }
}

module assembly() {
  union() {
    ht_32_cap_body();

    // Connect pipe to cap by aligning pipe top with socket top (inside cap),
    // and push slightly further in to guarantee overlap.
    // Socket top Z = -cap_h/2 + socket_depth
    // Pipe top Z   = pipe_center_z + pipe_stub_length/2
    pipe_center_z = (-cap_h/2 + socket_depth) - pipe_stub_length/2 + overlap;

    translate([0, 0, pipe_center_z])
      ht_pipe();
  }
}

assembly();