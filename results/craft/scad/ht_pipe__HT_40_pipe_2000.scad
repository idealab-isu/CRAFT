// HT 40 pipe 2000 mm (axis along X so front/back/left/right views show the length)

// Parameters
nominal_size = 40; //[20:80:1]
length_mm = 2000; //[1000:4000:10]
ht40_outer_diameter = 40; //[30:60:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
include_end_fitting = 1; //[0:1:1]
end_fitting_length = 25; //[10:60:1]
end_fitting_radial_clearance = 0.2; //[0:1:0.05]
connect_overlap = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - complete geometry
module ht_pipe() {
  od = ht40_outer_diameter;
  wt = ht40_wall_thickness;
  id = max(0.01, od - 2*wt);

  // Keep inner cut slightly longer to guarantee a clean through-hole
  eps = 0.2;

  // Build along Z then rotate so length is along X (better orthographic visibility)
  rotate([0, 90, 0]) {
    color([0.85, 0.85, 0.8]) {
      union() {
        // Main pipe (hollow)
        difference() {
          cylinder(d=od, h=length_mm, center=true);
          cylinder(d=id, h=length_mm + 2*eps, center=true);
        }

        // End fitting stub (solid sleeve) connected with computed translate + overlap
        if (include_end_fitting) {
          translate([0, 0, length_mm/2 + end_fitting_length/2 - connect_overlap])
            cylinder(d=od + 2*end_fitting_radial_clearance, h=end_fitting_length, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();