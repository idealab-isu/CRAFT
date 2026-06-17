$fn=96;

shaft_d = 4.0;
head_d  = 7.0;
head_h  = 2.4;
len     = 10.0;

module screw(shaft_d, head_d, head_h, len){
    union(){
        // Shaft
        cylinder(h=len, d=shaft_d);

        // Head (simple cylindrical head)
        translate([0,0,len])
            cylinder(h=head_h, d=head_d);
    }
}

screw(shaft_d, head_d, head_h, len);