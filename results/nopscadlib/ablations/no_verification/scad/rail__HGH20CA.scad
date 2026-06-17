// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 20.0; //[10.0:40.0:0.5]
rail_H = 17.5; //[8.75:35.0:0.5]
hole_d = 4.2; //[2.0:8.0:0.1]
hole_pitch = 25.0; //[10.0:60.0:1]
hole_edge_offset = 5.0; //[2.5:12.0:0.5]
hole_count = 4; //[2:8:1]
hole_csk_d = 8.0; //[5.0:14.0:0.5]
hole_csk_angle = 90.0; //[60.0:120.0:1]
overlap = 1.0; //[0.5:2.0:0.1]
edge_chamfer = 1.0; //[0.5:2.5:0.1]
fillet_r = 1.0; //[0.5:3.0:0.1]
groove_r = 2.0; //[1.0:4.0:0.1]
groove_depth = 1.2; //[0.5:3.0:0.1]
groove_z = 4.5; //[2.0:8.0:0.1]
csk_depth = 3.0; //[1.0:6.0:0.1]
end_mark_depth = 0.6; //[0.2:1.5:0.1]
end_mark_W = 6.0; //[3.0:12.0:0.5]
end_mark_H = 3.0; //[1.5:8.0:0.5]

// Rail Body
module rail_body() {
  color("Silver")
  cube([rail_L, rail_W, rail_H], center=true);
}

// Mounting Holes
module mounting_holes_pattern() {
  union() {
    for (i = [0:hole_count-1]) {
      translate([-rail_L/2 + hole_edge_offset + i*hole_pitch, 0, 0])
      rotate([90, 0, 0])
      cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);
      
      translate([-rail_L/2 + hole_edge_offset + i*hole_pitch, 0, rail_H/2 - (csk_depth + overlap)/2])
      rotate([90, 0, 0])
      cylinder(h=csk_depth + overlap, r=hole_csk_d/2, center=true);
    }
  }
}

// Edge Chamfers
module edge_chamfers() {
  union() {
    translate([0, rail_W/2 - edge_chamfer/2, rail_H/2 - edge_chamfer/2])
    rotate([45, 0, 0])
    cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
    
    translate([0, -rail_W/2 + edge_chamfer/2, rail_H/2 - edge_chamfer/2])
    rotate([-45, 0, 0])
    cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
    
    translate([0, rail_W/2 - edge_chamfer/2, -rail_H/2 + edge_chamfer/2])
    rotate([-45, 0, 0])
    cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
    
    translate([0, -rail_W/2 + edge_chamfer/2, -rail_H/2 + edge_chamfer/2])
    rotate([45, 0, 0])
    cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
  }
}

// Corner Fillets
module corner_fillets() {
  union() {
    translate([0, rail_W/2 - fillet_r, rail_H/2 - fillet_r])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=fillet_r, center=true);
    
    translate([0, -rail_W/2 + fillet_r, rail_H/2 - fillet_r])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=fillet_r, center=true);
    
    translate([0, rail_W/2 - fillet_r, -rail_H/2 + fillet_r])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=fillet_r, center=true);
    
    translate([0, -rail_W/2 + fillet_r, -rail_H/2 + fillet_r])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=fillet_r, center=true);
  }
}

// Raceway Grooves
module raceway_grooves() {
  union() {
    translate([0, rail_W/2 - groove_depth, -rail_H/2 + groove_z])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=groove_r, center=true);
    
    translate([0, -rail_W/2 + groove_depth, -rail_H/2 + groove_z])
    rotate([0, 90, 0])
    cylinder(h=rail_L + 2*overlap, r=groove_r, center=true);
  }
}

// End Markings
module end_markings() {
  union() {
    translate([-rail_L/2 + (end_mark_depth + overlap)/2, 0, rail_H/2 - end_mark_H/2 - edge_chamfer])
    cube([end_mark_depth + overlap, end_mark_W, end_mark_H], center=true);
    
    translate([rail_L/2 - (end_mark_depth + overlap)/2, 0, rail_H/2 - end_mark_H/2 - edge_chamfer])
    cube([end_mark_depth + overlap, end_mark_W, end_mark_H], center=true);
  }
}

// Final Rail with Features
difference() {
  rail_body();
  mounting_holes_pattern();
  edge_chamfers();
  corner_fillets();
  raceway_grooves();
  end_markings();
}