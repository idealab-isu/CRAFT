// Parameters
radial_x = 2; //[1:4:0.1]
radial_y = 0; //[-2:2:0.1]
radial_z = 6; //[3:12:0.1]
origin_radius = 1.5; //[0.75:3:0.1]
shaft_radius = 0.8; //[0.4:1.6:0.1]
head_radius = 1.4; //[0.7:2.8:0.1]
head_length = 3; //[1.5:6:0.1]
overlap = 0.8; //[0.5:2:0.1]

// Calculate derived values
vector_length = sqrt(radial_x*radial_x + radial_y*radial_y + radial_z*radial_z);
shaft_length = vector_length - head_length + overlap;
shaft_translate_factor = shaft_length / (2 * vector_length);
head_translate_factor = 1 - (head_length / (2 * vector_length));

// Rotation angles
shaft_rot_y_angle = acos(radial_z / vector_length);
shaft_rot_z_angle = atan2(radial_y, radial_x);

// Geometry
module radial_vector_origin_sphere() {
  color("Silver")
  sphere(r=origin_radius, center=true);
}

module radial_vector_shaft_cyl() {
  color("DimGray")
  cylinder(h=shaft_length, r=shaft_radius, center=true);
}

module radial_vector_head_cone() {
  color("DimGray")
  cylinder(h=head_length, r1=head_radius, r2=0, center=true);
}

// Operations
module radial_vector_shaft() {
  translate([
    radial_x * shaft_translate_factor,
    radial_y * shaft_translate_factor,
    radial_z * shaft_translate_factor
  ])
  rotate([0, shaft_rot_y_angle, shaft_rot_z_angle])
  radial_vector_shaft_cyl();
}

module radial_vector_head() {
  translate([
    radial_x * head_translate_factor,
    radial_y * head_translate_factor,
    radial_z * head_translate_factor
  ])
  rotate([0, shaft_rot_y_angle, shaft_rot_z_angle])
  radial_vector_head_cone();
}

// Final assembly
module radial_vector_definition() {
  union() {
    radial_vector_origin_sphere();
    radial_vector_shaft();
    radial_vector_head();
  }
}

// Render the final output
radial_vector_definition();