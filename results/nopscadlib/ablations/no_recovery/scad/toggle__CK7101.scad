// Parameters
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_radius_mm = 3.43; //[1.715:6.86:0.01]
body_height_mm = 12.7; //[6.35:25.4:0.01]
tolerance_mm = 0; //[0:1:0.01]
centered = 0; //[0:1:1]
include_lever = 0; //[0:1:1]
include_threads = 0; //[0:1:1]
include_nut_washer = 0; //[0:1:1]
ref_plane_thickness_mm = 0.6; //[0.3:2:0.1]
ref_plane_size_mm = 14; //[7:28:0.5]
ref_axis_radius_mm = 0.6; //[0.3:2:0.1]
ref_axis_extra_height_mm = 6; //[2:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]
toggle_lever_radius_mm = 1.2; //[0.6:3:0.1]
toggle_lever_length_mm = 10; //[5:25:0.5]
toggle_pivot_ball_radius_mm = 1.6; //[0.8:4:0.1]

// Toggle - Detailed geometry
module toggle() {
  color("Silver") {
    // Pivot Ball
    translate([0, 0, body_height_mm - overlap_mm])
      sphere(r=toggle_pivot_ball_radius_mm);
    // Lever
    translate([0, 0, body_height_mm - overlap_mm])
      cylinder(r=toggle_lever_radius_mm, h=toggle_lever_length_mm, center=false);
  }
}

// Assembly - Combine all parts
module assembly() {
  color("DimGray") {
    // Switch Body
    translate([0, 0, 0])
      cylinder(r=body_radius_mm + tolerance_mm, h=body_height_mm, center=false);
    // Mounting Reference Axis
    translate([0, 0, 0])
      cylinder(r=ref_axis_radius_mm, h=body_height_mm + ref_axis_extra_height_mm, center=false);
    // Top Face Reference Plane
    translate([0, 0, body_height_mm - ref_plane_thickness_mm/2 - overlap_mm/2])
      cube([ref_plane_size_mm, ref_plane_size_mm, ref_plane_thickness_mm], center=true);
    // Bottom Face Reference Plane
    translate([0, 0, ref_plane_thickness_mm/2 - overlap_mm/2])
      cube([ref_plane_size_mm, ref_plane_size_mm, ref_plane_thickness_mm], center=true);
  }
  
  // Toggle Lever (optional)
  if (include_lever) {
    toggle();
  }
}

// Final assembly call
assembly();