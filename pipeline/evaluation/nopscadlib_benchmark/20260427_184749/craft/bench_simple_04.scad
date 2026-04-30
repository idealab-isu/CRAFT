// Parameters
total_length = 40; //[20:80:1]
plate_thickness = 3; //[1.5:6:0.5]
hole_pitch = 32; //[16:64:0.5]
mount_hole_diameter = 4.3; //[2.5:8:0.1]
aperture_diameter = 38; //[20:78:0.5]
corner_radius = 2; //[0:8:0.5]
fan_depth = 10; //[5:25:1]
fan_frame_margin = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module mount_plate() {
  cube([total_length, total_length, plate_thickness], center=true);
}

module central_airflow_aperture() {
  cylinder(r=aperture_diameter/2, h=plate_thickness + 2*overlap, center=true);
}

module mount_hole_cyl() {
  cylinder(r=mount_hole_diameter/2, h=plate_thickness + 2*overlap, center=true);
}

module corner_cutout() {
  cylinder(r=corner_radius, h=plate_thickness + 2*overlap, center=true);
}

module fan() {
  cube([total_length - 2*fan_frame_margin, total_length - 2*fan_frame_margin, fan_depth], center=true);
}

// Operations
module four_corner_mounting_holes() {
  union() {
    translate([hole_pitch/2, hole_pitch/2, 0]) mount_hole_cyl();
    translate([-hole_pitch/2, hole_pitch/2, 0]) mount_hole_cyl();
    translate([-hole_pitch/2, -hole_pitch/2, 0]) mount_hole_cyl();
    translate([hole_pitch/2, -hole_pitch/2, 0]) mount_hole_cyl();
  }
}

module corner() {
  union() {
    translate([total_length/2 - corner_radius, total_length/2 - corner_radius, 0]) corner_cutout();
    translate([-(total_length/2 - corner_radius), total_length/2 - corner_radius, 0]) corner_cutout();
    translate([-(total_length/2 - corner_radius), -(total_length/2 - corner_radius), 0]) corner_cutout();
    translate([total_length/2 - corner_radius, -(total_length/2 - corner_radius), 0]) corner_cutout();
  }
}

module plate_with_holes() {
  difference() {
    mount_plate();
    central_airflow_aperture();
    four_corner_mounting_holes();
    corner();
  }
}

module final_union() {
  union() {
    plate_with_holes();
    translate([0, 0, plate_thickness/2 + fan_depth/2 - overlap]) fan();
  }
}

// Final Output
final_union();