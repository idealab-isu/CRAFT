// Parameters
bend_angle_deg = 90; //[45:135:1]
pipe_outer_diameter_mm = 90; //[45:180:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
clearance_mm = 0.2; //[0.0:1.0:0.05]
socket_depth_mm = 45; //[25:90:1]
cap_thickness_mm = 6; //[3:12:0.5]
chamfer_mm = 1; //[0.5:3:0.1]
fillet_radius_mm = 1; //[0.5:5:0.1]
stop_ring_thickness_mm = 3; //[1.5:6:0.5]
stop_ring_radial_mm = 2; //[1:5:0.5]
socket_wall_extra_mm = 3; //[1.5:8:0.5]
elbow_centerline_radius_mm = 60; //[30:120:1]
pipe_preview_length_mm = 80; //[30:200:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 96;

// Derived radii
pipe_ro = pipe_outer_diameter_mm/2;
pipe_ri = pipe_ro - wall_thickness_mm;

socket_ro = pipe_ro + socket_wall_extra_mm;
socket_ri = pipe_ro + clearance_mm;

cap_ro = socket_ro;
cap_ri = socket_ri;

// Elbow (sweep) radii
elbow_ro = socket_ro;
elbow_ri = socket_ri;

// Helper: ring (tube) cylinder
module tube_cyl(h, ro, ri, center=true) {
  difference() {
    cylinder(h=h, r=ro, center=center);
    cylinder(h=h + 2*overlap_mm, r=ri, center=center);
  }
}

// HT pipe preview (male pipe) aligned on +Z, end at z=0
module ht_pipe_preview() {
  color([0.85, 0.85, 0.8])
    translate([0,0, pipe_preview_length_mm/2 - overlap_mm])
      tube_cyl(pipe_preview_length_mm + 2*overlap_mm, pipe_ro, pipe_ri, center=true);
}

// Main part: 90° elbow with one socket and one cap (one connected solid)
module ht_90_cap() {
  color([0.15, 0.35, 0.65])
  union() {

    // Elbow wall (torus segment): outer sweep minus inner sweep
    difference() {
      rotate_extrude(angle=bend_angle_deg, convexity=10)
        translate([elbow_centerline_radius_mm, 0, 0])
          circle(r=elbow_ro);

      rotate_extrude(angle=bend_angle_deg, convexity=10)
        translate([elbow_centerline_radius_mm, 0, 0])
          circle(r=elbow_ri);
    }

    // Socket extension at start of elbow (axis +Z at x=R,y=0), overlapped into elbow
    translate([elbow_centerline_radius_mm, 0, socket_depth_mm/2 - overlap_mm])
      tube_cyl(socket_depth_mm + 2*overlap_mm, socket_ro, socket_ri, center=true);

    // Internal stop ring inside socket (connected to socket wall)
    translate([elbow_centerline_radius_mm, 0, socket_depth_mm - stop_ring_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(h=stop_ring_thickness_mm + 2*overlap_mm, r=socket_ri + stop_ring_radial_mm, center=true);
        cylinder(h=stop_ring_thickness_mm + 4*overlap_mm, r=socket_ri, center=true);
      }

    // Lead-in chamfer at socket mouth (z=0), connected to socket
    translate([elbow_centerline_radius_mm, 0, chamfer_mm/2 - overlap_mm])
      difference() {
        cylinder(h=chamfer_mm + 2*overlap_mm,
                 r1=socket_ri + chamfer_mm,
                 r2=socket_ri,
                 center=true);
        cylinder(h=chamfer_mm + 4*overlap_mm, r=socket_ri, center=true);
      }

    // Cap at end of elbow: axis must be tangent at end (along +X at x=0,y=R)
    // Place by rotating a Z-axis tube into X-axis, then translating to end point.
    translate([0, elbow_centerline_radius_mm, 0])
      rotate([0, 90, 0])
        translate([0, 0, cap_thickness_mm/2 - overlap_mm])
          tube_cyl(cap_thickness_mm + 2*overlap_mm, cap_ro, cap_ri, center=true);

    // Cap end-plate (solid disk) closing the cap, connected to cap tube
    translate([0, elbow_centerline_radius_mm, 0])
      rotate([0, 90, 0])
        translate([0, 0, cap_thickness_mm - overlap_mm])
          cylinder(h=cap_thickness_mm + 2*overlap_mm, r=cap_ri, center=true);
  }
}

// Assembly (single connected solid: blue part + optional preview pipe fused slightly)
module assembly() {
  union() {
    ht_90_cap();
    translate([elbow_centerline_radius_mm, 0, 0])
      ht_pipe_preview();
  }
}

assembly();