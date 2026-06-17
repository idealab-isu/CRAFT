// Parameters
rail_L = 100; //[50:200:1]
rail_W = 20; //[10:40:0.5]
rail_H = 17.5; //[8.75:35:0.5]
top_flat_W = 12; //[6:24:0.5]
top_flat_H = 2.5; //[1.25:5:0.25]
side_undercut_depth = 2; //[1:4:0.25]
side_undercut_H = 6; //[3:12:0.5]
mount_hole_d = 5; //[3:8:0.5]
mount_hole_count = 4; //[2:8:1]
end_margin = 12; //[6:24:1]
chamfer_L = 1.5; //[0.5:4:0.25]
fillet_r = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]
marking_depth = 0.3; //[0.1:1:0.1]

// Rail Body
module rail_body() {
  cube([rail_L, rail_W, rail_H], center=true);
}

// Top Running Surfaces
module top_running_surfaces() {
  translate([0, 0, rail_H/2 + top_flat_H/2 - overlap])
    cube([rail_L, top_flat_W, top_flat_H], center=true);
}

// Side Undercuts
module side_undercut_left() {
  translate([0, -(rail_W/2 - side_undercut_depth/2 + overlap), -(rail_H/2 - side_undercut_H/2)])
    cube([rail_L + 2*overlap, side_undercut_depth, side_undercut_H], center=true);
}

module side_undercut_right() {
  translate([0, (rail_W/2 - side_undercut_depth/2 + overlap), -(rail_H/2 - side_undercut_H/2)])
    cube([rail_L + 2*overlap, side_undercut_depth, side_undercut_H], center=true);
}

// Mounting Holes
module mount_hole(position) {
  translate(position)
    rotate([90, 0, 0])
      cylinder(h=rail_H + top_flat_H + 2*overlap, r=mount_hole_d/2, center=true);
}

// End Chamfers
module end_chamfer_pos() {
  translate([rail_L/2 - chamfer_L/2 + overlap, 0, top_flat_H/2 - overlap])
    rotate([0, 45, 0])
      cube([chamfer_L, rail_W + 2*overlap, rail_H + top_flat_H + 2*overlap], center=true);
}

module end_chamfer_neg() {
  translate([-rail_L/2 + chamfer_L/2 - overlap, 0, top_flat_H/2 - overlap])
    rotate([0, -45, 0])
      cube([chamfer_L, rail_W + 2*overlap, rail_H + top_flat_H + 2*overlap], center=true);
}

// Fillet Sphere
module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Engraved Markings
module engraved_markings() {
  translate([0, 0, rail_H/2 + top_flat_H - marking_depth/2])
    cube([rail_L/5, top_flat_W/2, marking_depth], center=true);
}

// Final Rail Assembly
module rail_final() {
  difference() {
    minkowski() {
      difference() {
        difference() {
          difference() {
            union() {
              rail_body();
              top_running_surfaces();
            }
            side_undercut_left();
            side_undercut_right();
          }
          for (i = [0:mount_hole_count-1]) {
            mount_hole([-rail_L/2 + end_margin + i*(rail_L - 2*end_margin)/(mount_hole_count-1), 0, top_flat_H/2 - overlap]);
          }
        }
        end_chamfer_pos();
        end_chamfer_neg();
      }
      fillet_sphere();
    }
    engraved_markings();
  }
}

// Render the final rail
color("DimGray") rail_final();