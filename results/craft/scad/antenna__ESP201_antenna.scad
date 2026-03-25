// Parameters
antenna_height = 200; //[100:400:1]
antenna_diameter = 6; //[3:12:0.5]
base_diameter = 30; //[15:60:1]
base_height = 12; //[6:24:1]
connector_diameter = 10; //[5:20:0.5]
connector_length = 15; //[8:30:1]
mount_hole_diameter = 4; //[2:8:0.5]
mount_hole_count = 2; //[1:6:1]
mount_hole_spacing = 20; //[10:40:1]
overlap = 1; //[0.5:2:0.1]
radome_thickness = 1.5; //[0.8:3:0.1]
radome_extra_radius = 1.5; //[0.5:4:0.1]
radome_cap_height = 12; //[6:24:1]
spring_height = 18; //[10:40:1]
spring_diameter = 12; //[8:20:0.5]
cable_diameter = 4; //[2:8:0.5]
cable_length = 60; //[30:150:1]
rib_count = 12; //[6:24:1]
rib_depth = 1.2; //[0.5:3:0.1]
rib_width = 2.2; //[1:5:0.1]
rib_height = 8; //[4:16:1]

// Base Mount with Holes
module base_mount_with_holes() {
  difference() {
    cylinder(r=base_diameter/2, h=base_height, center=true);
    translate([mount_hole_spacing/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=base_height + 2*overlap, center=true);
    translate([-mount_hole_spacing/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=base_height + 2*overlap, center=true);
  }
}

// Ribs
module rib_proto() {
  translate([base_diameter/2 - (rib_depth + overlap)/2, 0, -base_height/2 + rib_height/2 + overlap])
    cube([rib_depth + overlap, rib_width, rib_height], center=true);
}

module knurling_or_ribs() {
  union() {
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
        rib_proto();
    }
  }
}

// Base Mount with Ribs
module base_mount_with_ribs() {
  union() {
    base_mount_with_holes();
    knurling_or_ribs();
  }
}

// Connector Stub
module connector_stub() {
  translate([0, 0, -base_height/2 - connector_length/2 + overlap])
    cylinder(r=connector_diameter/2, h=connector_length, center=true);
}

// Cable
module cable() {
  translate([0, 0, -base_height/2 - connector_length - cable_length/2 + overlap])
    cylinder(r=cable_diameter/2, h=cable_length, center=true);
}

// Spring Flex Section
module spring_flex_section() {
  translate([0, 0, base_height/2 + spring_height/2 - overlap])
    cylinder(r=spring_diameter/2, h=spring_height, center=true);
}

// Radiating Element
module radiating_element() {
  translate([0, 0, base_height/2 + spring_height - overlap + antenna_height/2])
    cylinder(r=antenna_diameter/2, h=antenna_height, center=true);
}

// Radome Cover
module radome_cover() {
  difference() {
    translate([0, 0, base_height/2 + spring_height - overlap + (antenna_height + radome_cap_height)/2])
      cylinder(r=antenna_diameter/2 + radome_extra_radius, h=antenna_height + radome_cap_height, center=true);
    translate([0, 0, base_height/2 + spring_height - overlap + (antenna_height + radome_cap_height)/2 + radome_thickness])
      cylinder(r=antenna_diameter/2 + radome_extra_radius - radome_thickness, h=antenna_height + radome_cap_height, center=true);
  }
}

// Branding Text Placeholder
module branding_text_placeholder() {
  translate([0, 0, -base_height/2 + radome_thickness/2])
    cube([base_diameter/4, base_diameter/10, radome_thickness], center=true);
}

// Antenna Assembly
module antenna_assembly_union() {
  union() {
    base_mount_with_ribs();
    connector_stub();
    cable();
    spring_flex_section();
    radiating_element();
    radome_cover();
    branding_text_placeholder();
  }
}

// Final Output
antenna_assembly_union();