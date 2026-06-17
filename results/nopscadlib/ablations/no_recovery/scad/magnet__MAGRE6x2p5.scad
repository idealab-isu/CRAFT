// Parameters
outer_diameter = 10; //[5:20:0.1]
inner_diameter = 4; //[2:8:0.1]
thickness = 2; //[1:6:0.1]
edge_radius = 0.2; //[0:1:0.05]
chamfer = 0.3; //[0:1:0.05]
hub_outer_diameter = 6; //[3:12:0.1]
hub_length = 3; //[1.5:8:0.1]
press_fit_clearance = -0.05; //[-0.2:0.2:0.01]
adhesive_gap = 0.1; //[0:0.5:0.01]
overlap = 0.8; //[0.2:2:0.1]
bore_extra_height = 2; //[1:6:0.5]

// Ring Magnet - complete geometry
module ring_magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for magnet
    difference() {
      // Outer ring
      translate([0, 0, 0])
        cylinder(r=outer_diameter/2, h=thickness, center=true, $fn=64);
      
      // Center bore
      translate([0, 0, 0])
        cylinder(r=(inner_diameter + press_fit_clearance)/2, h=thickness + hub_length + bore_extra_height, center=true, $fn=64);
      
      // Outer chamfer top
      translate([0, 0, thickness/2 - chamfer/2])
        cylinder(r1=outer_diameter/2, r2=outer_diameter/2 - chamfer, h=chamfer, center=true, $fn=64);
      
      // Outer chamfer bottom
      translate([0, 0, -thickness/2 + chamfer/2])
        cylinder(r1=outer_diameter/2 - chamfer, r2=outer_diameter/2, h=chamfer, center=true, $fn=64);
    }
  }
}

// Mounting Hub - complete geometry
module mounting_hub() {
  color([0.85, 0.85, 0.8]) { // Off-white for hub
    difference() {
      // Outer hub
      translate([0, 0, thickness/2 + hub_length/2 - overlap])
        cylinder(r=hub_outer_diameter/2, h=hub_length, center=true, $fn=64);
      
      // Hub magnet seat
      translate([0, 0, thickness/2 + hub_length/2 - overlap])
        cylinder(r=outer_diameter/2 + adhesive_gap, h=hub_length + bore_extra_height, center=true, $fn=64);
    }
  }
}

// Magnet Assembly
module magnet() {
  union() {
    ring_magnet();
    mounting_hub();
  }
}

// Final Assembly
module assembly() {
  magnet();
}

assembly();