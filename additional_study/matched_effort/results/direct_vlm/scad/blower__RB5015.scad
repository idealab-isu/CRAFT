$fn = 96;

// Centrifugal blower fan (approx) 51.3mm x 51.0mm x 15.0mm
// Coordinate system: Z up. Overall bounding box: X=51.3, Y=51.0, Z=15.0

// ---------- Parameters ----------
overall_x = 51.3;
overall_y = 51.0;
overall_z = 15.0;

wall = 1.6;                 // housing wall thickness
base_th = 2.0;              // bottom thickness
top_th  = 1.6;              // top thickness (kept as a rim; interior is hollow)

corner_r = 4.0;             // outer corner radius
inner_corner_r = max(0.8, corner_r - wall);

inlet_d = 24.0;             // top inlet diameter
inlet_rim_h = 1.2;          // small raised rim around inlet

// Internal scroll / impeller cavity
cav_z0 = base_th;
cav_z1 = overall_z - top_th;
cav_h  = cav_z1 - cav_z0;

impeller_od = 38.0;
impeller_id = 12.0;
impeller_h  = cav_h - 0.8;

blade_count = 11;
blade_th = 1.0;
blade_len = (impeller_od/2 - impeller_id/2) * 0.92;
blade_twist = 18;           // degrees of sweep

// Outlet
outlet_w = 18.0;
outlet_h = 9.0;
outlet_len = 14.0;
outlet_center_y = 0;        // centered in Y
outlet_z0 = 3.0;            // from bottom
outlet_z1 = outlet_z0 + outlet_h;

// Mounting feet / bosses (simple)
boss_d = 6.0;
boss_h = 2.2;
boss_hole_d = 3.2;
boss_inset_x = 6.5;
boss_inset_y = 6.5;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module rounded_box(w, h, z, r) {
    linear_extrude(height=z) rounded_rect_2d(w, h, r);
}

module ring(r1, r2, h) {
    difference() {
        cylinder(r=r2, h=h);
        translate([0,0,-0.1]) cylinder(r=r1, h=h+0.2);
    }
}

module impeller() {
    // Hub + blades (simple radial swept blades)
    translate([0,0,cav_z0 + 0.4]) {
        // hub
        difference() {
            cylinder(r=impeller_id/2 + 2.2, h=impeller_h);
            translate([0,0,-0.1]) cylinder(r=impeller_id/2, h=impeller_h+0.2);
        }

        // blades
        for (i = [0:blade_count-1]) {
            ang = i * 360/blade_count;
            rotate([0,0,ang]) {
                // swept blade as a thin extruded polygon with slight twist
                translate([impeller_id/2 + 0.6, -blade_th/2, 0]) 
                    linear_extrude(height=impeller_h, twist=blade_twist, slices=24)
                        polygon(points=[
                            [0, 0],
                            [blade_len, 0.2],
                            [blade_len, blade_th],
                            [0, blade_th]
                        ]);
            }
        }

        // outer shroud ring (helps look like a blower wheel)
        translate([0,0,impeller_h*0.15])
            ring(r1=impeller_od/2 - 1.6, r2=impeller_od/2, h=impeller_h*0.7);
    }
}

module housing_shell() {
    // Outer body
    difference() {
        union() {
            // main rounded box
            rounded_box(overall_x, overall_y, overall_z, corner_r);

            // outlet duct (external)
            translate([overall_x/2, outlet_center_y, outlet_z0])
                translate([0, -outlet_w/2, 0])
                    cube([outlet_len, outlet_w, outlet_h]);

            // inlet rim on top
            translate([0,0,overall_z - inlet_rim_h])
                ring(r1=inlet_d/2, r2=inlet_d/2 + 1.2, h=inlet_rim_h);

            // mounting bosses (bottom)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*(overall_x/2 - boss_inset_x), sy*(overall_y/2 - boss_inset_y), 0])
                    cylinder(d=boss_d, h=boss_h);
            }
        }

        // Hollow interior cavity (main)
        translate([0,0,cav_z0])
            linear_extrude(height=cav_h)
                rounded_rect_2d(overall_x - 2*wall, overall_y - 2*wall, inner_corner_r);

        // Inlet hole through top
        translate([0,0,overall_z - top_th - 0.1])
            cylinder(d=inlet_d, h=top_th + 0.2);

        // Outlet opening (cut through wall into cavity)
        translate([overall_x/2 - 0.2, outlet_center_y, outlet_z0])
            translate([0, -outlet_w/2 + wall*0.2, 0])
                cube([outlet_len + 0.6, outlet_w - wall*0.4, outlet_h]);

        // Boss holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(overall_x/2 - boss_inset_x), sy*(overall_y/2 - boss_inset_y), -0.1])
                cylinder(d=boss_hole_d, h=boss_h + base_th + 0.4);
        }

        // Slight scroll shaping: carve a crescent to suggest volute
        translate([0,0,cav_z0])
            linear_extrude(height=cav_h)
                difference() {
                    circle(r=impeller_od/2 + 4.5);
                    translate([6.0,0]) circle(r=impeller_od/2 - 2.0);
                }
    }
}

module blower_fan() {
    union() {
        housing_shell();
        // show impeller inside (non-functional clearance model)
        impeller();
    }
}

blower_fan();