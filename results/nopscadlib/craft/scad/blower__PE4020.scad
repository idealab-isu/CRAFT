// Centrifugal blower fan (single connected solid), 40 x 40 x 20 mm overall
$fn = 96;

// Parameters
overall_width = 40; //[20:80:1]
overall_length = 40; //[20:80:1]
overall_depth = 20; //[10:40:1]

wall_thickness = 2; //[1:4:0.5]
base_plate_thickness = 2; //[1:4:0.5]
top_cover_thickness = 2; //[1:4:0.5]
internal_clearance = 0.6; //[0.2:1.5:0.1]

inlet_bore_diameter = 18; //[10:30:1]

outlet_width = 14; //[8:24:1]
outlet_height = 10; //[6:18:1]
outlet_length = 10; //[5:25:1]
outlet_wall = 2; //[1:4:0.5]

impeller_outer_diameter = 30; //[18:38:1]
impeller_height = 12; //[6:16:1]
hub_diameter = 10; //[6:18:1]
hub_height = 14; //[8:18:1]
blade_count = 20; //[10:40:1]
blade_thickness = 1; //[0.6:2:0.1]

mount_hole_diameter = 3.2; //[2:5:0.1]
mount_boss_diameter = 7; //[5:12:0.5]
mount_edge_offset = 5; //[3:10:0.5]

connect_overlap = 1; //[0.5:2:0.1]

// Derived
W = overall_width;
L = overall_length;
H = overall_depth;

inner_W = W - 2*wall_thickness;
inner_L = L - 2*wall_thickness;
inner_H = H - base_plate_thickness - top_cover_thickness;

z_inner_center = (top_cover_thickness - base_plate_thickness)/2;

// Impeller placement (inside cavity)
z_imp_center = -H/2 + base_plate_thickness + impeller_height/2 + internal_clearance;

// Volute (scroll) parameters (2D, extruded)
volute_outer_r = min(inner_W, inner_L)/2 - internal_clearance;
volute_inner_r = max(hub_diameter/2 + 2, impeller_outer_diameter/2 + internal_clearance);
volute_thickness = max(1.2, wall_thickness); // internal divider thickness

// Outlet placement (tangential, on +Y side)
outlet_outer_x = outlet_width + 2*outlet_wall;
outlet_outer_y = outlet_length;
outlet_outer_z = outlet_height + 2*outlet_wall;

outlet_center = [
    0,
    L/2 + outlet_outer_y/2 - connect_overlap,
    0
];

// Mount bosses (kept within 40x40 footprint)
boss_z = -H/2 + base_plate_thickness/2;
boss_xy = W/2 - mount_edge_offset;

// 2D volute wall: a ring sector with increasing outer radius (simple scroll approximation)
module volute_wall_2d(r_in, r_out_min, r_out_max, a0=20, a1=330) {
    // Outer radius increases with angle to mimic a scroll
    // Use a polygon for outer boundary and an arc for inner boundary.
    steps = 120;
    outer_pts = [
        for (i = [0:steps])
            let(a = a0 + (a1-a0)*i/steps)
            let(t = i/steps)
            let(r = r_out_min + (r_out_max - r_out_min)*t)
            [r*cos(a), r*sin(a)]
    ];
    inner_pts = [
        for (i = [steps:-1:0])
            let(a = a0 + (a1-a0)*i/steps)
            [r_in*cos(a), r_in*sin(a)]
    ];
    polygon(concat(outer_pts, inner_pts));
}

// Impeller (simple backward-curved blades) as solid (not subtractive)
module impeller() {
    union() {
        // Hub
        translate([0,0,z_imp_center])
            cylinder(d=hub_diameter, h=impeller_height, center=true, $fn=48);

        // Shroud disk (thin) to visually read as centrifugal impeller
        translate([0,0,z_imp_center + impeller_height/2 - blade_thickness/2])
            cylinder(d=impeller_outer_diameter, h=blade_thickness, center=true, $fn=96);

        // Blades: radial array, protruding outward from near hub to near outer diameter
        blade_len = impeller_outer_diameter/2 - (hub_diameter/2 + 1.5);
        blade_w = max(2.2, blade_thickness*2.2);
        blade_h = impeller_height - 2*blade_thickness;

        for (i = [0:blade_count-1]) {
            ang = i*360/blade_count;
            // Backward-curved: rotate blade slightly opposite rotation direction
            rotate([0,0,ang - 25])
                translate([hub_diameter/2 + blade_len/2 + 0.5, 0, z_imp_center])
                    // slight tilt for 3D interest
                    rotate([0, -8, 0])
                        cube([blade_len, blade_w, blade_h], center=true);
        }
    }
}

// Main blower body: outer shell + internal cavity + inlet + outlet + internal volute wall
module blower_body() {
    difference() {
        // OUTER SOLID (includes outlet block and bosses so everything is one connected solid)
        union() {
            // Outer casing block
            cube([W, L, H], center=true);

            // Outlet outer block (tangential)
            translate(outlet_center)
                cube([outlet_outer_x, outlet_outer_y, outlet_outer_z], center=true);

            // Mount bosses (4)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*boss_xy, sy*boss_xy, boss_z])
                    cylinder(d=mount_boss_diameter, h=base_plate_thickness + 2*connect_overlap, center=true, $fn=48);
            }

            // Internal volute wall (solid divider inside cavity)
            // Positioned within inner cavity, extruded through most of cavity height
            translate([0,0,z_inner_center])
                linear_extrude(height=inner_H - 2*internal_clearance, center=true)
                    volute_wall_2d(
                        r_in = volute_inner_r,
                        r_out_min = volute_inner_r + volute_thickness,
                        r_out_max = volute_outer_r
                    );
        }

        // SUBTRACT: inner cavity (hollow)
        translate([0, 0, z_inner_center])
            cube([inner_W, inner_L, inner_H], center=true);

        // SUBTRACT: inlet bore through top cover into cavity
        translate([0, 0, H/2 - top_cover_thickness/2])
            cylinder(d=inlet_bore_diameter, h=top_cover_thickness + 2*connect_overlap, center=true, $fn=96);

        // SUBTRACT: outlet duct opening (through outlet block into cavity)
        // Make sure it intersects the inner cavity by extending slightly inward.
        translate([0, L/2 + outlet_length/2 - connect_overlap, 0])
            cube([outlet_width, outlet_length + 2*connect_overlap, outlet_height], center=true);

        // SUBTRACT: mount holes through bosses and base
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*boss_xy, sy*boss_xy, -H/2 + (base_plate_thickness/2)])
                cylinder(d=mount_hole_diameter, h=base_plate_thickness + 4*connect_overlap, center=true, $fn=48);
        }
    }
}

// Assembly: ensure ONE connected solid by unioning impeller with body (impeller sits inside cavity)
module assembly() {
    union() {
        blower_body();
        impeller();
    }
}

assembly();