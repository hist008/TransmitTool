unit uSharedConfig;

interface

type

  {��������}
  RSharedConfig = record
    nID: Integer;
    strHost: string;      //IP��ַ
    strUserName: string; //�û���
    strPassWord: string; //����
    strDir: string;     //Ŀ¼
  end;


  {���������б�}
  RSharedConfigArray = array of RSharedConfig;


implementation

end.
