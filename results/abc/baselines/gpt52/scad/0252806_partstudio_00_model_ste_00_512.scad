$fn=96;

plate_L = 100;
plate_W = 22;
plate_T = 2.2;

chamfer_L = 10;

boss_r = 10;
boss_T = plate_T;

hole_diamond_flat = 7.0;
hole_clear = 0.2;

text_str = "ASTRID";
text_size = 10.5;
text_height = 0.7;

logo_size = 6.0;
logo_height = 0.6;

module chamfered_plate(L, W, T, cL){
    linear_extrude(height=T, center=true)
        polygon(points=[
            [-L/2 + cL, -W/2],
            [ L/2 - cL, -W/2],
            [ L/2, 0],
            [ L/2 - cL,  W/2],
            [-L/2 + cL,  W/2],
            [-L/2, 0]
        ]);
}

module boss(r, T){
    cylinder(h=T, r=r, center=true);
}

module diamond_hole(flat, T){
    rotate([0,0,45])
        cube([flat, flat, T+2], center=true);
}

module logo_geom(size, h){
    linear_extrude(height=h, center=false)
        union(){
            polygon(points=[
                [0, size*0.55],
                [size*0.55, 0],
                [0, -size*0.55],
                [-size*0.55, 0]
            ]);
            translate([0,0])
                circle(r=size*0.18);
        }
}

module embossed_text(str, size, h){
    linear_extrude(height=h, center=false)
        text(str, size=size, font="Liberation Sans:style=Bold", halign="center", valign="center");
}

module tag(){
    boss_center_x = plate_L/2 - chamfer_L + boss_r*0.65;

    difference(){
        union(){
            chamfered_plate(plate_L, plate_W, plate_T, chamfer_L);
            translate([boss_center_x, 0, 0])
                boss(boss_r, boss_T);

            translate([0, 0, plate_T/2])
                embossed_text(text_str, text_size, text_height);

            translate([boss_center_x - boss_r*0.35, 0, plate_T/2])
                logo_geom(logo_size, logo_height);
        }

        translate([boss_center_x, 0, 0])
            diamond_hole(hole_diamond_flat + hole_clear, plate_T);
    }
}

tag();