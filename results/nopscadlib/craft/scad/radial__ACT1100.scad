// Parameters
outer_radius = 20.4; //[10.2:40.8:0.1]
inner_radius = 10.8; //[5.4:21.6:0.1]
height = 5.3; //[2.65:10.6:0.1]
count_or_scale = 1; //[1:4:1]
overlap = 0.8; //[0.5:2:0.1]
chamfer_depth = 0.8; //[0.4:1.6:0.1]
chamfer_height = 0.6; //[0.3:1.2:0.1]
base_pattern_count = 12; //[6:24:1]
groove_width = 2.2; //[1.1:4.4:0.1]
groove_depth = 1.0; //[0.5:2:0.1]

// Main radial body
module radial_main_body() {
  color("Silver")
  cylinder(r=outer_radius, h=height, center=true);
}

// Inner bore
module inner_bore() {
  color("Black")
  cylinder(r=inner_radius, h=height + 2*overlap, center=true);
}

// Chamfer top outer
module fillet_chamfer_top_outer() {
  color("DimGray")
  translate([0, 0, height/2 - (chamfer_height + overlap)/2])
    cylinder(r1=outer_radius + overlap, r2=outer_radius + overlap - chamfer_depth, h=chamfer_height + overlap, center=true);
}

// Chamfer bottom outer
module fillet_chamfer_bottom_outer() {
  color("DimGray")
  translate([0, 0, -height/2 + (chamfer_height + overlap)/2])
    rotate([180, 0, 0])
    cylinder(r1=outer_radius + overlap, r2=outer_radius + overlap - chamfer_depth, h=chamfer_height + overlap, center=true);
}

// Groove cutter base
module groove_cutter_base() {
  color("Black")
  translate([outer_radius - groove_depth/2, 0, 0])
    cube([groove_depth + 2*overlap, groove_width, height + 2*overlap], center=true);
}

// Assemble the radial body with chamfers and grooves
module final_model() {
  difference() {
    // Main body minus inner bore
    difference() {
      radial_main_body();
      inner_bore();
    }
    // Subtract chamfers
    fillet_chamfer_top_outer();
    fillet_chamfer_bottom_outer();
    // Subtract groove pattern
    union() {
      for (i = [0:base_pattern_count*count_or_scale-1]) {
        rotate([0, 0, i*(360/(base_pattern_count*count_or_scale))])
          groove_cutter_base();
      }
    }
  }
}

// Render the final model
final_model();