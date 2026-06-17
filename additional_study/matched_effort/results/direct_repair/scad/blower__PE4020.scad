$fn=96;

// Centrifugal blower fan 40x40x20mm (approximate model)
size_x = 40;
size_y = 40;
size_z = 20;

wall = 1.6;
base_th = 2.0;

outlet_w = 14.0;
outlet_h = 10.0;
outlet_len = 10.0;

inlet_d = 22.0;
inlet_lip = 1.2;

scroll_clear = 1.2;

impeller_od = 28.0;
impeller_id = 10.0;
impeller_h  = 12.0;
hub_d = 12.0;
hub_h = 14.0;
shaft_d = 3.0;

blade_count = 11;
blade_th = 1.0;
blade_len = (impeller_od - impeller_id)/2 - 0.6;
blade_twist = 28; // degrees

module rounded_box(x,y,z,r){
    // Minkowski rounded edges
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=false);
        sphere(r=r);
    }
}

module housing_outer(){
    // Outer shell with slight rounding
    translate([0,0,0])
        rounded_box(size_x, size_y, size_z, 1.2);
}

module housing_inner(){
    // Inner cavity: main chamber + scroll cavity + outlet duct
    // Main cavity
    translate([wall, wall, base_th])
        cube([size_x-2*wall, size_y-2*wall, size_z-base_th-wall], center=false);

    // Scroll cavity (cylindrical region around impeller)
    // Centered slightly toward inlet side to mimic blower geometry
    cx = size_x*0.52;
    cy = size_y*0.52;
    cz = base_th + (size_z-base_th-wall)/2;

    translate([cx, cy, base_th])
        cylinder(h=size_z-base_th-wall, d=impeller_od + 2*scroll_clear, center=false);

    // Outlet duct cavity
    // Outlet on +X side
    translate([size_x-wall, (size_y-outlet_w)/2, base_th + (size_z-base_th-wall-outlet_h)/2])
        cube([outlet_len, outlet_w, outlet_h], center=false);
}

module inlet_hole(){
    // Inlet on top face (Z+)
    cx = size_x*0.52;
    cy = size_y*0.52;
    translate([cx, cy, size_z-wall])
        cylinder(h=wall+0.5, d=inlet_d, center=false);
}

module inlet_lip_ring(){
    // Small raised ring around inlet
    cx = size_x*0.52;
    cy = size_y*0.52;
    translate([cx, cy, size_z-wall])
        difference(){
            cylinder(h=inlet_lip, d=inlet_d+4.0, center=false);
            translate([0,0,-0.1]) cylinder(h=inlet_lip+0.2, d=inlet_d, center=false);
        }
}

module mounting_posts(){
    // Simple corner bosses inside base
    post_d = 6.0;
    hole_d = 3.2;
    post_h = 6.0;

    pts = [
        [6,6],
        [size_x-6,6],
        [6,size_y-6],
        [size_x-6,size_y-6]
    ];

    for(p=pts){
        translate([p[0], p[1], base_th])
            difference(){
                cylinder(h=post_h, d=post_d, center=false);
                translate([0,0,-0.1]) cylinder(h=post_h+0.2, d=hole_d, center=false);
            }
    }
}

module impeller(){
    // Impeller positioned under inlet
    cx = size_x*0.52;
    cy = size_y*0.52;
    z0 = base_th + 2.0;

    translate([cx, cy, z0]){
        // Hub + shaft
        union(){
            difference(){
                cylinder(h=hub_h, d=hub_d, center=false);
                translate([0,0,-0.1]) cylinder(h=hub_h+0.2, d=shaft_d, center=false);
            }

            // Backplate
            translate([0,0,0])
                difference(){
                    cylinder(h=1.2, d=impeller_od, center=false);
                    translate([0,0,-0.1]) cylinder(h=1.4, d=impeller_id, center=false);
                }

            // Shroud ring (partial height)
            translate([0,0,impeller_h-1.2])
                difference(){
                    cylinder(h=1.2, d=impeller_od, center=false);
                    translate([0,0,-0.1]) cylinder(h=1.4, d=impeller_od-3.0, center=false);
                }

            // Blades (backward-curved approximation via twisted extrude)
            for(i=[0:blade_count-1]){
                rotate([0,0,i*360/blade_count])
                    translate([impeller_id/2 + 0.6, -blade_th/2, 1.2])
                        linear_extrude(height=impeller_h-2.4, twist=-blade_twist, slices=24)
                            square([blade_len, blade_th], center=false);
            }
        }
    }
}

module blower(){
    difference(){
        union(){
            // Outer housing
            housing_outer();

            // Inlet lip
            inlet_lip_ring();
        }

        // Hollow interior
        housing_inner();

        // Inlet hole
        inlet_hole();

        // Outlet opening to outside
        translate([size_x-0.01, (size_y-outlet_w)/2, base_th + (size_z-base_th-wall-outlet_h)/2])
            cube([outlet_len+0.5, outlet_w, outlet_h], center=false);
    }

    // Internal mounting posts
    mounting_posts();

    // Impeller (for visualization)
    impeller();
}

blower();