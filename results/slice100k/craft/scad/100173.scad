// Parameters
bbox_x = 70.55; //[35.28:141.1:0.01]
bbox_y = 65.21; //[32.6:130.42:0.01]
bbox_z = 70.37; //[35.19:140.74:0.01]
base_radius = 34.0; //[17.0:68.0:0.1]
facet_count = 120; //[40:240:1]
facet_size_min = 4.0; //[2.0:8.0:0.1]
facet_size_max = 14.0; //[7.0:28.0:0.1]
seed = 1; //[1:9999:1]
scale_x = 1.0; //[0.5:2.0:0.01]
scale_y = 1.0; //[0.5:2.0:0.01]
scale_z = 1.0; //[0.5:2.0:0.01]
ovoid_sx = 0.98; //[0.7:1.3:0.01]
ovoid_sy = 0.92; //[0.7:1.3:0.01]
ovoid_sz = 1.02; //[0.7:1.3:0.01]
point_r = 34.0; //[17.0:68.0:0.1]
micro_bevel_r = 0.6; //[0.2:1.5:0.05]
base_flatten_depth = 6.0; //[2.0:14.0:0.1]
base_flatten_margin = 2.0; //[0.5:6.0:0.1]
connect_overlap = 1.0; //[0.5:2.0:0.1]

// Base shapes
module facet_density_control() {
  sphere(r=base_radius, center=true);
}

module point_sphere(x, y, z) {
  translate([x, y, z])
    sphere(r=facet_size_min/2, center=true);
}

module subtle_asymmetry_noise() {
  translate([point_r*0.18, -point_r*0.12, point_r*0.08])
    sphere(r=facet_size_max/2, center=true);
}

module edge_chamfer_or_micro_bevel() {
  sphere(r=micro_bevel_r, center=true);
}

module base_flattening_patch() {
  translate([0, 0, -(bbox_z/2) + (base_flatten_depth/2)])
    cube([bbox_x + 2*base_flatten_margin, bbox_y + 2*base_flatten_margin, base_flatten_depth], center=true);
}

// Operations
module hull_points_raw() {
  hull() {
    point_sphere(point_r*0.95, point_r*0.05, point_r*0.10);
    point_sphere(point_r*0.70, point_r*0.55, point_r*0.25);
    point_sphere(point_r*0.35, point_r*0.85, point_r*0.15);
    point_sphere(point_r*0.05, point_r*0.95, point_r*0.05);
    point_sphere(-point_r*0.25, point_r*0.90, point_r*0.20);
    point_sphere(-point_r*0.55, point_r*0.70, point_r*0.30);
    point_sphere(-point_r*0.85, point_r*0.35, point_r*0.15);
    point_sphere(-point_r*0.95, point_r*0.05, point_r*0.10);
    point_sphere(-point_r*0.90, -point_r*0.25, point_r*0.20);
    point_sphere(-point_r*0.70, -point_r*0.55, point_r*0.25);
    point_sphere(-point_r*0.35, -point_r*0.85, point_r*0.15);
    point_sphere(-point_r*0.05, -point_r*0.95, point_r*0.05);
    point_sphere(point_r*0.25, -point_r*0.90, point_r*0.20);
    point_sphere(point_r*0.55, -point_r*0.70, point_r*0.30);
    point_sphere(point_r*0.85, -point_r*0.35, point_r*0.15);
    point_sphere(point_r*0.95, -point_r*0.05, point_r*0.10);
    point_sphere(point_r*0.70, point_r*0.10, point_r*0.70);
    point_sphere(point_r*0.25, point_r*0.55, point_r*0.80);
    point_sphere(-point_r*0.25, point_r*0.55, point_r*0.85);
    point_sphere(-point_r*0.70, point_r*0.10, point_r*0.75);
    point_sphere(-point_r*0.55, -point_r*0.35, point_r*0.80);
    point_sphere(-point_r*0.10, -point_r*0.70, point_r*0.75);
    point_sphere(point_r*0.35, -point_r*0.55, point_r*0.80);
    point_sphere(point_r*0.55, -point_r*0.10, point_r*0.85);
    point_sphere(point_r*0.70, point_r*0.10, -point_r*0.70);
    point_sphere(point_r*0.25, point_r*0.55, -point_r*0.80);
    point_sphere(-point_r*0.25, point_r*0.55, -point_r*0.85);
    point_sphere(-point_r*0.70, point_r*0.10, -point_r*0.75);
    point_sphere(-point_r*0.55, -point_r*0.35, -point_r*0.80);
    point_sphere(-point_r*0.10, -point_r*0.70, -point_r*0.75);
    point_sphere(point_r*0.35, -point_r*0.55, -point_r*0.80);
    point_sphere(point_r*0.55, -point_r*0.10, -point_r*0.85);
  }
}

module hull_points_ovoid() {
  scale([ovoid_sx, ovoid_sy, ovoid_sz])
    hull_points_raw();
}

module hull_points_asym() {
  union() {
    hull_points_ovoid();
    subtle_asymmetry_noise();
  }
}

module faceted_main_solid() {
  intersection() {
    hull_points_asym();
    facet_density_control();
  }
}

module micro_bevel_applied() {
  minkowski() {
    faceted_main_solid();
    edge_chamfer_or_micro_bevel();
  }
}

module flattened_solid() {
  difference() {
    micro_bevel_applied();
    base_flattening_patch();
  }
}

module global_nonuniform_scale_to_bbox() {
  scale([(bbox_x/(2*base_radius))*scale_x, (bbox_y/(2*base_radius))*scale_y, (bbox_z/(2*base_radius))*scale_z])
    flattened_solid();
}

// Final output
global_nonuniform_scale_to_bbox();