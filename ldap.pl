use IO::Socket::INET;
my $s=IO::Socket::INET->new(PeerAddr=>"10.36.34.54:389",Timeout=>3) or die "F";
$s->send("\x30\x0c\x02\x01\x01\x60\x07\x02\x01\x03\x04\x00\x80\x00");
my $r;$s->recv($r,1024);
my @b=unpack("C*",$r);
if($b[7]==0){print "ANON_BIND_OK\n"}else{print "ANON_BIND_FAIL:$b[7]\n"}
$s->send("\x30\x25\x02\x01\x02\x63\x20\x04\x00\x0a\x01\x00\x0a\x01\x00\x02\x01\x00\x02\x01\x00\x01\x01\x00\x87\x0b\x6f\x62\x6a\x65\x63\x74\x43\x6c\x61\x73\x73\x30\x00");
$s->recv($r,8192);
my $txt=$r;$txt=~s/[^\x20-\x7e]/./g;
print substr($txt,0,500)."\n";
printf("RESP:%d\n",length($r));
