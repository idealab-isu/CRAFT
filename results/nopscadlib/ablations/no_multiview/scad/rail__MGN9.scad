// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width = 9.0; //[4.5:18.0:0.5]
rail_height = 6.0; //[3.0:12.0:0.5]
hole_diameter = 3.0; //[1.5:6.0:0.25]
hole_count = 4; //[2:8:1]
end_margin = 12.0; //[6.0:24.0:1]
chamfer_size = 0.8; //[0.3:2.0:0.1]
fillet_radius = 0.6; //[0.2:1.5:0.1]
fillet_trim = 1.2; //[0.6:3.0:0.1]
engrave_depth = 0.2; //[0.1:0.6:0.05]
engrave_groove_width = 0.6; //[0.3:1.5:0.1]
engrave_groove_length = 18.0; //[8.0:40.0:1]
engrave_offset_from_top = 1.0; //[0.5:2.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Rail Body
module rail_body() {
  translate([0, 0, 0])
    cube([rail_width, rail_length, rail_height], center=true);
}

// Mounting Holes
module mounting_holes() {
  union() {
    translate([0, -rail_length/2 + end_margin, 0])
      cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
    translate([0, -rail_length/2 + end_margin + (rail_length - 2*end_margin)/3, 0])
      cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
    translate([0, -rail_length/2 + end_margin + 2*(rail_length - 2*end_margin)/3, 0])
      cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
    translate([0, rail_length/2 - end_margin, 0])
      cylinder(h=rail_height + 2*overlap, r=hole_diameter/2, center=true);
  }
}

// End Chamfers
module end_chamfers() {
  union() {
    translate([0, rail_length/2 - chamfer_size/2, 0])
      rotate([0, 45, 0])
        cube([rail_width + 2*overlap, chamfer_size, rail_height + 2*overlap], center=true);
    translate([0, -rail_length/2 + chamfer_size/2, 0])
      rotate([0, -45, 0])
        cube([rail_width + 2*overlap, chamfer_size, rail_height + 2*overlap], center=true);
  }
}

// Engraved Markings
module engraved_markings() {
  union() {
    translate([-rail_width/4, 0, rail_height/2 - engrave_offset_from_top - (engrave_depth + overlap)/2])
      cube([engrave_groove_width, engrave_groove_length, engrave_depth + overlap], center=true);
    translate([rail_width/4, 0, rail_height/2 - engrave_offset_from_top - (engrave_depth + overlap)/2])
      cube([engrave_groove_width, engrave_groove_length, engrave_depth + overlap], center=true);
  }
}

// Edge Fillets
module edge_fillets() {
  intersection() {
    minkowski() {
      difference() {
        difference() {
          difference() {
            rail_body();
            mounting_holes();
          }
          end_chamfers();
        }
        engraved_markings();
      }
      sphere(r=fillet_radius, center=true);
    }
    translate([0, 0, 0])
      cube([rail_width + 4*fillet_radius + 2*overlap, rail_length, rail_height + 4*fillet_radius + 2*overlap], center=true);
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
edge_fillets();