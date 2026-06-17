// Parameters
mast_height = 300; //[150:600:1]
mast_diameter = 8; //[4:16:1]
base_height = 20; //[10:40:1]
base_diameter = 30; //[15:60:1]
flange_thickness = 3; //[2:8:1]
flange_diameter = 40; //[20:80:1]
hole_count = 3; //[2:8:1]
hole_diameter = 4; //[2:10:1]
hole_circle_diameter = 32; //[16:64:1]
overlap = 1; //[0.5:2:0.5]
tip_cap_height = 10; //[5:25:1]
tip_cap_diameter = 10; //[6:20:1]
connector_diameter = 12; //[6:24:1]
connector_length = 18; //[8:40:1]
connector_offset_y = 0; //[-10:10:1]
knurl_tooth_count = 24; //[12:60:1]
knurl_tooth_depth = 1; //[0.5:2:0.5]
knurl_band_height = 10; //[5:20:1]

// Base shapes
module mast_cyl() {
  translate([0, 0, base_height + flange_thickness - overlap + mast_height / 2])
    cylinder(h = mast_height, r = mast_diameter / 2, center = true);
}

module base_mount_cyl() {
  translate([0, 0, flange_thickness + base_height / 2 - overlap])
    cylinder(h = base_height, r = base_diameter / 2, center = true);
}

module base_flange_cyl() {
  translate([0, 0, flange_thickness / 2])
    cylinder(h = flange_thickness, r = flange_diameter / 2, center = true);
}

module tip_cap_cyl() {
  translate([0, 0, base_height + flange_thickness - overlap + mast_height + tip_cap_height / 2 - overlap])
    cylinder(h = tip_cap_height, r = tip_cap_diameter / 2, center = true);
}

module connector_cyl() {
  translate([base_diameter / 2 + connector_length / 2 - overlap, connector_offset_y, flange_thickness + base_height / 2 - overlap])
    rotate([0, 90, 0])
    cylinder(h = connector_length, r = connector_diameter / 2, center = true);
}

module knurl_tooth_box(angle) {
  translate([base_diameter / 2 + knurl_tooth_depth / 2 - overlap, 0, flange_thickness + base_height - knurl_band_height / 2 - overlap])
    rotate([0, 0, angle])
    cube([knurl_tooth_depth, base_diameter * 0.12, knurl_band_height], center = true);
}

module mount_hole_cyl(angle) {
  translate([hole_circle_diameter / 2 * cos(angle), hole_circle_diameter / 2 * sin(angle), (flange_thickness + base_height) / 2])
    cylinder(h = flange_thickness + base_height + overlap * 2, r = hole_diameter / 2, center = true);
}

// Operations
module antenna_solid_union() {
  union() {
    base_flange_cyl();
    base_mount_cyl();
    mast_cyl();
    tip_cap_cyl();
    connector_cyl();
    for (i = [0:knurl_tooth_count-1]) {
      knurl_tooth_box(i * 360 / knurl_tooth_count);
    }
  }
}

module antenna_with_mounting_holes() {
  difference() {
    antenna_solid_union();
    for (i = [0:hole_count-1]) {
      mount_hole_cyl(i * 360 / hole_count);
    }
  }
}

// Final output
color("Silver") antenna_with_mounting_holes();