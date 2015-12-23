#!/usr/bin/perl
# vim:set et ts=2 sw=2:

# Author : djluo
# version: 2.0(20150107)
#
# 初衷: 每个容器用不同用户运行程序,已方便在宿主中直观的查看.
# 需求: 1. 动态添加用户,不能将添加用户的动作写死到images中.
#       2. 容器内尽量不留无用进程,保持进程树干净.
# 问题: 如用shell的su命令切换,会遗留一个su本身的进程.
# 最终: 使用perl脚本进行添加和切换操作. 从环境变量User_Id获取用户信息.

use Cwd;
use strict;
#use English '-no_match_vars';

my $uid = 1000;
my $gid = 1000;
my $pwd = cwd();

$uid = $gid = $ENV{'User_Id'} if $ENV{'User_Id'} =~ /\d+/;

sub add_user {
  my ($name,$id)=@_;

  system("/usr/sbin/useradd",
    "-s", "/bin/false",
    "-d", "/var/empty/$name",
    "-U", "--uid", "$id",
    "$name");
}
unless (getpwuid("$uid")){
  add_user("docker", "$uid");
}
system("mkdir ./logs")        unless ( -d "./logs");
system("mkdir -m 750 ./data") unless ( -d "./data");

system("chown docker.docker -R ./data ./logs");

my $cfg = "/zookeeper/conf/zoo.cfg";
open(CFG,'>',$cfg) or die "open zoo.cfg error";
print CFG "tickTime=2000\n";
print CFG "initLimit=10\n";
print CFG "syncLimit=5\n";
print CFG "dataDir=$pwd/data\n";

my $port = "2181";
   $port = $ENV{'clientPort'} if $ENV{'clientPort'} =~ /\d+/;
print CFG "clientPort=$port\n";

if($ENV{'Servers'}){
  my $i=1;
  my $ID=0;
  my @ips=split(/,/, $ENV{'Servers'});

  foreach(@ips){
    print CFG "server.$i=$_\n";
    $ID = $i if("$ENV{'Current_Servers'}" eq "$_");
    $i++;
  }

  my $myid = "$pwd/data/myid";
  open(MYID,'>', $myid) or die "write myid error";
  print MYID "$ID\n";
  close(MYID);
}
close(CFG);

# 切换当前运行用户,先切GID.
#$GID = $EGID = $gid;
#$UID = $EUID = $uid;
$( = $) = $gid; die "switch gid error\n" if $gid != $( ;
$< = $> = $uid; die "switch uid error\n" if $uid != $< ;

exec(@ARGV);
