$fn = 96;

// Parameters
outer_diameter = 12; //[6:24:0.5]
inner_hole_diameter = 5; //[2.5:10:0.5]
thickness = 1; //[0.5:2:0.1]
overall_length = 25; //[12.5:50:0.5]
width = 6; //[3:12:0.5]
crimp_barrel_length = 10; //[5:20:0.5]
transition_length = 1; //[0.5:3:0.1]
hole_clearance = 0.2; //[0:0.6:0.05]
overlap = 0.8; //[0.5:2:0.1]
barrel_wall = 0.6; //[0.3:1.2:0.05]
wire_entry_diameter = 3; //[1.5:6:0.5]
slot_width = 0.6; //[0.3:1.5:0.1]

// Derived / safety
ring_r = outer_diameter/2;
hole_r = (inner_hole_diameter + hole_clearance)/2;
tongue_len = max(0.1, overall_length - outer_diameter/2);
barrel_outer_r = width/2;
barrel_inner_r = max(0.1, min(wire_entry_diameter/2, barrel_outer_r - barrel_wall));
slot_w = min(slot_width, 2*barrel_inner_r - 0.05);

// Placement along Y (ring at y=0, tongue extends to -Y, barrel continues further -Y)
y_ring_center = 0;
y_ring_bottom = y_ring_center - ring_r;

y_transition_center = y_ring_bottom - transition_length/2 + overlap;
y_transition_bottom = y_transition_center - transition_length/2;

y_tongue_center = y_transition_bottom - tongue_len/2 + overlap;
y_tongue_bottom = y_tongue_center - tongue_len/2;

y_barrel_center = y_tongue_bottom - crimp_barrel_length/2 + overlap;

// Ring terminal: one connected solid with clear ring hole and hollow barrel opening
module ring_terminal_connected() {
  color("Silver")
  difference() {
    // SOLID union (outer shape)
    union() {
      // Ring (disk)
      translate([0, y_ring_center, 0])
        cylinder(r=ring_r, h=thickness, center=true);

      // Transition block (small neck)
      translate([0, y_transition_center, 0])
        cube([width, transition_length, thickness], center=true);

      // Tongue (flat strap)
      translate([0, y_tongue_center, 0])
        cube([width, tongue_len, thickness], center=true);

      // Barrel outer (tube) aligned along Y
      translate([0, y_barrel_center, 0])
        rotate([90, 0, 0])
          cylinder(r=barrel_outer_r, h=crimp_barrel_length, center=true);

      // Small fillet-like bridge between tongue and barrel for robust connectivity
      hull() {
        translate([0, y_tongue_bottom + overlap, 0])
          cube([width, overlap*2, thickness], center=true);
        translate([0, y_barrel_center + crimp_barrel_length/2 - overlap, 0])
          rotate([90, 0, 0])
            cylinder(r=barrel_outer_r, h=overlap*2, center=true);
      }
    }

    // SUBTRACT: ring hole
    translate([0, y_ring_center, 0])
      cylinder(r=hole_r, h=thickness + 2*overlap, center=true);

    // SUBTRACT: barrel inner bore (wire entry)
    translate([0, y_barrel_center, 0])
      rotate([90, 0, 0])
        cylinder(r=barrel_inner_r, h=crimp_barrel_length + 2*overlap, center=true);

    // SUBTRACT: crimp slot (longitudinal opening) through barrel wall
    translate([0, y_barrel_center, 0])
      rotate([90, 0, 0])
        cube([slot_w, crimp_barrel_length + 2*overlap, 2*barrel_outer_r + 2*overlap], center=true);
  }
}

ring_terminal_connected();