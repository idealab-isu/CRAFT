$fn=96;

// Centrifugal blower fan 40x40x20mm (approx), printable mockup with housing, inlet, outlet, impeller.
size_x = 40;
size_y = 40;
size_z = 20;

wall = 2.0;
base_th = 2.0;
top_th  = 2.0;

inlet_d = 18.0;          // top inlet diameter
inlet_lip = 1.2;

outlet_w = 14.0;         // outlet opening width
outlet_h = 10.0;         // outlet opening height
outlet_len = 10.0;       // outlet duct length beyond body

scroll_clear = 1.2;      // clearance between impeller and housing
impeller_d = 28.0;
impeller_h = 12.0;
hub_d = 10.0;
hub_h = 12.0;
shaft_d = 3.0;

blade_count = 11;
blade_th = 1.0;
blade_radial = (impeller_d/2 - hub_d/2 - 0.8);
blade_height = impeller_h;
blade_twist = 18;        // degrees

module rounded_box(x,y,z,r){
    r2 = min(r, min(x,y)/2 - 0.01);
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2-r2), sy*(y/2-r2), sz*(z/2-r2)])
                sphere(r=r2);
        }
    }
}

module housing_outer(){
    rounded_box(size_x, size_y, size_z, 3.0);
}

module housing_inner(){
    // Inner cavity: mostly open volume, leaving walls and base/top thickness.
    // Slightly smaller rounded box, shifted to keep base thickness.
    translate([0,0,(base_th - top_th)/2])
        rounded_box(size_x-2*wall, size_y-2*wall, size_z-(base_th+top_th), 2.2);
}

module inlet_cut(){
    // Top inlet hole
    translate([0,0,size_z/2 - top_th/2])
        cylinder(d=inlet_d, h=top_th+2, center=true);
}

module outlet_cut(){
    // Side outlet opening + duct cavity
    // Outlet on +X side, centered in Y, located in upper half.
    zc = 0; // centered vertically in cavity
    translate([size_x/2 - wall/2, 0, zc])
        rotate([0,90,0])
            cube([outlet_len + wall + 2, outlet_w, outlet_h], center=true);
}

module scroll_cut(){
    // Create a scroll-like cavity around impeller by subtracting a growing-radius spiral-ish shape.
    // Implemented as union of rotated cylinders with increasing radius.
    // Positioned slightly toward outlet side.
    z0 = -size_z/2 + base_th + (size_z-(base_th+top_th))/2;
    translate([0,0,z0])
    union(){
        steps = 28;
        for(i=[0:steps-1]){
            a = i*(270/(steps-1)); // degrees
            r = (impeller_d/2 + scroll_clear) + (i/(steps-1))*4.0;
            // place a cylinder whose center traces a circle; union approximates scroll volume
            translate([ (r)*cos(a), (r)*sin(a), 0 ])
                cylinder(r= (impeller_d/2 + scroll_clear)*0.55, h=(size_z-(base_th+top_th))+0.6, center=true);
        }
        // Ensure central region is open
        cylinder(d=impeller_d + 2*scroll_clear + 2.0, h=(size_z-(base_th+top_th))+0.6, center=true);
    }
}

module housing(){
    difference(){
        housing_outer();
        housing_inner();
        inlet_cut();
        outlet_cut();
        // Scroll cavity (keeps walls by intersecting with inner volume implicitly)
        scroll_cut();
    }

    // Inlet lip ring on top
    translate([0,0,size_z/2 - top_th])
    difference(){
        cylinder(d=inlet_d + 2*inlet_lip, h=top_th, center=false);
        translate([0,0,-0.1]) cylinder(d=inlet_d, h=top_th+0.2, center=false);
    }

    // Outlet duct outer shell
    translate([size_x/2, 0, 0])
    difference(){
        rotate([0,90,0])
            rounded_box(outlet_len, outlet_w + 2*wall, outlet_h + 2*wall, 1.5);
        translate([wall/2,0,0])
            rotate([0,90,0])
                cube([outlet_len+2, outlet_w, outlet_h], center=true);
    }
}

module blade(){
    // A backward-curved blade segment made by extruding a 2D rectangle along Z with slight twist.
    // Positioned at radius hub_d/2 to hub_d/2+blade_radial.
    r0 = hub_d/2 + 0.4;
    w = blade_th;
    len = blade_radial;

    // 2D profile in XY, then linear_extrude in Z
    translate([r0, -w/2, -blade_height/2])
        linear_extrude(height=blade_height, twist=blade_twist, slices=24)
            square([len, w], center=false);
}

module impeller(){
    // Place impeller inside housing cavity, slightly below top.
    zc = -size_z/2 + base_th + (size_z-(base_th+top_th))/2;
    translate([0,0,zc])
    union(){
        // Backplate
        cylinder(d=impeller_d, h=1.2, center=true);

        // Hub
        cylinder(d=hub_d, h=hub_h, center=true);

        // Shaft hole (visual)
        difference(){
            cylinder(d=hub_d-1.0, h=hub_h+0.2, center=true);
            cylinder(d=shaft_d, h=hub_h+1.0, center=true);
        }

        // Blades
        for(k=[0:blade_count-1]){
            rotate([0,0,k*360/blade_count])
                blade();
        }

        // Front shroud ring (partial)
        translate([0,0,impeller_h/2 - 0.8])
        difference(){
            cylinder(d=impeller_d, h=1.2, center=true);
            cylinder(d=impeller_d-4.0, h=1.4, center=true);
        }
    }
}

module feet(){
    // Small corner feet on bottom
    foot_d = 6;
    foot_h = 1.2;
    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(size_x/2-5), sy*(size_y/2-5), -size_z/2])
            cylinder(d=foot_d, h=foot_h, center=false);
    }
}

union(){
    color([0.15,0.15,0.15]) housing();
    color([0.75,0.75,0.75]) impeller();
    color([0.15,0.15,0.15]) feet();
}