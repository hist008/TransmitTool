unit uFtpConfig;

interface

uses
  uTFSystem;

type


   RExFTPConfig = record
     nID:Integer ;
     FTPConfig : RFTPConfig ;
   end;

    {FTP�����б�}
   RFTPConfigArray =  array of RExFTPConfig  ;


implementation

end.
