$fn = 128;

// Parameters
nominal_diameter_mm = 90;      //[45:180:1]
length_mm = 250;               //[125:500:1]
wall_thickness_mm = 3.2;       //[1.6:6.4:0.1]
fitting_length_mm = 28;        //[14:56:1]
fitting_radial_add_mm = 4;     //[2:8:0.5]
overlap_mm = 1;                //[0.5:2:0.1]

// Derived
outer_r = nominal_diameter_mm/2;
inner_r = outer_r - wall_thickness_mm;
socket_outer_r = outer_r + fitting_radial_add_mm;

// HT Pipe - one connected solid
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: main pipe + socket, socket overlaps into main pipe by overlap_mm
    union() {
      cylinder(h=length_mm, r=outer_r, center=false);

      // Socket at bottom end, extends below 0 and overlaps into main pipe
      translate([0, 0, -fitting_length_mm + overlap_mm])
        cylinder(h=fitting_length_mm, r=socket_outer_r, center=false);
    }

    // INNER VOID: continuous bore through entire length + socket region
    translate([0, 0, -fitting_length_mm - overlap_mm])
      cylinder(h=length_mm + fitting_length_mm + overlap_mm*2, r=inner_r, center=false);
  }
}

ht_pipe();