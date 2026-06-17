// Parameters
outer_radius = 17.4; //[8.7:34.8:0.1]
inner_radius = 11.4; //[5.7:22.8:0.1]
height = 9.0; //[4.5:18.0:0.1]
wall_thickness = 0.5; //[0.25:1.0:0.05]
overlap = 1.0; //[0.5:2.0:0.1]

// Main body of the bushing
module radial_main_body() {
  color("Silver")
  cylinder(r=outer_radius, h=height, center=true);
}

// Inner bore subtraction
module inner_bore() {
  cylinder(r=inner_radius, h=height + 2*overlap, center=true);
}

// Edge chamfer cuts
module edge_chamfer_top_cut() {
  translate([0, 0, height/2 - (wall_thickness + overlap)/2])
    cylinder(r1=outer_radius, r2=0, h=wall_thickness + overlap, center=true);
}

module edge_chamfer_bottom_cut() {
  translate([0, 0, -height/2 + (wall_thickness + overlap)/2])
    rotate([180, 0, 0])
    cylinder(r1=outer_radius, r2=0, h=wall_thickness + overlap, center=true);
}

// Union of edge chamfers
module edge_chamfers_fillets() {
  union() {
    edge_chamfer_top_cut();
    edge_chamfer_bottom_cut();
  }
}

// Final model with all operations applied
module final_model() {
  difference() {
    radial_main_body();
    inner_bore();
    edge_chamfers_fillets();
  }
}

// Render the final model
final_model();