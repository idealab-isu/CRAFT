// Parameters
bbox_xy = 23.46; //[11.73:46.92:0.01]
thickness = 7; //[3.5:14:0.1]
outer_diameter_max = 23.46; //[11.73:46.92:0.01]
bore_diameter = 10; //[5:20:0.1]
root_diameter = 20; //[12:23.46:0.1]
tooth_count = 12; //[6:36:2]
tooth_radial_height = 1.73; //[0.5:3.46:0.01]
tooth_tangential_width = 3; //[1.5:6:0.1]
overlap = 0.8; //[0.2:2:0.1]
chamfer_size = 0.6; //[0:1.5:0.1]
fillet_radius = 0.6; //[0:1.5:0.1]
tooth_tip_chamfer = 0.4; //[0:1.2:0.1]

// Helper function to create a tooth
module tooth() {
  translate([min(root_diameter/2, outer_diameter_max/2 - tooth_radial_height) + (tooth_radial_height + overlap)/2 - overlap, 0, 0])
    cube([tooth_radial_height + overlap, tooth_tangential_width, thickness], center=true);
}

// Main module
module final_ring_with_bore() {
  difference() {
    union() {
      // Annular main body
      cylinder(h=thickness, r=min(root_diameter/2, outer_diameter_max/2 - tooth_radial_height), center=true);
      
      // Outer tooth lug array
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i * 360/tooth_count])
          tooth();
      }
    }
    
    // Central through bore
    cylinder(h=thickness + 2*overlap, r=bore_diameter/2, center=true);
  }
}

// Render the final output
color("Silver") final_ring_with_bore();