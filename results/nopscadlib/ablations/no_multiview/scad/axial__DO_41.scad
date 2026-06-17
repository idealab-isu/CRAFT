// Parameters
axial_x = 5.21; //[2.605:10.42:0.01]
axial_y = 2.72; //[1.36:5.44:0.01]
axial_z = 0;    //[−5:5:0.01]

line_diameter = 0.5; //[0.25:1:0.05]
endpoint_marker_diameter = 1.5; //[0.75:3:0.05]
endpoint_marker_height = 1; //[0.5:2:0.05]
origin_marker_diameter = 1.5; //[0.75:3:0.05]
origin_marker_height = 1; //[0.5:2:0.05]
arrowhead_length = 1.2; //[0.6:2.4:0.05]
arrowhead_diameter = 1.6; //[0.8:3.2:0.05]

// Overlap for solid connections (1–2mm requested)
connect_overlap = 1.2; //[0.2:2:0.05]

// Calculate the length of the axial vector
axial_length = sqrt(axial_x*axial_x + axial_y*axial_y + axial_z*axial_z);

// Helper: rotate Z so a cylinder aligned with +Z points along the axial vector in XY plane
function axial_angle_deg(x,y) = atan2(y, x);

// Axial reference indicator (single connected, clearly axial/axisymmetric)
module axial_reference_indicator() {
  // Derived sizes/positions to guarantee contact
  r_line = line_diameter/2;
  r_origin = origin_marker_diameter/2;
  r_end = endpoint_marker_diameter/2;

  // Make the "shaft" run from origin to endpoint with slight extension into both end features
  shaft_len = axial_length + 2*connect_overlap;

  // Place origin marker so its top face overlaps the shaft start
  // (origin marker centered at z = origin_h/2, shaft centered at z = shaft_len/2)
  origin_z = origin_marker_height/2;

  // Place endpoint marker so its bottom face overlaps the shaft end
  end_z = axial_length - endpoint_marker_height/2;

  // Place arrowhead so its base overlaps the endpoint marker/shaft region
  // (arrowhead centered so its base is slightly inside the endpoint marker)
  arrow_z = axial_length + arrowhead_length/2 - connect_overlap;

  union() {
    // Main axial shaft (axisymmetric, single body backbone)
    rotate([0, 90, axial_angle_deg(axial_x, axial_y)])
      translate([0, 0, axial_length/2])
        cylinder(h=shaft_len, r=r_line, center=true, $fn=48);

    // Origin marker (coaxial with shaft)
    rotate([0, 90, axial_angle_deg(axial_x, axial_y)])
      translate([0, 0, origin_z])
        cylinder(h=origin_marker_height, r=r_origin, center=true, $fn=64);

    // Endpoint marker (coaxial with shaft)
    rotate([0, 90, axial_angle_deg(axial_x, axial_y)])
      translate([0, 0, end_z])
        cylinder(h=endpoint_marker_height, r=r_end, center=true, $fn=64);

    // Arrowhead (coaxial with shaft, pointing outward)
    rotate([0, 90, axial_angle_deg(axial_x, axial_y)])
      translate([0, 0, arrow_z])
        cylinder(h=arrowhead_length, r1=arrowhead_diameter/2, r2=0, center=true, $fn=64);
  }
}

// Render the model
axial_reference_indicator();