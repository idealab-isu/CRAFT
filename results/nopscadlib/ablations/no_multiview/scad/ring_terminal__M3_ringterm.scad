// Parameters
type = 0; //[0:1:1]
thickness = 2; //[1:4:0.1]
width = 12; //[6:24:0.5]
outer_diameter = 18; //[9:36:0.5]
inner_diameter = 8; //[4:16:0.5]
overall_length = 45; //[25:90:1]
crimp_length = 18; //[8:36:1]
bolt_hole_diameter = 6; //[3:12:0.5]
bend_angle_deg = 45; //[0:75:1]
overlap = 1; //[0.5:2:0.1]
transition_length = 2; //[1:6:0.5]
wire_hole_diameter = 4; //[0:10:0.5]
assembly_plate_thickness = 6; //[3:12:0.5]
assembly_plate_size = 40; //[20:80:1]

$fn = 96;

// ---- Derived layout (Y axis is the terminal length direction) ----
ring_r = outer_diameter/2;

// Keep the original intent: overall_length measured from ring center to far end.
// Make the straight tab length such that: ring_r + tab_len + transition_length + crimp_length = overall_length
tab_len = max(0, overall_length - ring_r - transition_length - crimp_length);

// Segment centers along Y, with guaranteed overlaps between neighbors
y_ring = 0;
y_tab  = -(ring_r + tab_len/2 - overlap);
y_tran = -(ring_r + tab_len + transition_length/2 - overlap);
y_crmp = -(ring_r + tab_len + transition_length + crimp_length/2 - overlap);

// ---- Ring Terminal - complete geometry (single connected solid) ----
module ring_terminal() {
  color([0.8, 0.6, 0.2])  // Brass color
  union() {

    // Ring end (washer)
    difference() {
      translate([0, y_ring, 0])
        cylinder(r=outer_diameter/2, h=thickness, center=true);

      // Bolt hole (use the specified bolt hole diameter)
      translate([0, y_ring, 0])
        cylinder(r=bolt_hole_diameter/2, h=thickness + 2*overlap, center=true);

      // Inner clearance (keep as in original; if larger than bolt hole it will dominate)
      translate([0, y_ring, 0])
        cylinder(r=inner_diameter/2, h=thickness + 2*overlap, center=true);
    }

    // Flat tab body (overlaps ring by 'overlap')
    translate([0, y_tab, 0])
      cube([width, tab_len + 2*overlap, thickness], center=true);

    // Transition block (overlaps tab and crimp by 'overlap')
    translate([0, y_tran, 0])
      cube([width, transition_length + 2*overlap, thickness], center=true);

    // Crimp barrel shell (position recalculated to touch/overlap transition)
    // Axis along Y (rotate 90deg about X), centered at y_crmp.
    // Z positioned so the barrel sits on the same "top surface" as the flat tab (as in original intent),
    // and overlaps the transition slightly in Y.
    difference() {
      translate([0, y_crmp, width/2 - thickness/2])
        rotate([90, 0, 0])
          cylinder(r=width/2, h=crimp_length + 2*overlap, center=true);

      translate([0, y_crmp, width/2 - thickness/2])
        rotate([90, 0, 0])
          cylinder(r=width/2 - thickness, h=crimp_length + 4*overlap, center=true);
    }
  }
}

// ---- Ring Terminal Assembly - wire-hole end (attached to far end of tab) ----
module ring_terminal_assembly() {
  // Place this at the far end of the flat tab (end opposite the ring),
  // overlapping the tab by 'overlap' so it is not disconnected.
  y_wire = -(ring_r + tab_len - overlap);

  color([0.8, 0.6, 0.2])  // Brass color
  union() {
    difference() {
      translate([0, y_wire, 0])
        cylinder(r=width/2, h=thickness, center=true);

      translate([0, y_wire, 0])
        cylinder(r=wire_hole_diameter/2, h=thickness + 2*overlap, center=true);
    }
  }
}

// ---- Assembly Plate (kept as separate part, but unioned into one solid per requirements) ----
module assembly_plate() {
  color([0.75, 0.75, 0.77]) { // Aluminum color
    difference() {
      translate([0, 0, -(assembly_plate_thickness/2 + thickness/2 - overlap)])
        cube([assembly_plate_size, assembly_plate_size, assembly_plate_thickness], center=true);

      translate([0, 0, -(assembly_plate_thickness/2 + thickness/2 - overlap)])
        cylinder(r=bolt_hole_diameter/2, h=assembly_plate_thickness + 2*overlap, center=true);
    }
  }
}

// ---- Final Assembly (single union so nothing is disconnected) ----
module assembly() {
  union() {
    ring_terminal();
    ring_terminal_assembly();
    assembly_plate();
  }
}

assembly();