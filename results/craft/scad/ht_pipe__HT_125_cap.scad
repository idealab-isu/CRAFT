$fn = 180;

// Parameters
nominal_diameter = 125; //[60:250:1]
cap_outer_diameter = 125; //[80:200:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_inner_diameter = 125; //[80:200:1]
socket_depth = 50; //[25:100:1]
end_face_thickness = 4; //[2:10:0.5]
lead_in_chamfer_angle_deg = 30; //[10:60:1]
pipe_wall_thickness = 3.2; //[1.6:6.4:0.1]
pipe_length = 120; //[60:240:1]
overlap = 1; //[0.5:2:0.1]
chamfer_radial = 2; //[1:5:0.1]
outer_chamfer_radial = 1.5; //[0.5:4:0.1]

// Derived
cap_r      = cap_outer_diameter/2;
socket_r   = socket_inner_diameter/2;
pipe_od_r  = socket_r; // pipe OD matches socket ID for assembly
pipe_id_r  = pipe_od_r - pipe_wall_thickness;

cap_total_h = socket_depth + end_face_thickness;

// Chamfer height from angle (avoid div by 0)
function chamfer_h(radial, ang_deg) = radial / max(0.001, tan(ang_deg * PI / 180));

module ht125_cap_with_pipe() {
  color([0.85, 0.85, 0.8])
  union() {

    // CAP: closed end + socket (open at bottom)
    difference() {
      // Outer body
      cylinder(r=cap_r, h=cap_total_h, center=false);

      // Inner cavity: stop before the closed end to ensure a solid end face
      translate([0,0,-overlap])
        cylinder(r=socket_r, h=socket_depth + overlap, center=false);

      // Lead-in chamfer at socket mouth (bottom)
      translate([0,0,-overlap])
        cylinder(
          r1 = socket_r + chamfer_radial,
          r2 = socket_r,
          h  = chamfer_h(chamfer_radial, lead_in_chamfer_angle_deg) + overlap,
          center=false
        );

      // Outer chamfer at the closed-end rim (top)
      translate([0,0,cap_total_h - outer_chamfer_radial])
        cylinder(
          r1 = cap_r + outer_chamfer_radial,
          r2 = cap_r,
          h  = outer_chamfer_radial + overlap,
          center=false
        );
    }

    // PIPE: inserted into socket and connected (overlaps into cap by 'overlap')
    // Pipe top ends at z = socket_depth + overlap, which is inside the cap solid region.
    translate([0,0,-pipe_length + socket_depth + overlap])
      difference() {
        cylinder(r=pipe_od_r, h=pipe_length, center=false);
        translate([0,0,-overlap])
          cylinder(r=pipe_id_r, h=pipe_length + 2*overlap, center=false);
      }
  }
}

ht125_cap_with_pipe();