// Parameters
pipe_standard = 0; //[0:0:1]
nominal_size = 40; //[20:80:1]
length_mm = 1000; //[500:2000:10]
center = 0; //[0:1:1]
include_end_fitting = 1; //[0:1:1]
ht40_od = 40; //[30:60:0.5]
ht40_wall = 1.8; //[1:3.6:0.1]
end_interface_length = 25; //[10:60:1]
end_interface_radial = 1.5; //[0.5:4:0.1]
connect_overlap = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - one connected solid
module ht_pipe() {
  od_r = ht40_od/2;
  id_r = max(0.01, od_r - ht40_wall);

  // Z placement (optionally centered)
  z0 = (center == 1) ? -length_mm/2 : 0;

  // End fitting placement (connected to main pipe with overlap)
  fit_h = end_interface_length;
  fit_r = od_r + end_interface_radial;
  fit_z = z0 + length_mm - fit_h - connect_overlap; // overlaps into main by connect_overlap

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: union of main pipe + optional end fitting (connected)
    union() {
      translate([0, 0, z0])
        cylinder(h=length_mm, r=od_r, center=false);

      if (include_end_fitting)
        translate([0, 0, fit_z])
          cylinder(h=fit_h + connect_overlap, r=fit_r, center=false);
    }

    // INNER VOID: continuous bore through entire length (and through fitting)
    translate([0, 0, z0 - connect_overlap])
      cylinder(h=length_mm + 2*connect_overlap, r=id_r, center=false);
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();