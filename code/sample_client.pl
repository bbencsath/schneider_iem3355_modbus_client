

 use Device::Modbus::RTU::Client;
 use warnings;
use Data::Dumper;


 my $client = Device::Modbus::RTU::Client->new(
     port     => '/dev/ttyUSB0',
     baudrate => 38400,
     parity   => 'even',
 );


sub read_string
 #where:as in the documentation
{
$where= shift;
$length = shift;

 my $req = $client->read_holding_registers(
     unit     => 3, #might be different for you!
     address  => $where-1, #although it is 30 in doc, it is 29 in reality
     quantity => $length,
 );

 $client->send_request($req);
 my $resp = $client->receive_response;
#printf(Dumper($resp));
my  $t=$resp->values;
$i=0;
$s="";


while ($i<$length)
 {
 $s.=chr($t->[$i]/256);
 $s.=chr($t->[$i]%256);
 $i++;
 }
#printf("$s\n");
return $s;


}



sub read_uint16
 #where:as in the documentation
{
$where= shift;

 my $req = $client->read_holding_registers(
     unit     => 3, #might be different for you!
     address  => $where-1, #although it is 30 in doc, it is 29 in reality
     quantity => 1,
 );

 $client->send_request($req);
 my $resp = $client->receive_response;
#printf(Dumper($resp));
my  $t=$resp->values;
return $t->[0];


}

sub read_float32
 #where:as in the documentation
{
$where= shift;

 my $req = $client->read_holding_registers(
     unit     => 3, #might be different for you!
     address  => $where-1, #although it is 30 in doc, it is 29 in reality
     quantity => 2,
 );

 $client->send_request($req);
 my $resp = $client->receive_response;
#printf(Dumper($resp));
my  $t=$resp->values;


my $word = ($t->[0] << 16) + ($t->[1]);
my $sign = ($word & 0x80000000) ? -1 : 1;
my $expo = (($word & 0x7F800000) >> 23) - 127;
my $mant = ($word & 0x007FFFFF | 0x00800000);
my $float = $sign * (2 ** $expo) * ( $mant / (1 << 23));
return $float


}



printf("name:".read_string(30,20)."\n");
printf("model:".read_string(50,20)."\n");
printf("manufacturer:".read_string(70,20)."\n");
printf("HW rev:".read_string(136,5)."\n");
printf("power system 2016:".read_uint16(2016)."\n"); #11 = 3PH4W
$voltage1=read_float32(3028);
$voltage2=read_float32(3030);
$voltage3=read_float32(3032);
printf("V1: $voltage1 V2: $voltage2 V3: $voltage3 \n");


 $client->disconnect;
