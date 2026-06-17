// Parameters
face_width_mm = 42.3; //[21.15:84.6:0.1]
front_face_thickness_mm = 3.0; //[1.5:6.0:0.1]
body_length_mm = 47.0; //[23.5:94.0:0.1]
body_width_mm = 42.3; //[21.15:84.6:0.1]
body_height_mm = 42.3; //[21.15:84.6:0.1]
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
shaft_length_mm = 20.0; //[10.0:40.0:0.1]
front_boss_diameter_mm = 22.0; //[11.0:44.0:0.1]
front_boss_thickness_mm = 2.0; //[1.0:6.0:0.1]
mounting_hole_spacing_mm = 31.0; //[15.5:62.0:0.1]
mounting_hole_diameter_mm = 3.5; //[2.0:6.0:0.1]
corner_radius_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
mount_hole_depth_extra_mm = 2.0; //[1.0:6.0:0.1]
d_plug_length_mm = 18.0; //[9.0:36.0:0.1]
d_plug_width_mm = 12.0; //[6.0:24.0:0.1]
d_plug_rad_mm = 2.0; //[1.0:5.0:0.1]
grill_width_mm = 20.0; //[10.0:40.0:0.1]
grill_height_mm = 20.0; //[10.0:40.0:0.1]
grill_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
screw_shank_diameter_mm = 3.0; //[2.0:6.0:0.1]
screw_length_mm = 10.0; //[5.0:25.0:0.1]
washer_outer_diameter_mm = 7.0; //[4.0:14.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.5:0.1]
ttrack_hole_diameter_mm = 4.0; //[2.0:8.0:0.1]
rail_hole_diameter_mm = 4.0; //[2.0:8.0:0.1]

// Modules for detailed components
module d_plug_D() {
  color("DimGray") {
    translate([0, 0, -(front_face_thickness_mm/2 - overlap_mm)])
      linear_extrude(height=front_face_thickness_mm, center=true)
        offset(r=d_plug_rad_mm)
          square([d_plug_length_mm, d_plug_width_mm], center=true);
  }
}

module grill_hole_positions() {
  color("Silver") {
    translate([0, 0, 0])
      cylinder(r=grill_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
  }
}

module screw_and_washer() {
  color("Black") {
    union() {
      translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + screw_length_mm/2 - overlap_mm])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
    }
  }
}

module ttrack_hole_positions() {
  color("Silver") {
    translate([mounting_hole_spacing_mm/2, 0, 0])
      cylinder(r=ttrack_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
  }
}

module rail_hole_positions() {
  color("Silver") {
    translate([-mounting_hole_spacing_mm/2, 0, 0])
      cylinder(r=rail_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
  }
}

// Main assembly
module assembly() {
  color("Black") {
    // Motor body
    translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);
    
    // Front face with holes
    difference() {
      translate([0, 0, 0])
        cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);
      union() {
        translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, 0])
          cylinder(r=mounting_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
        translate([-mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, 0])
          cylinder(r=mounting_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
        translate([-mounting_hole_spacing_mm/2, -mounting_hole_spacing_mm/2, 0])
          cylinder(r=mounting_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
        translate([mounting_hole_spacing_mm/2, -mounting_hole_spacing_mm/2, 0])
          cylinder(r=mounting_hole_diameter_mm/2, h=front_face_thickness_mm + mount_hole_depth_extra_mm, center=true);
      }
      grill_hole_positions();
      ttrack_hole_positions();
      rail_hole_positions();
    }
    
    // Front boss
    translate([0, 0, front_face_thickness_mm/2 + front_boss_thickness_mm/2 - overlap_mm])
      cylinder(r=front_boss_diameter_mm/2, h=front_boss_thickness_mm, center=true);
    
    // Output shaft
    translate([0, 0, front_face_thickness_mm/2 + shaft_length_mm/2 - overlap_mm])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
    
    // D Plug D
    d_plug_D();
    
    // Screw and Washer
    screw_and_washer();
  }
}

assembly();