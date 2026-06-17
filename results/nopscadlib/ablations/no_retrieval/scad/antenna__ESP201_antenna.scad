// Parameters
mast_h = 150; //[75:300:1]
mast_d = 6; //[3:12:0.1]
base_d = 20; //[10:40:0.5]
base_h = 8; //[4:16:0.5]
flange_d = 30; //[15:60:0.5]
flange_h = 3; //[1.5:8:0.5]
hole_count = 4; //[2:8:1]
hole_d = 3.2; //[2:6:0.1]
hole_circle_d = 22; //[12:44:0.5]
connector_d = 8; //[4:16:0.5]
connector_h = 12; //[6:30:1]
tip_h = 12; //[6:30:1]
tip_d2 = 1.5; //[0.5:4:0.1]
boot_h = 18; //[8:40:1]
boot_d = 14; //[8:28:0.5]
knurl_count = 24; //[8:64:1]
knurl_depth = 0.8; //[0.3:2:0.1]
knurl_w = 1.2; //[0.6:3:0.1]
knurl_h = 6; //[2:12:0.5]
overlap = 1; //[0.5:2:0.1]
hole_extra_h = 2; //[1:6:0.5]
enable_flange = 1; //[0:1:1]
enable_connector = 1; //[0:1:1]

// Base Cylinder
module base_cyl() {
  translate([0, 0, 0])
    cylinder(h=base_h, r=base_d/2, center=true);
}

// Mast Cylinder
module mast_cyl() {
  translate([0, 0, base_h/2 + mast_h/2 - overlap])
    cylinder(h=mast_h, r=mast_d/2, center=true);
}

// Tapered Tip Cone
module tapered_tip_cone() {
  translate([0, 0, base_h/2 + mast_h - overlap + tip_h/2])
    cylinder(h=tip_h, r1=mast_d/2, r2=tip_d2/2, center=true);
}

// Strain Relief Boot Cone
module strain_relief_boot_cone() {
  translate([0, 0, base_h/2 + boot_h/2 - overlap])
    cylinder(h=boot_h, r1=boot_d/2, r2=mast_d/2, center=true);
}

// Mounting Flange Cylinder
module mounting_flange_cyl() {
  translate([0, 0, -base_h/2 - (flange_h*enable_flange)/2 + overlap])
    cylinder(h=flange_h*enable_flange, r=flange_d/2, center=true);
}

// Connector Stub Cylinder
module connector_stub_cyl() {
  translate([0, 0, -base_h/2 - (flange_h*enable_flange) - (connector_h*enable_connector)/2 + overlap])
    cylinder(h=connector_h*enable_connector, r=connector_d/2, center=true);
}

// Mounting Holes
module mount_hole_0() {
  translate([hole_circle_d/2, 0, -base_h/2 - (flange_h*enable_flange)/2 + overlap])
    cylinder(h=flange_h*enable_flange + hole_extra_h, r=hole_d/2, center=true);
}

module mount_hole_90() {
  translate([0, hole_circle_d/2, -base_h/2 - (flange_h*enable_flange)/2 + overlap])
    cylinder(h=flange_h*enable_flange + hole_extra_h, r=hole_d/2, center=true);
}

module mount_hole_180() {
  translate([-hole_circle_d/2, 0, -base_h/2 - (flange_h*enable_flange)/2 + overlap])
    cylinder(h=flange_h*enable_flange + hole_extra_h, r=hole_d/2, center=true);
}

module mount_hole_270() {
  translate([0, -hole_circle_d/2, -base_h/2 - (flange_h*enable_flange)/2 + overlap])
    cylinder(h=flange_h*enable_flange + hole_extra_h, r=hole_d/2, center=true);
}

// Knurl Ribs
module knurl_rib(angle) {
  rotate([0, 0, angle])
    translate([base_d/2 + knurl_depth/2 - overlap, 0, -base_h/2 + knurl_h/2 + overlap])
      cube([knurl_depth, knurl_w, knurl_h], center=true);
}

// Assemble the antenna
module antenna() {
  difference() {
    union() {
      // Main solids
      union() {
        base_cyl();
        mast_cyl();
        tapered_tip_cone();
        strain_relief_boot_cone();
        mounting_flange_cyl();
        connector_stub_cyl();
      }
      // Knurling
      for (i = [0:knurl_count-1])
        knurl_rib(i * 360/knurl_count);
    }
    // Mounting holes
    mount_hole_0();
    mount_hole_90();
    mount_hole_180();
    mount_hole_270();
  }
}

// Render the antenna
antenna();