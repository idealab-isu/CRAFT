// Parameters
base_width = 12; //[6:24:0.5]
base_height = 6; //[3:12:0.5]
gap_width = 3; //[1.5:6:0.25]
gap_height = 10; //[5:20:0.5]
stem_width = 2.5; //[1.25:5:0.25]
hole_diameter = 2.2; //[1.1:4.4:0.1]
hole_spacing = 8; //[4:16:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin = 3; //[1.5:6:0.5]
base_plate_thickness = 0.8; //[0.4:2:0.1]
overlap = 1; //[0.5:2:0.1]

$fn = 64;

// Derived sizes
pcb_w = hole_spacing + base_width + 2*pcb_margin;
pcb_d = base_width + 2*pcb_margin;

// Z stacking (intentional overlaps to ensure ONE connected solid)
z_body  = 0;
z_pcb   = -(base_height/2 + pcb_thickness/2 - overlap);
z_plate = z_pcb - (pcb_thickness/2 + base_plate_thickness/2 - overlap);

// Side terminals/blocks (added + attached with overlap)
term_w = 6;
term_d = 6;
term_h = 4;

// Place terminals on left/right of the body footprint and overlap into body by `overlap`
body_x_extent = hole_spacing/2 + base_width/2; // max X of the hex footprint
term_x = body_x_extent + term_w/2 - overlap;   // ensures intersection (no gap)
term_z = 0;                                    // centered on body so it intersects

module photo_interrupter_solid() {
  union() {

    // PCB (solid) - overlaps into body
    translate([0, 0, z_pcb])
      cube([pcb_w, pcb_d, pcb_thickness], center=true);

    // Base Plate (solid) - overlaps into PCB
    translate([0, 0, z_plate])
      cube([pcb_w, pcb_d, base_plate_thickness], center=true);

    // Left/Right side blocks/terminals (solid) - ATTACHED (overlap into body)
    translate([-term_x, 0, term_z])
      cube([term_w, term_d, term_h], center=true);

    translate([ term_x, 0, term_z])
      cube([term_w, term_d, term_h], center=true);

    // Photo interrupter body + arms with gap cutout and mounting holes
    // (This is the actual photo interrupter geometry; kept, but ensured connected via overlaps)
    difference() {
      union() {
        // Main body (hex-like footprint)
        translate([0, 0, z_body])
          linear_extrude(height=base_height, center=true)
            polygon(points=[
              [-hole_spacing/2 - base_width/2, 0],
              [-hole_spacing/2, -base_width/2],
              [ hole_spacing/2, -base_width/2],
              [ hole_spacing/2 + base_width/2, 0],
              [ hole_spacing/2,  base_width/2],
              [-hole_spacing/2,  base_width/2]
            ]);

        // Stems/Arms (connected to body by overlapping into body thickness)
        arm_h = gap_height + base_height;
        arm_z = (base_height/2 - overlap) + arm_h/2;

        translate([0, -(gap_width/2 + stem_width/2 - overlap), arm_z])
          cube([base_width, stem_width, arm_h], center=true);

        translate([0,  (gap_width/2 + stem_width/2 - overlap), arm_z])
          cube([base_width, stem_width, arm_h], center=true);
      }

      // Interrupter Gap (cutout between arms)
      gap_h = gap_height + base_height + 2*overlap;
      gap_z = (base_height/2 - overlap) + gap_h/2;

      translate([0, 0, gap_z])
        cube([base_width + 2*overlap, gap_width, gap_h], center=true);

      // Mounting holes: cut through BODY + PCB + BASE PLATE
      hole_h = (base_height + pcb_thickness + base_plate_thickness) + 4*overlap;
      hole_z = (z_plate - base_plate_thickness/2) + hole_h/2 - overlap;

      translate([-hole_spacing/2, 0, hole_z])
        cylinder(r=hole_diameter/2, h=hole_h, center=true);

      translate([ hole_spacing/2, 0, hole_z])
        cylinder(r=hole_diameter/2, h=hole_h, center=true);
    }
  }
}

photo_interrupter_solid();