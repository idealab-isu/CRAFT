$fn=96;

// Centrifugal blower fan (approx) 30.0 x 30.0 x 10.1 mm
// Z up, centered at origin. ONE connected solid (external shell + internal impeller fused).

size_xy = 30.0;
height  = 10.1;

// Housing
wall    = 1.2;
base_th = 1.2;
top_th  = 1.0;

corner_r = 3.0;

// Internal cavity
cav_xy = size_xy - 2*wall;
cav_h  = height - base_th - top_th;

// Impeller / scroll
imp_r     = 10.2;
clearance = 0.8;
scroll_r0 = imp_r + clearance;
scroll_r1 = (cav_xy/2) - 0.8;

// Outlet (rectangular duct)
out_w   = 10.0;  // width in Y
out_h   = 6.0;   // height in Z
out_len = 8.0;   // length in X (outside)
out_wall = 1.2;  // duct wall thickness

// Inlet (top)
inlet_r = 6.0;

// Motor hub + impeller
hub_r = 3.2;
hub_h = 6.0;
shaft_r = 1.2;

blade_count = 11;
blade_th = 0.9;
blade_h  = 6.2;
blade_r0 = hub_r + 0.8;
blade_r1 = imp_r;
blade_twist = 28; // degrees

// Small overlap to guarantee connectivity between parts
eps = 0.25;

module rounded_square_2d(s, r){
    offset(r=r) offset(delta=-r) square([s,s], center=true);
}

module housing_outer(){
    // Outer body only (no cuts)
    linear_extrude(height=height)
        rounded_square_2d(size_xy, corner_r);
}

module housing_shell_with_openings(){
    // Outer shell with internal cavity + inlet + outlet opening
    difference(){
        housing_outer();

        // Inner cavity
        translate([0,0,base_th])
            linear_extrude(height=cav_h)
                rounded_square_2d(cav_xy, max(0.1, corner_r - wall));

        // Outlet opening through side wall into cavity
        // Place so inner face reaches into cavity and outer face exits the body.
        // X center at outer wall mid-plane.
        translate([size_xy/2 - wall/2, 0, base_th + (cav_h - out_h)/2])
            rotate([0,90,0])
                cube([out_h, out_w, out_len + wall + 0.6], center=true);

        // Top inlet hole through top thickness
        translate([0,0,height-top_th-eps])
            cylinder(h=top_th + 2*eps, r=inlet_r, center=false);

        // Bottom small relief (cosmetic)
        translate([0,0,-eps])
            cylinder(h=base_th + 2*eps, r=1.5, center=false);
    }
}

module outlet_duct_solid(){
    // External duct that protrudes from the right side and connects to the outlet opening.
    // Built as a hollow rectangular tube (solid walls), fused to housing.
    // Duct axis along +X.
    duct_len = out_len;
    // Center of duct: start at housing outer face and extend outward.
    // Housing outer face at x = size_xy/2. Duct spans [size_xy/2 - eps, size_xy/2 + duct_len]
    x_center = size_xy/2 + duct_len/2 - eps;

    z_center = base_th + cav_h/2; // align with cavity mid-height
    union(){
        translate([x_center, 0, z_center])
            difference(){
                cube([duct_len, out_w + 2*out_wall, out_h + 2*out_wall], center=true);
                cube([duct_len + 2*eps, out_w, out_h], center=true);
            }

        // Small fillet-like brace to visually blend duct into housing (keeps one solid)
        // Uses hull between a thin slice on housing face and a thin slice on duct.
        hull(){
            translate([size_xy/2 - eps, 0, z_center])
                cube([2*eps, out_w + 2*out_wall, out_h + 2*out_wall], center=true);
            translate([size_xy/2 + 2*eps, 0, z_center])
                cube([4*eps, out_w + 2*out_wall, out_h + 2*out_wall], center=true);
        }
    }
}

module volute_wall_solid(){
    // Spiral "fence" inside cavity to resemble a volute.
    steps = 240;
    ang0 = -150;
    ang1 = 230;
    band = 1.3;

    pts_outer = [
        for(i=[0:steps])
            let(t=i/steps,
                a=ang0 + (ang1-ang0)*t,
                r=scroll_r0 + (scroll_r1-scroll_r0)*t)
            [r*cos(a), r*sin(a)]
    ];

    pts_inner = [
        for(i=[steps:-1:0])
            let(t=i/steps,
                a=ang0 + (ang1-ang0)*t,
                r=(scroll_r0 + (scroll_r1-scroll_r0)*t) - band)
            [r*cos(a), r*sin(a)]
    ];

    // Keep it inside cavity footprint and ensure it touches base for connectivity.
    intersection(){
        translate([0,0,base_th - eps])
            linear_extrude(height=cav_h + 2*eps)
                polygon(concat(pts_outer, pts_inner));

        translate([0,0,base_th - eps])
            linear_extrude(height=cav_h + 2*eps)
                rounded_square_2d(cav_xy-0.4, max(0.1, corner_r - wall - 0.2));
    }
}

module impeller_solid(){
    // Impeller sits inside cavity, centered under inlet.
    // Slightly overlaps base to guarantee union connectivity.
    z0 = base_th - eps;

    union(){
        // Backplate (touches base)
        translate([0,0,z0])
            cylinder(h=1.0 + eps, r=imp_r-0.4, center=false);

        // Hub
        translate([0,0,z0])
            cylinder(h=hub_h, r=hub_r, center=false);

        // Shaft stub up toward inlet (kept inside cavity)
        shaft_h = max(0.1, (height - top_th) - (z0 + hub_h) - 0.6);
        translate([0,0,z0+hub_h])
            cylinder(h=shaft_h, r=shaft_r, center=false);

        // Blades (curved via twist)
        for(k=[0:blade_count-1]){
            rotate([0,0,360*k/blade_count])
                translate([blade_r0, -blade_th/2, z0+1.0])
                    linear_extrude(height=blade_h, twist=blade_twist, slices=24)
                        square([blade_r1-blade_r0, blade_th], center=false);
        }

        // Front shroud ring (thin)
        translate([0,0,z0+1.0+blade_h-0.8])
            difference(){
                cylinder(h=0.8, r=imp_r, center=false);
                translate([0,0,-eps])
                    cylinder(h=0.8 + 2*eps, r=imp_r-1.2, center=false);
            }
    }
}

module mounting_bosses_solid(){
    // Corner bosses with through holes (holes are voids in the solid)
    boss_r = 2.2;
    hole_r = 1.2;
    inset  = 4.0;

    difference(){
        union(){
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*(size_xy/2 - inset), sy*(size_xy/2 - inset), 0])
                    cylinder(h=height, r=boss_r, center=false);
            }
        }
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*(size_xy/2 - inset), sy*(size_xy/2 - inset), -eps])
                cylinder(h=height + 2*eps, r=hole_r, center=false);
        }
    }
}

module blower(){
    // One connected solid: housing + duct + internal volute + impeller + bosses
    // (Internal parts are fused to base via slight overlap.)
    union(){
        housing_shell_with_openings();
        outlet_duct_solid();
        volute_wall_solid();
        impeller_solid();

        // Bosses clipped to outer footprint so they don't protrude past rounded square
        intersection(){
            mounting_bosses_solid();
            housing_outer();
        }
    }
}

translate([0,0,-height/2]) blower();