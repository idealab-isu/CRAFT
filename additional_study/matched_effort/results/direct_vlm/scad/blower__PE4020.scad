$fn = 96;

// Centrifugal blower fan (approximate), 40x40x20 mm
// Includes: outer housing, internal scroll cavity, inlet, outlet, and a simple impeller.

size_x = 40;
size_y = 40;
size_z = 20;

wall = 2.0;
base_th = 2.0;
top_th  = 2.0;

inlet_d = 18.0;
inlet_ring_th = 1.5;

outlet_w = 14.0;
outlet_h = 10.0;

impeller_d = 26.0;
impeller_h = 12.0;
hub_d = 8.0;
hub_h = impeller_h;

blade_count = 11;
blade_th = 1.2;
blade_len = (impeller_d/2 - hub_d/2) * 0.95;
blade_height = impeller_h * 0.95;
blade_twist = 25; // degrees

module rounded_box(x,y,z,r=2){
  // Minkowski rounded edges
  minkowski(){
    cube([x-2*r, y-2*r, z-2*r], center=true);
    sphere(r=r);
  }
}

module housing(){
  // Outer shell with internal cavity and outlet + inlet opening
  difference(){
    // Outer body
    translate([0,0,size_z/2])
      rounded_box(size_x, size_y, size_z, r=2);

    // Internal cavity (main)
    translate([0,0,base_th + (size_z-base_th-top_th)/2])
      rounded_box(size_x-2*wall, size_y-2*wall, size_z-base_th-top_th, r=1.5);

    // Scroll shaping: subtract a slightly offset cylinder to create volute-like cavity
    translate([2.5,0,base_th + (size_z-base_th-top_th)/2])
      cylinder(d=30, h=size_z-base_th-top_th+0.2, center=true);

    // Inlet hole (top face)
    translate([0,0,size_z - top_th/2])
      cylinder(d=inlet_d, h=top_th+0.6, center=true);

    // Outlet port cut (side)
    // Outlet on +X side
    translate([size_x/2 - wall/2, 0, base_th + outlet_h/2 + 2])
      cube([wall+1.0, outlet_w, outlet_h], center=true);

    // Outlet internal channel cut
    translate([size_x/2 - wall - 4.0, 0, base_th + outlet_h/2 + 2])
      cube([10.0, outlet_w-2.0, outlet_h-2.0], center=true);
  }

  // Inlet ring on top
  translate([0,0,size_z - top_th])
  difference(){
    cylinder(d=inlet_d + 2*inlet_ring_th, h=top_th, center=false);
    translate([0,0,-0.1]) cylinder(d=inlet_d, h=top_th+0.2, center=false);
  }

  // Outlet nozzle (external)
  translate([size_x/2, 0, base_th + outlet_h/2 + 2])
  difference(){
    cube([8.0, outlet_w+2.0, outlet_h+2.0], center=true);
    cube([9.0, outlet_w, outlet_h], center=true);
  }
}

module blade(){
  // A single curved blade made by twisting a thin rectangular prism
  translate([hub_d/2, -blade_th/2, 0])
    linear_extrude(height=blade_height, twist=blade_twist, slices=40, center=false)
      square([blade_len, blade_th], center=false);
}

module impeller(){
  // Simple impeller: hub + backplate + blades
  union(){
    // Backplate
    cylinder(d=impeller_d, h=1.2, center=false);

    // Hub
    translate([0,0,0])
      cylinder(d=hub_d, h=hub_h, center=false);

    // Blades
    for(i=[0:blade_count-1]){
      rotate([0,0, i*360/blade_count])
        translate([0,0,1.2])
          blade();
    }
  }
}

module assembly(){
  // Place impeller inside housing, centered under inlet
  union(){
    housing();

    // Impeller positioned inside cavity
    translate([0,0,base_th + 2.0])
      impeller();

    // Simple motor boss under impeller (inside base)
    translate([0,0,base_th-0.2])
      cylinder(d=10, h=2.2, center=false);
  }
}

assembly();