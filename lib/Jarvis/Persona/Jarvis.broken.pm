package Jarvis::Persona::Jarvis;
use parent Jarvis::Persona::Base;

################################################################################
# Jarvis is Just A Really Vigilant Infrastructure Sysadmin.
# most of what he does will be done with an alarm() or delay()
################################################################################
sub may {
    my $self = shift;
    return { 
             'ldap_uri'        => undef,
             'ldap_binddn'     => undef,
             'ldap_bindpw'     => undef,
             'trace'           => 1,
             'log_dir'         => '/var/log/irc',
           };
}

sub persona_start{
    my ($self, $kernel, $heap, $sender, @args) = @_[OBJECT, KERNEL, HEAP, SENDER, ARG0 .. $#_];
    return $self;
}

sub stop{
    my ($self, $kernel, $heap, $sender, @args) = @_[OBJECT, KERNEL, HEAP, SENDER, ARG0 .. $#_];
    return $self;
}

################################################################################
# the messages get routed here from the connectors, a reply is formed, and 
# posted back to the sender_alias,reply event (this function will need to be
# overloaded...
################################################################################
sub input{
    my ($self, $kernel, $heap, $sender, $msg) = @_[OBJECT, KERNEL, HEAP, SENDER, ARG0];
    # un-wrap the $msg
    my ( $sender_alias, $respond_event, $who, $where, $what, $id ) =
       (
         $msg->{'sender_alias'},
         $msg->{'reply_event'},
         $msg->{'conversation'}->{'nick'},
         $msg->{'conversation'}->{'room'},
         $msg->{'conversation'}->{'body'},
         $msg->{'conversation'}->{'id'},
       );
    my $direct=$msg->{'conversation'}->{'direct'}||0;
    if(defined($what)){
        if(defined($heap->{'locations'}->{$sender_alias}->{$where})){
            foreach my $chan_nick (@{ $heap->{'locations'}->{$sender_alias}->{$where} }){
                if($what=~m/^\s*$chan_nick\s*:*\s*/){
                    $what=~s/^\s*$chan_nick\s*:*\s*//;
                    $direct=1;
                }
            }
        }
        my $replies=[];
        ########################################################################
        #                                                                      #
        ########################################################################
        for ( $what ) {
            /^\s*!*help\s*/ && do { $replies = [ "i need a help routine" ] if($direct); last; };
            /.*/            && do { $replies = [ "i don't understand"    ] if($direct); last; };
            /.*/            && do { last; }
        }
        ########################################################################
        #                                                                      #
        ########################################################################
        if($direct==1){
            foreach my $line (@{ $replies }){
                if($msg->{'conversation'}->{'direct'} == 0){
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $who.': '.$line); }
                }else{
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $line); }
                }
            }
        }else{
            foreach my $line (@{ $replies }){
                    if( defined($line) && ($line ne "") ){ $kernel->post($sender, $respond_event, $msg, $line); }
            }
        }
    }
    return $self->{'alias'};
}

1;