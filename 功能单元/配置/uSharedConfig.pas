unit uSharedConfig;

interface

type

  {共享配置}
  RSharedConfig = record
    nID: Integer;
    strHost: string;      //IP地址
    strUserName: string; //用户名
    strPassWord: string; //密码
    strDir: string;     //目录
  end;


  {共享配置列表}
  RSharedConfigArray = array of RSharedConfig;


implementation

end.
