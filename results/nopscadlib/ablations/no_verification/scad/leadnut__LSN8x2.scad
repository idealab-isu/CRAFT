// Parameters
width_mm = 8.0; //[4.0:16.0:0.1]
height_mm = 10.2; //[5.1:20.4:0.1]
length_mm = 15.0; //[7.5:30.0:0.1]
tolerance_mm = 0.2; //[0.0:0.6:0.05]
nut_pocket_depth_mm = 8.0; //[4.0:14.0:0.1]
nut_pocket_width_mm = 6.0; //[3.0:12.0:0.1]
nut_pocket_height_mm = 6.0; //[3.0:12.0:0.1]
bore_diameter_mm = 3.0; //[1.0:8.0:0.1]
mount_hole_diameter_mm = 2.0; //[1.0:5.0:0.1]
mount_hole_spacing_x_mm = 4.0; //[2.0:10.0:0.1]
mount_hole_spacing_z_mm = 8.0; //[4.0:20.0:0.1]
mount_hole_edge_margin_mm = 1.0; //[0.5:3.0:0.1]
leadscrew_diameter_mm = 3.0; //[1.0:8.0:0.1]
leadscrew_length_mm = 25.0; //[15.0:60.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Leadscrew - detailed geometry
module leadscrew() {
  color("Silver") {
    // Leadscrew body
    cylinder(r=leadscrew_diameter_mm/2, h=leadscrew_length_mm, center=true, $fn=32);
    // Thread pattern (simplified for visual effect)
    for (i = [0:leadscrew_length_mm/2]) {
      translate([0, 0, i*2]) rotate([0, 0, i*10])
        cylinder(r=leadscrew_diameter_mm/2 + 0.5, h=1, center=true, $fn=32);
    }
  }
}

// Main block with placeholders
module housing_with_placeholders() {
  difference() {
    // Main block body
    color([0.85, 0.85, 0.8]) cube([width_mm, height_mm, length_mm], center=true);
    
    // Leadscrew nut cavity placeholder
    translate([0, 0, 0])
      cube([nut_pocket_width_mm + 2*tolerance_mm, nut_pocket_height_mm + 2*tolerance_mm, nut_pocket_depth_mm], center=true);
    
    // Leadscrew through bore placeholder
    rotate([90, 0, 0])
      translate([0, 0, 0])
      cylinder(r=(bore_diameter_mm + 2*tolerance_mm)/2, h=length_mm + 2*overlap_mm, center=true, $fn=32);
    
    // Mounting holes placeholders
    union() {
      translate([min(width_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_x_mm/2), 0, min(length_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_z_mm/2)])
        cylinder(r=(mount_hole_diameter_mm + 2*tolerance_mm)/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([-min(width_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_x_mm/2), 0, min(length_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_z_mm/2)])
        cylinder(r=(mount_hole_diameter_mm + 2*tolerance_mm)/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([min(width_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_x_mm/2), 0, -min(length_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_z_mm/2)])
        cylinder(r=(mount_hole_diameter_mm + 2*tolerance_mm)/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([-min(width_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_x_mm/2), 0, -min(length_mm/2 - mount_hole_edge_margin_mm, mount_hole_spacing_z_mm/2)])
        cylinder(r=(mount_hole_diameter_mm + 2*tolerance_mm)/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  housing_with_placeholders();
  translate([0, 0, leadscrew_length_mm/2 + length_mm/2])
    leadscrew();
}

assembly();