// Parameters
bbox_x = 46.19; //[23.095:92.38:0.01]
bbox_y = 40; //[20:80:0.01]
bbox_z = 29.88; //[14.94:59.76:0.01]
hex_flat_to_flat = 40; //[20:80:0.01]
plate_thickness = 6; //[3:12:0.1]
dome_radius = 23.88; //[11.94:47.76:0.01]
hole_diameter = 4; //[1:10:0.1]
blend_height = 1; //[0.5:3:0.1]
blend_radius = 2; //[0.5:6:0.1]
edge_chamfer = 0.8; //[0.2:2:0.1]
edge_fillet = 0.6; //[0.2:2:0.1]
top_rounding = 0.8; //[0.2:3:0.1]
overlap = 1; //[0.5:2:0.1]
eps = 0.2; //[0.05:0.5:0.01]

// Hexagonal Plate
module hex_plate_prism() {
  linear_extrude(height=plate_thickness, center=true)
    polygon(points=[
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * 1, (hex_flat_to_flat/2) * (2/sqrt(3)) * 0],
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * 0.5, (hex_flat_to_flat/2) * (2/sqrt(3)) * (sqrt(3)/2)],
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * -0.5, (hex_flat_to_flat/2) * (2/sqrt(3)) * (sqrt(3)/2)],
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * -1, (hex_flat_to_flat/2) * (2/sqrt(3)) * 0],
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * -0.5, (hex_flat_to_flat/2) * (2/sqrt(3)) * (-sqrt(3)/2)],
      [(hex_flat_to_flat/2) * (2/sqrt(3)) * 0.5, (hex_flat_to_flat/2) * (2/sqrt(3)) * (-sqrt(3)/2)]
    ]);
}

// Hemispherical Dome
module hemispherical_dome() {
  difference() {
    translate([0, 0, (plate_thickness/2) + dome_radius - overlap])
      sphere(r=dome_radius, center=true);
    translate([0, 0, (plate_thickness/2) - (dome_radius/2) - eps])
      cube([2*dome_radius + 2*eps, 2*dome_radius + 2*eps, dome_radius + 2*eps], center=true);
  }
}

// Dome to Plate Blend Shoulder
module dome_to_plate_blend_shoulder() {
  translate([0, 0, (plate_thickness/2) + (blend_height/2) - overlap])
    cylinder(r=dome_radius + blend_radius, h=blend_height, center=true);
}

// Central Through Hole
module central_through_hole() {
  translate([0, 0, (plate_thickness/2) + (dome_radius/2) - overlap/2])
    cylinder(r=hole_diameter/2, h=plate_thickness + dome_radius + 2*eps, center=true);
}

// Edge Chamfer Tool
module edge_chamfer_tool_sphere() {
  sphere(r=edge_chamfer, center=true);
}

// Edge Fillet Tool
module edge_fillet_tool_sphere() {
  sphere(r=edge_fillet, center=true);
}

// Top Surface Rounding Tool
module top_surface_rounding_tool_sphere() {
  sphere(r=top_rounding, center=true);
}

// Engraving or Marking Placeholder
module engraving_or_marking() {
  cube([eps, eps, eps], center=true);
}

// Final Model
module final_model() {
  difference() {
    union() {
      minkowski() {
        minkowski() {
          minkowski() {
            union() {
              union() {
                hex_plate_prism();
                dome_to_plate_blend_shoulder();
              }
              hemispherical_dome();
            }
            edge_chamfer_tool_sphere();
          }
          edge_fillet_tool_sphere();
        }
        top_surface_rounding_tool_sphere();
      }
      engraving_or_marking();
    }
    central_through_hole();
  }
}

// Render the final model
color("Silver") final_model();