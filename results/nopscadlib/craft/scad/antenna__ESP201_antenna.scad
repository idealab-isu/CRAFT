// A antenna (connected solid, consistent orthographic visibility)

// Quality
$fn = 96;

// Parameters
mast_h = 200; //[100:400:1]
mast_r = 1.5; //[0.75:3:0.1]
base_h = 20; //[10:40:1]
base_r = 8; //[4:16:0.5]
mount_hole_d = 4; //[2:8:0.25]
mount_hole_depth = 15; //[7.5:30:1]
overlap = 1; //[0.5:2:0.1]
tip_h = 12; //[6:24:1]
tip_r = 0.4; //[0.2:1.5:0.05]
flange_h = 3; //[1.5:6:0.5]
flange_r = 12; //[6:24:0.5]
strain_h = 8; //[4:16:1]
strain_r = 5; //[2.5:10:0.5]
stub_h = 10; //[5:20:1]
stub_r = 6; //[3:12:0.5]

// Derived Z positions (all formulas, no arbitrary offsets)
z_base_c = 0;

z_mast_c = base_h/2 + mast_h/2 - overlap;
z_tip_c  = base_h/2 + mast_h - overlap + tip_h/2;

z_flange_c = -base_h/2 - flange_h/2 + overlap;
z_stub_c   = -base_h/2 - flange_h - stub_h/2 + overlap;

// Strain relief sits on top of base, tapering down into it (connected)
z_strain_c = base_h/2 + strain_h/2 - overlap;

// Mounting hole starts at bottom of stub and goes upward into it
z_stub_bottom = z_stub_c - stub_h/2;
z_hole_c = z_stub_bottom + mount_hole_depth/2;

// Base shapes
module base_cyl() {
    translate([0, 0, z_base_c])
        cylinder(h=base_h, r=base_r, center=true);
}

module mast_cyl() {
    translate([0, 0, z_mast_c])
        cylinder(h=mast_h, r=mast_r, center=true);
}

module tapered_tip_cone() {
    translate([0, 0, z_tip_c])
        cylinder(h=tip_h, r1=mast_r, r2=tip_r, center=true);
}

module base_flange_cyl() {
    translate([0, 0, z_flange_c])
        cylinder(h=flange_h, r=flange_r, center=true);
}

module strain_relief_cone() {
    translate([0, 0, z_strain_c])
        cylinder(h=strain_h, r1=strain_r, r2=base_r, center=true);
}

module connector_stub_cyl() {
    translate([0, 0, z_stub_c])
        cylinder(h=stub_h, r=stub_r, center=true);
}

module mounting_hole_cyl() {
    translate([0, 0, z_hole_c])
        cylinder(h=mount_hole_depth + 2*overlap, r=mount_hole_d/2, center=true);
}

// Operations
module antenna_union() {
    union() {
        base_cyl();
        mast_cyl();
        tapered_tip_cone();
        base_flange_cyl();
        strain_relief_cone();
        connector_stub_cyl();
    }
}

module antenna_with_mount_hole() {
    difference() {
        antenna_union();
        mounting_hole_cyl();
    }
}

// Final output (rotate so antenna is along X for consistent front/back/left/right visibility)
rotate([0, 90, 0])
    antenna_with_mount_hole();