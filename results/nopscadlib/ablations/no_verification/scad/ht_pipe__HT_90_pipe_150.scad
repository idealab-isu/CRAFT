// HT 90 pipe 150 mm (single connected solid, hollow, with one socket end)

// Parameters
nominal_diameter = 90; //[45:180:1]
length_mm = 150;       //[75:300:1]
od_mm = 90;            //[45:180:1]
wall_mm = 3.2;         //[1.6:6.4:0.1]
fitting_len_mm = 35;   //[18:70:1]
fitting_radial_add_mm = 4; //[2:8:0.5]
connect_overlap_mm = 1;     //[0.5:2:0.1]

$fn = 96;

module ht_pipe() {
  outer_r = od_mm/2;
  inner_r = max(0.01, outer_r - wall_mm);

  // Small epsilon to avoid coplanar faces
  eps = 0.02;

  // Ensure overlap is valid and creates a connected sleeve
  overlap = min(connect_overlap_mm, fitting_len_mm - eps);

  // Sleeve starts at the pipe end and extends outward, overlapping into the pipe
  sleeve_z0 = length_mm - overlap;
  sleeve_h  = fitting_len_mm;

  // Inner bores: open at both ends (typical pipe), so no bottom "cap"
  // Main bore runs full length; sleeve bore runs full sleeve length.
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (pipe + sleeve), unioned so it's one connected body
    union() {
      cylinder(h=length_mm, r=outer_r, center=false);

      translate([0, 0, sleeve_z0])
        cylinder(h=sleeve_h, r=outer_r + fitting_radial_add_mm, center=false);
    }

    // INNER VOID (continuous through), unioned
    union() {
      // Main bore (open both ends)
      translate([0, 0, -eps])
        cylinder(h=length_mm + 2*eps, r=inner_r, center=false);

      // Sleeve bore (open at far end)
      translate([0, 0, sleeve_z0 - eps])
        cylinder(h=sleeve_h + 2*eps, r=inner_r, center=false);
    }
  }
}

ht_pipe();