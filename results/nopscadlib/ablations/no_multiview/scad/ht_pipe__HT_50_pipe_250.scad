// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 50; //[25:100:1]
length_mm = 250; //[125:500:1]
end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
ht50_outer_diameter = 50; //[45:60:0.1]
ht50_wall_thickness = 1.8; //[1:3.6:0.1]
fitting_length = 35; //[20:70:1]
fitting_od_factor = 1.18; //[1.05:1.4:0.01]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
socket_clearance = 0.4; //[0.1:1:0.05]
stop_ring_thickness = 2; //[1:5:0.1]
stop_ring_depth = 2; //[1:6:0.1]

// HT Pipe - fixed connectivity (no floating caps, all in one union with overlap)
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {

    // Derived dimensions
    main_h = length_mm - (end_fitting * fitting_length);   // straight pipe length
    fit_h  = end_fitting * fitting_length;

    // Place main pipe centered at Z=0
    main_z = 0;

    // Attach fitting to TOP end of main pipe with guaranteed overlap
    // main top face at +main_h/2
    // fitting bottom face at (fit_z - fit_h/2)
    // enforce: (fit_z - fit_h/2) = main_h/2 - overlap_mm  => fit_z = main_h/2 + fit_h/2 - overlap_mm
    fit_z = (main_h/2) + (fit_h/2) - overlap_mm;

    union() {

      // --- SOLID GEOMETRY (outer shells + stop ring) ---
      difference() {
        union() {
          // Main outer pipe
          translate([0, 0, main_z])
            cylinder(r=ht50_outer_diameter/2, h=main_h, center=true);

          // Integrated end fitting outer shell (attached, overlapping)
          if (end_fitting == 1) {
            translate([0, 0, fit_z])
              cylinder(r=(ht50_outer_diameter * fitting_od_factor) / 2, h=fit_h, center=true);

            // Stop ring near the top end of the fitting (still part of the solid)
            // Position so it stays within the fitting and remains connected
            stop_z = fit_z + (fit_h/2) - (stop_ring_thickness/2) - overlap_mm;
            translate([0, 0, stop_z])
              cylinder(r=(ht50_outer_diameter + 2 * socket_clearance) / 2,
                       h=stop_ring_thickness, center=true);
          }
        }

        // --- VOIDS (subtract once so everything stays a single connected solid) ---

        // Main inner void (slightly longer for clean subtraction)
        translate([0, 0, main_z])
          cylinder(r=(ht50_outer_diameter - 2 * ht50_wall_thickness) / 2,
                   h=main_h + 2 * overlap_mm, center=true);

        if (end_fitting == 1) {
          // Socket void inside fitting (slightly longer)
          translate([0, 0, fit_z])
            cylinder(r=(ht50_outer_diameter + 2 * socket_clearance) / 2,
                     h=fit_h + 2 * overlap_mm, center=true);

          // Through-bore void (keeps continuity with main inner diameter)
          translate([0, 0, fit_z])
            cylinder(r=(ht50_outer_diameter - 2 * ht50_wall_thickness) / 2,
                     h=fit_h + 2 * overlap_mm, center=true);

          // Stop ring inner relief (creates the ring)
          stop_z = fit_z + (fit_h/2) - (stop_ring_thickness/2) - overlap_mm;
          translate([0, 0, stop_z])
            cylinder(r=((ht50_outer_diameter + 2 * socket_clearance) - 2 * stop_ring_depth) / 2,
                     h=stop_ring_thickness + 2 * overlap_mm, center=true);
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