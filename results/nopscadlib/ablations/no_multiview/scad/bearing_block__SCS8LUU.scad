// Parameters
shaft_diameter = 6.0; //[3.0:12.0:0.1]
block_width = 34.0; //[17.0:68.0:0.5]
block_length = 58.0; //[29.0:116.0:0.5]
block_height = 24.0; //[12.0:48.0:0.5]
bearing_outer_diameter = 12.0; //[8.0:24.0:0.1]
bearing_length = 20.0; //[10.0:40.0:0.5]
bore_diameter = 6.4; //[6.1:8.0:0.05]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_pattern_x = 24.0; //[12.0:48.0:0.5]
mount_hole_pattern_y = 40.0; //[20.0:80.0:0.5]
counterbore_diameter = 9.0; //[7.0:16.0:0.1]
counterbore_depth = 4.0; //[2.0:10.0:0.1]
chamfer_size = 1.0; //[0.5:3.0:0.1]
bore_lead_in_chamfer = 1.0; //[0.5:3.0:0.1]
eps = 0.6; //[0.2:2.0:0.1]

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  color("Silver") {
    difference() {
      // Block Body
      cube([block_width, block_length, block_height], center=true);
      
      // Shaft Bore
      rotate([90, 0, 0])
        translate([0, 0, 0])
        cylinder(h=block_length + 2*eps, r=bore_diameter/2, center=true);
      
      // Bearing Seat
      rotate([90, 0, 0])
        translate([0, 0, 0])
        cylinder(h=bearing_length + 2*eps, r=bearing_outer_diameter/2, center=true);
      
      // Mounting Holes
      union() {
        translate([mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
          cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
        translate([-mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
          cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
        translate([mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
          cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
        translate([-mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
          cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      }
      
      // Counterbores
      union() {
        translate([mount_hole_pattern_x/2, mount_hole_pattern_y/2, -block_height/2 + counterbore_depth/2])
          cylinder(h=counterbore_depth + eps, r=counterbore_diameter/2, center=true);
        translate([-mount_hole_pattern_x/2, mount_hole_pattern_y/2, -block_height/2 + counterbore_depth/2])
          cylinder(h=counterbore_depth + eps, r=counterbore_diameter/2, center=true);
        translate([mount_hole_pattern_x/2, -mount_hole_pattern_y/2, -block_height/2 + counterbore_depth/2])
          cylinder(h=counterbore_depth + eps, r=counterbore_diameter/2, center=true);
        translate([-mount_hole_pattern_x/2, -mount_hole_pattern_y/2, -block_height/2 + counterbore_depth/2])
          cylinder(h=counterbore_depth + eps, r=counterbore_diameter/2, center=true);
      }
      
      // Bore Lead-in Chamfers
      union() {
        rotate([90, 0, 0])
          translate([0, block_length/2 - bore_lead_in_chamfer/2 + eps/2, 0])
          cylinder(h=bore_lead_in_chamfer, r1=bearing_outer_diameter/2 + bore_lead_in_chamfer, r2=bore_diameter/2, center=true);
        rotate([-90, 0, 0])
          translate([0, -block_length/2 + bore_lead_in_chamfer/2 - eps/2, 0])
          cylinder(h=bore_lead_in_chamfer, r1=bearing_outer_diameter/2 + bore_lead_in_chamfer, r2=bore_diameter/2, center=true);
      }
      
      // Chamfers
      union() {
        translate([block_width/2 - chamfer_size, block_length/2 - chamfer_size, 0])
          rotate([0, 0, 45])
          cube([chamfer_size*2, chamfer_size*2, block_height + 2*eps], center=true);
        translate([-block_width/2 + chamfer_size, block_length/2 - chamfer_size, 0])
          rotate([0, 0, 45])
          cube([chamfer_size*2, chamfer_size*2, block_height + 2*eps], center=true);
        translate([block_width/2 - chamfer_size, -block_length/2 + chamfer_size, 0])
          rotate([0, 0, 45])
          cube([chamfer_size*2, chamfer_size*2, block_height + 2*eps], center=true);
        translate([-block_width/2 + chamfer_size, -block_length/2 + chamfer_size, 0])
          rotate([0, 0, 45])
          cube([chamfer_size*2, chamfer_size*2, block_height + 2*eps], center=true);
      }
    }
  }
}

// SBR Bearing Block Hole Positions
module sbr_bearing_block_hole_positions() {
  color("DimGray") {
    union() {
      translate([mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([-mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([-mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("Silver") {
    cube([block_width, block_length, block_height], center=true);
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("DimGray") {
    union() {
      translate([mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([-mount_hole_pattern_x/2, mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
      translate([-mount_hole_pattern_x/2, -mount_hole_pattern_y/2, 0])
        cylinder(h=block_height + 2*eps, r=mount_hole_diameter/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
  translate([0, 0, block_height/2 + 5]) sbr_bearing_block_hole_positions();
  translate([0, 0, block_height/2 + 10]) scs_bearing_block();
  translate([0, 0, block_height/2 + 15]) scs_bearing_block_hole_positions();
}

assembly();