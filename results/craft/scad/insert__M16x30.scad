// Parameters
insert_outer_diameter_mm = 30; //[15:60:0.5]
insert_length_mm = 25; //[12.5:50:0.5]
screw_nominal_diameter_mm = 16; //[8:32:0.5]
internal_thread_clearance_mm = 0.6; //[0.2:1.5:0.1]
outer_rib_count = 24; //[8:60:1]
outer_rib_radial_height_mm = 1.2; //[0.4:3:0.1]
outer_rib_tangential_width_mm = 2.2; //[0.8:5:0.1]
outer_rib_length_mm = 21; //[10:45:0.5]
entry_chamfer_angle_deg = 45; //[15:75:1]
tip_chamfer_angle_deg = 30; //[15:75:1]
entry_chamfer_radial_mm = 1.5; //[0.5:4:0.1]
tip_chamfer_radial_mm = 1.2; //[0.5:4:0.1]
bore_entry_chamfer_radial_mm = 1; //[0.3:3:0.1]
bore_tip_chamfer_radial_mm = 0.8; //[0.3:3:0.1]
connect_overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// M16x30 Insert - complete geometry
module insert() {
  color("Silver") {
    difference() {
      union() {
        // Main body
        cylinder(r=insert_outer_diameter_mm/2, h=insert_length_mm, center=true);
        
        // Outer ribs
        for (i = [0:outer_rib_count-1]) {
          rotate([0, 0, i*360/outer_rib_count]) {
            translate([insert_outer_diameter_mm/2 + outer_rib_radial_height_mm/2 - connect_overlap_mm, 0, 0]) {
              cube([outer_rib_radial_height_mm + connect_overlap_mm, outer_rib_tangential_width_mm, outer_rib_length_mm], center=true);
            }
          }
        }
      }
      
      // Internal bore
      cylinder(r=(screw_nominal_diameter_mm + internal_thread_clearance_mm)/2, h=insert_length_mm + 2*eps_mm, center=true);
      
      // Entry chamfer
      translate([0, 0, insert_length_mm/2 - (entry_chamfer_radial_mm / tan(entry_chamfer_angle_deg)) / 2 + eps_mm/2]) {
        rotate([180, 0, 0]) {
          cylinder(r1=insert_outer_diameter_mm/2, r2=0, h=entry_chamfer_radial_mm / tan(entry_chamfer_angle_deg), center=true);
        }
      }
      
      // Tip chamfer
      translate([0, 0, -insert_length_mm/2 + (tip_chamfer_radial_mm / tan(tip_chamfer_angle_deg)) / 2 - eps_mm/2]) {
        cylinder(r1=insert_outer_diameter_mm/2, r2=0, h=tip_chamfer_radial_mm / tan(tip_chamfer_angle_deg), center=true);
      }
      
      // Bore entry chamfer
      translate([0, 0, insert_length_mm/2 - (bore_entry_chamfer_radial_mm / tan(entry_chamfer_angle_deg)) / 2 + eps_mm/2]) {
        rotate([180, 0, 0]) {
          cylinder(r1=(screw_nominal_diameter_mm + internal_thread_clearance_mm)/2 + bore_entry_chamfer_radial_mm, r2=0, h=bore_entry_chamfer_radial_mm / tan(entry_chamfer_angle_deg), center=true);
        }
      }
      
      // Bore tip chamfer
      translate([0, 0, -insert_length_mm/2 + (bore_tip_chamfer_radial_mm / tan(tip_chamfer_angle_deg)) / 2 - eps_mm/2]) {
        cylinder(r1=(screw_nominal_diameter_mm + internal_thread_clearance_mm)/2 + bore_tip_chamfer_radial_mm, r2=0, h=bore_tip_chamfer_radial_mm / tan(tip_chamfer_angle_deg), center=true);
      }
    }
  }
}

// Threaded Insert - complete geometry
module threaded_insert() {
  insert();
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();