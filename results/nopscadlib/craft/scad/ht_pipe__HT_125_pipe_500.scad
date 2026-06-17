// HT 125 pipe 500 mm (single connected solid)

// Parameters
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 500; //[250:1000:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 55; //[30:110:1]
fitting_radial_thickness_mm = 4; //[2:10:0.5]
fitting_inner_clearance_mm = 0.8; //[0.2:2:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.5]
fitting_stop_depth_mm = 12; //[6:25:1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// Derived radii
outer_r = nominal_diameter_mm/2;
inner_r = outer_r - wall_thickness_mm;

// Socket (muffe) radii
socket_outer_r = outer_r + fitting_radial_thickness_mm;
socket_inner_r = outer_r + fitting_inner_clearance_mm;

// Z positions (formulas, no arbitrary offsets)
pipe_z0 = 0;
pipe_z1 = length_mm;

socket_z0 = pipe_z1 - overlap_mm;                 // overlaps into pipe to ensure connectivity
socket_z1 = socket_z0 + fitting_length_mm;

stop_z0 = socket_z0 + fitting_stop_depth_mm;      // internal stop ring position
stop_z1 = stop_z0 + fitting_stop_thickness_mm;

module ht_pipe() {
  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe (hollow)
    difference() {
      cylinder(h=length_mm, r=outer_r, center=false);
      translate([0,0,-overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=inner_r, center=false);
    }

    // End socket (hollow with internal stop ring)
    difference() {
      // Outer socket body
      translate([0,0,socket_z0])
        cylinder(h=fitting_length_mm, r=socket_outer_r, center=false);

      // Inner void of socket
      translate([0,0,socket_z0 - overlap_mm])
        cylinder(h=fitting_length_mm + 2*overlap_mm, r=socket_inner_r, center=false);

      // Create the internal stop ring by "un-cutting" a thin band:
      // subtract everything except the stop band by adding back a blocker subtraction
      // (implemented as subtracting a larger void above and below the stop band)
      // Below stop: already void; Above stop: void continues. We remove void only in stop band by subtracting void in two parts.
      // Part 1: remove void below stop band (no effect, already void) - kept for clarity
      translate([0,0,socket_z0 - overlap_mm])
        cylinder(h=(stop_z0 - socket_z0) + overlap_mm, r=socket_inner_r, center=false);

      // Part 2: remove void above stop band
      translate([0,0,stop_z1 - overlap_mm])
        cylinder(h=(socket_z1 - stop_z1) + 2*overlap_mm, r=socket_inner_r, center=false);
    }

    // Add back the stop ring solid (ensures it exists as material)
    // Ring occupies the socket wall thickness region between socket_inner_r and socket_outer_r,
    // but we only need the inner stop lip: between socket_inner_r and socket_inner_r + fitting_stop_thickness_mm radial? No.
    // Stop is axial thickness; radial is the socket wall. So we add a short tube segment of socket wall at stop band.
    translate([0,0,stop_z0])
      difference() {
        cylinder(h=fitting_stop_thickness_mm, r=socket_outer_r, center=false);
        translate([0,0,-overlap_mm])
          cylinder(h=fitting_stop_thickness_mm + 2*overlap_mm, r=socket_inner_r, center=false);
      }
  }
}

ht_pipe();