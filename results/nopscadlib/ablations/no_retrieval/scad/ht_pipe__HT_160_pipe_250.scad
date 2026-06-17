// HT pipe: HT 160, length 250 mm
// Fixed: clearly hollow in orthographic views by leaving BOTH ends open (no end caps),
// proper connected socket/bell end, and all placements derived from dimensions.

$fn = 180;

// Parameters
pipe_length = 250;                 // mm
outer_diameter = 160;              // mm
wall_thickness = 4.7;              // mm

socket_length = 60;                // mm (bell length)
socket_wall_extra = 3.0;           // mm (OD increase at socket)

gasket_groove_width = 10;          // mm
gasket_groove_depth = 2.0;         // mm
gasket_groove_offset_from_end = 18;// mm from socket mouth inward

chamfer_length = 2.0;              // mm
chamfer_radial = 1.5;              // mm

marking_band_width = 6;            // mm
marking_band_height = 0.6;         // mm
marking_band_offset_from_socket = 90; // mm from socket end toward plain end

overlap = 1.0;                     // mm (boolean robustness)

// Derived radii
ro = outer_diameter/2;
ri = ro - wall_thickness;

ro_socket = ro + socket_wall_extra;

// Socket inner step (enlarged ID inside socket)
socket_id_extra = socket_wall_extra;
ri_socket = ri + socket_id_extra;

// Axial reference (pipe centered at Z=0)
z_plain_end  = -pipe_length/2;
z_socket_end =  pipe_length/2;

// Helpers
module cyl(h, r, center=true) { cylinder(h=h, r=r, center=center); }
module cyl_taper(h, r1, r2, center=true) { cylinder(h=h, r1=r1, r2=r2, center=center); }

// Outer solids
module outer_main() {
  cyl(pipe_length, ro, center=true);
}

module outer_socket() {
  // Socket occupies last socket_length at +Z end, overlapping slightly into main body
  translate([0,0, z_socket_end - socket_length/2 + overlap/2])
    cyl(socket_length + overlap, ro_socket, center=true);
}

module marking_band(zc) {
  translate([0,0, zc])
    cyl(marking_band_width, ro + marking_band_height, center=true);
}

module outer_with_details() {
  union() {
    outer_main();
    outer_socket();

    // Marking bands on plain OD (do not extend onto socket)
    marking_band(z_socket_end - marking_band_offset_from_socket);
    marking_band(z_socket_end - (marking_band_offset_from_socket + 2*marking_band_width));
  }
}

// Inner voids (bores) - IMPORTANT: keep both ends open so orthographic views show a ring, not a disk.
module inner_bore_main_open_ends() {
  // Through-bore for the whole pipe, extended beyond both ends to guarantee open ends
  cyl(pipe_length + 4*overlap, ri, center=true);
}

module inner_bore_socket_enlarged_open_end() {
  // Enlarged ID inside socket region (bell), extended beyond socket mouth to keep it open
  translate([0,0, z_socket_end - socket_length/2 + overlap/2])
    cyl(socket_length + 4*overlap, ri_socket, center=true);
}

// Chamfers (subtractive)
module chamfer_outer_plain_end() {
  // Outer chamfer at plain end (-Z)
  translate([0,0, z_plain_end + chamfer_length/2])
    cyl_taper(chamfer_length + 2*overlap, ro - chamfer_radial, ro, center=true);
}

module chamfer_outer_socket_end() {
  // Outer chamfer at socket mouth (+Z)
  translate([0,0, z_socket_end - chamfer_length/2])
    cyl_taper(chamfer_length + 2*overlap, ro_socket, ro_socket - chamfer_radial, center=true);
}

module chamfer_inner_plain_end() {
  // Inner chamfer at plain end (-Z)
  translate([0,0, z_plain_end + chamfer_length/2])
    cyl_taper(chamfer_length + 2*overlap, ri, max(ri - chamfer_radial, 0.01), center=true);
}

module chamfer_inner_socket_end() {
  // Inner chamfer at socket mouth (+Z) on enlarged socket ID
  translate([0,0, z_socket_end - chamfer_length/2])
    cyl_taper(chamfer_length + 2*overlap, ri_socket, max(ri_socket - chamfer_radial, 0.01), center=true);
}

// Gasket groove (subtractive) inside socket, cut into socket wall (radially outward from socket ID)
module gasket_groove_cut() {
  // Groove center position measured from socket end inward
  zc = z_socket_end - gasket_groove_offset_from_end;

  translate([0,0, zc])
    difference() {
      cyl(gasket_groove_width + 2*overlap, ri_socket + gasket_groove_depth, center=true);
      cyl(gasket_groove_width + 4*overlap, ri_socket, center=true);
    }
}

// Final model
module ht_pipe_160_L250() {
  difference() {
    // Outer connected solid
    outer_with_details();

    // Inner voids + details (subtractive)
    union() {
      inner_bore_main_open_ends();
      inner_bore_socket_enlarged_open_end();

      // Chamfers
      chamfer_inner_plain_end();
      chamfer_inner_socket_end();
      chamfer_outer_plain_end();
      chamfer_outer_socket_end();

      // Gasket groove
      gasket_groove_cut();
    }
  }
}

ht_pipe_160_L250();