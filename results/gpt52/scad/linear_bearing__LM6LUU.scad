$fn=96;

bore_d = 6.0;
od_d = 12.0;
len = 35.0;

module linear_bearing(bore_d, od_d, len){
    difference(){
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.2, center=true);
    }
}

linear_bearing(bore_d, od_d, len);