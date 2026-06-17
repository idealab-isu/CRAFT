$fn=96;

module hex_prism(flat_d, h, center=true){
    r = flat_d / sqrt(3);
    cylinder(h=h, r=r, $fn=6, center=center);
}

module faceted_cylinder(h, r, facets=12, center=true){
    cylinder(h=h, r=r, $fn=facets, center=center);
}

module tool_body(){
    // Dimensions (mm)
    L = 60;
    r_main = 9.5;
    facets = 14;

    collar_len = 10;
    collar_r = 11.0;

    dome_len = 12;
    dome_r = 10.5;

    // Bores
    center_hex_flat = 8.0;
    outer_hex_flat = 4.0;
    outer_count = 6;
    outer_radius = 6.2;

    union(){
        // Main faceted body
        translate([0,0,0])
            faceted_cylinder(h=L, r=r_main, facets=facets, center=true);

        // Stepped collar near one end (negative Z end)
        translate([0,0,-L/2 + collar_len/2])
            faceted_cylinder(h=collar_len, r=collar_r, facets=facets, center=true);

        // Domed/capped end on positive Z end
        translate([0,0, L/2 - dome_len])
            union(){
                // short faceted transition
                translate([0,0,dome_len*0.35])
                    faceted_cylinder(h=dome_len*0.7, r=dome_r, facets=facets, center=false);
                // dome
                translate([0,0,dome_len*0.7])
                    scale([1,1,0.85])
                        sphere(r=dome_r);
            }
    }
}

module bores(){
    L = 60;
    extra = 2;

    center_hex_flat = 8.0;
    outer_hex_flat = 4.0;
    outer_count = 6;
    outer_radius = 6.2;

    // Central through-bore
    hex_prism(center_hex_flat, L + 2*extra, center=true);

    // Multiple smaller hex through-holes arranged around on one end face (negative Z end)
    for(i=[0:outer_count-1]){
        ang = 360/outer_count * i;
        translate([outer_radius*cos(ang), outer_radius*sin(ang), 0])
            hex_prism(outer_hex_flat, L + 2*extra, center=true);
    }
}

difference(){
    tool_body();
    bores();
}