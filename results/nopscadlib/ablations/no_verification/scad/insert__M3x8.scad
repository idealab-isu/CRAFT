// Parameters
outer_diameter_mm = 8; //[4:16:0.1]
length_mm = 6; //[3:12:0.1]
screw_diameter_mm = 3; //[2:6:0.1]
core_hole_diameter_mm = 2.5; //[1.5:4:0.05]
lead_in_chamfer_mm = 0.5; //[0.2:1.5:0.05]
knurl_depth_mm = 0.3; //[0.1:0.8:0.05]
knurl_pitch_mm = 0.8; //[0.4:1.6:0.05]
knurl_rib_width_mm = 0.5; //[0.2:1.2:0.05]
knurl_rib_height_mm = 4.5; //[2:10:0.1]
knurl_rib_count = 24; //[12:48:1]
overlap_mm = 0.8; //[0.2:2:0.1]
bore_extra_mm = 0.2; //[0.05:0.6:0.05]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Gold") {
    // Insert Body
    module insert_body() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
    }

    // Knurl Ribs
    module knurl_rib_base() {
      translate([outer_diameter_mm/2 + (knurl_depth_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([knurl_depth_mm + overlap_mm, knurl_rib_width_mm, knurl_rib_height_mm], center=true);
    }

    module installation_knurl_or_ribs() {
      union() {
        for (i = [0:knurl_rib_count-1]) {
          rotate([0, 0, i*360/knurl_rib_count]) knurl_rib_base();
        }
      }
    }

    // Internal Thread or Core Bore
    module internal_thread_or_core_bore() {
      cylinder(r=core_hole_diameter_mm/2, h=length_mm + bore_extra_mm, center=true, $fn=64);
    }

    // Lead-in Chamfer
    module lead_in_chamfer() {
      translate([0, 0, -length_mm/2 + lead_in_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2, r2=core_hole_diameter_mm/2, h=lead_in_chamfer_mm, center=true, $fn=64);
    }

    // Combine Insert Body and Knurl Ribs
    module insert_body_with_knurl() {
      union() {
        insert_body();
        installation_knurl_or_ribs();
      }
    }

    // Final Threaded Insert
    difference() {
      insert_body_with_knurl();
      internal_thread_or_core_bore();
      lead_in_chamfer();
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();