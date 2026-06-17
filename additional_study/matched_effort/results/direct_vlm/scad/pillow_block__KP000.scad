$fn = 96;

// Pillow block bearing housing (UCP-style) for 10.0mm shaft
// Base: 67.0mm x 53.0mm
// Units: mm

// -------- Parameters --------
shaft_d = 10.0;
bore_d  = 10.2;                 // clearance

base_L = 67.0;
base_W = 53.0;
base_H = 12.0;

mount_hole_d = 11.0;            // clearance holes
mount_hole_x = 50.0;            // center-to-center along length

// Use visible slots typical of pillow blocks (still satisfies hole clearance)
slot_len = 18.0;                // along X
slot_w   = mount_hole_d;        // across Y

pedestal_L = 52.0;
pedestal_W = 40.0;
pedestal_H = 18.0;

housing_outer_d = 44.0;         // outer housing diameter
housing_len = 34.0;             // along X

bearing_seat_d = 22.0;          // visual counterbore
bearing_seat_len = 22.0;

set_screw_d = 4.2;              // M4-ish

fillet_r = 3.0;
overlap = 0.8;                  // small overlap to ensure watertight unions

// Derived
housing_center_z = base_H + pedestal_H + housing_outer_d/2;

// -------- Helpers --------
module rounded_block(size=[10,10,10], r=2) {
    sx = max(size[0]-2*r, 0.01);
    sy = max(size[1]-2*r, 0.01);
    sz = max(size[2]-2*r, 0.01);
    minkowski() {
        cube([sx, sy, sz], center=true);
        sphere(r=r);
    }
}

module capsule2d_x(d=10, len=20) {
    hull() {
        translate([-len/2,0]) circle(d=d);
        translate([ len/2,0]) circle(d=d);
    }
}

module capsule_x(d=20, len=30, h=1, center=true) {
    linear_extrude(height=h, center=center)
        capsule2d_x(d=d, len=len);
}

module slot_through_base(xc=0, yc=0, len=18, w=11, h=20) {
    // Slot is a capsule in XY, extruded in Z
    translate([xc, yc, base_H/2])
        linear_extrude(height=h, center=true)
            capsule2d_x(d=w, len=len);
}

// -------- Model --------
module pillow_block() {
    difference() {
        union() {
            // Base (67 x 53)
            translate([0,0,base_H/2])
                rounded_block([base_L, base_W, base_H], r=fillet_r);

            // Pedestal (connected to base with slight overlap)
            translate([0,0,base_H + pedestal_H/2 - overlap/2])
                rounded_block([pedestal_L, pedestal_W, pedestal_H], r=fillet_r);

            // Housing body: capsule-like along X, solid (not a thin shell)
            translate([0,0,housing_center_z])
                hull() {
                    translate([0,0,-housing_outer_d/2 + 1.2])
                        capsule_x(d=housing_outer_d, len=housing_len, h=2.4, center=true);
                    translate([0,0, housing_outer_d/2 - 1.2])
                        capsule_x(d=housing_outer_d, len=housing_len, h=2.4, center=true);
                }

            // Ribs from pedestal to housing (ensure clear connected support)
            for (sy = [-1, 1]) {
                hull() {
                    translate([0, sy*(pedestal_W/2 - 6), base_H + pedestal_H - 2])
                        cube([pedestal_L*0.85, 10, 4], center=true);
                    translate([0, sy*(housing_outer_d*0.35), housing_center_z - housing_outer_d*0.25])
                        cube([housing_len*0.9, 10, 4], center=true);
                }
            }

            // Small top boss for set screw area (connected to housing with overlap)
            translate([0,0,housing_center_z + housing_outer_d*0.25 - overlap])
                rotate([0,90,0])
                    cylinder(d=12, h=housing_len*0.55, center=true);
        }

        // --- Mounting slots (2) through base, visible in orthographic views ---
        for (sx = [-1, 1]) {
            slot_through_base(
                xc = sx*mount_hole_x/2,
                yc = 0,
                len = slot_len,
                w  = slot_w,
                h  = base_H + 2
            );

            // shallow top recess around slot (counterbore-ish)
            translate([sx*mount_hole_x/2, 0, base_H - 2.2])
                linear_extrude(height=4.6, center=false)
                    capsule2d_x(d=18, len=slot_len + (18 - slot_w));
        }

        // Main shaft bore through housing along X (clear 10mm)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bore_d, h=base_L + 40, center=true);

        // Bearing seat counterbore (visual) centered in housing
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bearing_seat_d, h=bearing_seat_len, center=true);

        // Undercut to create the typical "U" opening under the bearing
        // Keep it as a local cut so the housing remains connected to the pedestal.
        undercut_d = housing_outer_d*1.10;
        undercut_z = housing_center_z - housing_outer_d*0.62;
        // Limit cut height so it doesn't remove the entire lower housing/pedestal connection
        translate([0,0,undercut_z])
            intersection() {
                rotate([0,90,0])
                    cylinder(d=undercut_d, h=housing_len + 8, center=true);
                // Z-limiter block: only cut the lower portion of the housing
                translate([0,0,-housing_outer_d*0.35])
                    cube([housing_len + 20, undercut_d + 20, housing_outer_d*0.70], center=true);
            }

        // Side reliefs to open the housing cheeks slightly (visual)
        for (sy = [-1, 1]) {
            translate([0, sy*(housing_outer_d*0.62), housing_center_z])
                cube([housing_len + 10, housing_outer_d*0.35, housing_outer_d*1.2], center=true);
        }

        // Set screw hole (radial into bore from top)
        translate([0,0,housing_center_z + housing_outer_d*0.25])
            rotate([90,0,0])
                cylinder(d=set_screw_d, h=housing_outer_d + 20, center=true);
    }
}

pillow_block();