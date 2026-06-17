// Parameters
outer_diameter = 30.0; //[15.0:60.0:0.5]
inner_diameter = 8.0; //[4.0:16.0:0.5]
thickness = 1.5; //[0.75:3.0:0.25]
chamfer_size = 0.4; //[0.2:1.0:0.1]
edge_fillet_radius = 0.3; //[0.1:0.8:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// Washer with edge fillet
module washer_with_edge_fillet() {
  // Base washer body
  washer_body = cylinder(r=outer_diameter/2, h=thickness, center=true);

  // Center through hole
  center_through_hole = cylinder(r=inner_diameter/2, h=thickness + 2*overlap, center=true);

  // Edge chamfers
  edge_chamfer_top = translate([0, 0, thickness/2 - (chamfer_size + overlap)/2])
    cylinder(r1=outer_diameter/2, r2=0, h=chamfer_size + overlap, center=true);

  edge_chamfer_bottom = translate([0, 0, -thickness/2 + (chamfer_size + overlap)/2])
    cylinder(r1=outer_diameter/2, r2=0, h=chamfer_size + overlap, center=true);

  // Edge fillet sphere
  edge_fillet = sphere(r=edge_fillet_radius, center=true);

  // Construct washer with chamfers
  washer_chamfered = difference() {
    washer_body;
    center_through_hole;
    edge_chamfer_top;
    edge_chamfer_bottom;
  }

  // Apply edge fillet using minkowski
  minkowski() {
    washer_chamfered;
    edge_fillet;
  }
}

// Render the final washer
washer_with_edge_fillet();