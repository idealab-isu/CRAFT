$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size_mm = 32; //[16:64:1]
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 32; //[16:64:0.5]
wall_mm = 2.0; //[1.0:4.0:0.1]
fit_len_mm = 35; //[18:70:1]
fit_wall_extra_mm = 1.5; //[0.5:3.0:0.1]
fit_id_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Robust epsilon to avoid coplanar/zero-thickness artifacts
eps = 0.05;

// Derived
outer_r = od_mm/2;
inner_r = max(0.01, outer_r - wall_mm);

fit_outer_r = outer_r + fit_wall_extra_mm;
// Socket ID slightly larger than pipe OD
fit_inner_r = outer_r + fit_id_clearance_mm/2;

// Pipe segment (hollow tube)
module ht_pipe() {
  difference() {
    cylinder(h=length_mm, r=outer_r, center=false);
    translate([0, 0, -eps])
      cylinder(h=length_mm + 2*eps, r=inner_r, center=false);
  }
}

// End fitting (socket) placed at the end, overlapping into pipe by overlap_mm
module end_fitting() {
  // Start the fitting so it extends beyond the pipe end by overlap_mm (guaranteed union contact)
  z0 = length_mm - fit_len_mm + overlap_mm;

  difference() {
    translate([0, 0, z0])
      cylinder(h=fit_len_mm, r=fit_outer_r, center=false);

    // Inner void through the fitting; extend slightly to avoid coplanar faces
    translate([0, 0, z0 - eps])
      cylinder(h=fit_len_mm + 2*eps, r=fit_inner_r, center=false);
  }
}

// Assembly (one connected solid)
module assembly() {
  union() {
    ht_pipe();
    if (include_end_fitting) end_fitting();
  }
}

assembly();