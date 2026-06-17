// HT 50 T pipe (connected, non-empty solid) - corrected to be ONE connected solid

// ---------- Parameters ----------
nominal_size = 50; //[25:110:1]
branch_angle_deg = 90; //[45:90:1]  // (kept for UI; model uses 90° T)
outer_diameter_mm = 50; //[25:110:1]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
socket_depth_mm = 35; //[18:70:1]
socket_outer_extra_mm = 3; //[1.5:8:0.5]
junction_core_length_mm = 18; //[10:40:1]
junction_blend_radius_mm = 10; //[5:25:1]
stop_ring_height_mm = 2; //[1:5:0.5]
stop_ring_thickness_mm = 1.2; //[0.6:3:0.1]
chamfer_length_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
ht_pipe_length_mm = 60; //[30:200:1]
ht_pipe_clearance_mm = 0.4; //[0.1:1.2:0.1]

// ---------- Derived ----------
$fn = 96;

outer_r = outer_diameter_mm/2;
socket_outer_r = outer_r + socket_outer_extra_mm;

// Ensure valid wall
inner_r = max(0.1, outer_r - wall_thickness_mm);
pipe_outer_r = max(0.1, outer_r - ht_pipe_clearance_mm);
pipe_inner_r = max(0.1, pipe_outer_r - wall_thickness_mm);

// Socket overall length along each axis (centered)
socket_len = 2*socket_depth_mm + junction_core_length_mm;

// Place attached straight pipes so they CONNECT to socket mouths with overlap
pipe_center_offset = socket_len/2 + ht_pipe_length_mm/2 - overlap_mm;

// ---------- Modules ----------
module ht_pipe(len=ht_pipe_length_mm) {
  // A short pipe segment (hollow)
  difference() {
    cylinder(r=pipe_outer_r, h=len, center=true);
    translate([0,0,-overlap_mm])
      cylinder(r=pipe_inner_r, h=len + 2*overlap_mm, center=true);
  }
}

module stop_ring_z(zpos) {
  // Internal stop ring inside the Z socket
  translate([0,0,zpos])
    difference() {
      cylinder(r=inner_r, h=stop_ring_height_mm, center=true);
      translate([0,0,-overlap_mm])
        cylinder(r=max(0.1, inner_r - stop_ring_thickness_mm),
                 h=stop_ring_height_mm + 2*overlap_mm, center=true);
    }
}

module stop_ring_x(xpos) {
  // Internal stop ring inside the X socket
  translate([xpos,0,0])
    rotate([0,90,0])
      difference() {
        cylinder(r=inner_r, h=stop_ring_height_mm, center=true);
        translate([0,0,-overlap_mm])
          cylinder(r=max(0.1, inner_r - stop_ring_thickness_mm),
                   h=stop_ring_height_mm + 2*overlap_mm, center=true);
      }
}

module t_fitting() {
  // Outer union minus inner bores/chamfers; stop rings are ADDED after subtraction
  union() {
    difference() {
      // ---- OUTER SOLID ----
      union() {
        // Outer sockets
        cylinder(r=socket_outer_r, h=socket_len, center=true);
        rotate([0,90,0])
          cylinder(r=socket_outer_r, h=socket_len, center=true);

        // Blended junction core (kept compact to avoid bulging "X" artifacts)
        // Use a hull of small spheres around the intersection region.
        hull() {
          sphere(r=junction_blend_radius_mm);
          translate([ junction_core_length_mm/2, 0, 0]) sphere(r=junction_blend_radius_mm);
          translate([-junction_core_length_mm/2, 0, 0]) sphere(r=junction_blend_radius_mm);
          translate([0, 0,  junction_core_length_mm/2]) sphere(r=junction_blend_radius_mm);
          translate([0, 0, -junction_core_length_mm/2]) sphere(r=junction_blend_radius_mm);
        }
      }

      // ---- SUBTRACT: INTERNAL BORES + CHAMFERS ----
      union() {
        // Internal flow bores (through both axes)
        cylinder(r=inner_r, h=socket_len + 2*overlap_mm, center=true);
        rotate([0,90,0])
          cylinder(r=inner_r, h=socket_len + 2*overlap_mm, center=true);

        // Entry chamfers at the four socket mouths (subtractive)
        // Z+ mouth
        translate([0,0, socket_len/2 - chamfer_length_mm/2])
          cylinder(r1=inner_r + chamfer_length_mm, r2=inner_r,
                   h=chamfer_length_mm, center=true);
        // Z- mouth
        translate([0,0,-socket_len/2 + chamfer_length_mm/2])
          rotate([180,0,0])
            cylinder(r1=inner_r + chamfer_length_mm, r2=inner_r,
                     h=chamfer_length_mm, center=true);

        // X+ mouth
        translate([ socket_len/2 - chamfer_length_mm/2,0,0])
          rotate([0,90,0])
            cylinder(r1=inner_r + chamfer_length_mm, r2=inner_r,
                     h=chamfer_length_mm, center=true);
        // X- mouth
        translate([-socket_len/2 + chamfer_length_mm/2,0,0])
          rotate([0,-90,0])
            cylinder(r1=inner_r + chamfer_length_mm, r2=inner_r,
                     h=chamfer_length_mm, center=true);
      }
    }

    // ---- ADD: INTERNAL STOP RINGS (must not be subtracted away) ----
    // Place rings inside each socket, near the mouths but within the socket depth.
    // Use formulas (no arbitrary offsets).
    stop_ring_z( socket_len/2 - socket_depth_mm/2);
    stop_ring_z(-socket_len/2 + socket_depth_mm/2);

    stop_ring_x( socket_len/2 - socket_depth_mm/2);
    stop_ring_x(-socket_len/2 + socket_depth_mm/2);
  }
}

module assembly() {
  // One connected solid: fitting + three connected pipe segments
  union() {
    t_fitting();

    // Z+ pipe
    translate([0,0, pipe_center_offset])
      ht_pipe();

    // Z- pipe
    translate([0,0,-pipe_center_offset])
      ht_pipe();

    // X+ pipe (branch)
    translate([ pipe_center_offset,0,0])
      rotate([0,90,0])
        ht_pipe();
  }
}

// ---------- Render ----------
color([0.78,0.78,0.78]) assembly();