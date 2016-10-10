unit uDBSharedTrans;

interface


uses
  SysUtils,uTFSystem,ADODB,uSharedConfig;

type
//==============================================================================
// ���������ݿ������
// ����    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  TDBSharedLog = class(TDBOperate)
  public
    {����ɹ��ļ�¼}
    procedure AddSuccessLog(Ip,FileName:string;FileMd5:string;CreateTime:TDateTime);
    {����ʧ�ܵļ�¼}
    procedure AddFailerLog(Ip,FileName:string;FileMd5:string;CreateTime:TDateTime);
    {��ѯ�Ƿ���ڸü�¼ }
    function IsExist(Ip,FileMd5:string):Boolean;
    {���}
    procedure Clear();
  end;
//==============================================================================
// ���������ݿ������
// ����    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  TDBSharedTrans = class(TDBOperate)
  public
    class procedure GetSharedList(ADOConnection : TADOConnection;var SharedConfigArray:RSharedConfigArray);
    //��ȡ���е��б�
    procedure GetList(var SharedConfigArray:RSharedConfigArray);
    //��ѯ����
    function QueryById(ID:Integer;var SharedConfig:RSharedConfig):Boolean;
    //����һ��
    function Insert(SharedConfig:RSharedConfig):Boolean;
    //ɾ��һ��
    function Delete(SharedConfig:RSharedConfig):Boolean;
    //�޸�һ��
    function Modify(SharedConfig:RSharedConfig):Boolean;
    //����Ƿ����
    function IsExist(ID:Integer):Boolean;
  private
    procedure AdoToData(var SharedConfig:RSharedConfig;ADOQuery:TADOQuery);
    procedure DataToAdo(SharedConfig:RSharedConfig;ADOQuery:TADOQuery);
  end;

implementation

{ TDBFtpTrans }

procedure TDBSharedTrans.AdoToData(var SharedConfig: RSharedConfig;
  ADOQuery: TADOQuery);
begin
  with SharedConfig do
  begin
    nID :=  ADOQuery.FieldByName('nID').AsInteger ;
    strHost := ADOQuery.FieldByName('HostAddress').AsString ;
    strUserName := ADOQuery.FieldByName('UserName').AsString ;
    strPassWord := ADOQuery.FieldByName('PassWord').AsString ;
    strDir := ADOQuery.FieldByName('SaveDir').AsString ;
  end;
end;

procedure TDBSharedTrans.DataToAdo(SharedConfig: RSharedConfig;
  ADOQuery: TADOQuery);
begin
  with SharedConfig do
  begin
    //ADOQuery.FieldByName('nID').AsInteger := nID ;
    ADOQuery.FieldByName('HostAddress').AsString := strHost  ;
    ADOQuery.FieldByName('UserName').AsString := strUserName ;
    ADOQuery.FieldByName('PassWord').AsString := strPassWord ;
    ADOQuery.FieldByName('SaveDir').AsString := strDir ;
  end;
end;

function TDBSharedTrans.Delete(SharedConfig: RSharedConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'delete from Tab_SharedTrans where nid = %d';
  strSql := Format(strSql,[SharedConfig.nID]);
  adoQuery := NewADOQuery ;
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      if ExecSQL > 0 then;
        Result:= True ;
    end;
  finally
    adoQuery.Free;
  end;
end;

class procedure TDBSharedTrans.GetSharedList(ADOConnection: TADOConnection;
  var SharedConfigArray: RSharedConfigArray);
var
  dbSharedTrans : TDBSharedTrans;
begin
  dbSharedTrans := TDBSharedTrans.Create(ADOConnection);
  try
    dbSharedTrans.GetList(SharedConfigArray);
  finally
    dbSharedTrans.Free;
  end;
end;

procedure TDBSharedTrans.GetList(var SharedConfigArray: RSharedConfigArray);
var
  adoQuery : TADOQuery;
  i : Integer ;
  strSql : string;
begin
  strSql := 'Select * from Tab_SharedTrans order by nid';
  i := 0 ;
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      SetLength(SharedConfigArray,adoQuery.RecordCount);
      while not adoQuery.eof do
      begin
        AdoToData(SharedConfigArray[i],adoQuery);
        Inc(i);
        adoQuery.Next ;
      end;
    end;
  finally
    adoQuery.Free;
  end;
end;

function TDBSharedTrans.Insert(SharedConfig: RSharedConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'Select * from Tab_SharedTrans where 1 = 2';
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      Append;
      DataToAdo(SharedConfig,ADOQuery);
      Post;
    end;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

function TDBSharedTrans.IsExist(ID: Integer): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  result := false;
  strSql := 'Select nid from Tab_SharedTrans where nid = %d';
  strSql := Format(strSql,[ID]);
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      if RecordCount = 0 then
        exit;
      result := true;
    end;
  finally
    adoQuery.Free;
  end;
end;

function TDBSharedTrans.Modify(SharedConfig: RSharedConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'Select * from Tab_SharedTrans where nid = %d';
  strSql := Format(strSql,[SharedConfig.nID]);
  adoQuery := NewADOQuery;
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      Edit;
      DataToAdo(SharedConfig,ADOQuery);
      Post;
    end;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

function TDBSharedTrans.QueryById(ID: Integer;
  var SharedConfig: RSharedConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  result := false;
  strSql := 'Select * from Tab_SharedTrans where nid = %d';
  strSql := Format(strSql,[ID]);
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      if RecordCount = 0 then
        exit;
      AdoToData(SharedConfig,adoQuery);
      result := true;
    end;
  finally
    adoQuery.Free;
  end;
end;

{ TDBSharedLog }

procedure TDBSharedLog.AddFailerLog(Ip, FileName, FileMd5: string;
  CreateTime: TDateTime);
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  adoQuery := NewADOQuery;
  try
    strSql := ' insert into tab_SharedUploadFailer_Log (strIp,strFileMd5,strFileName,dtCreateTime) values (:strIp,:strFileMd5,:strFileName,:dtCreateTime)';
    adoQuery.SQL.Text := strSql;
    adoQuery.Parameters.ParamByName('strIp').Value := Ip ;
    adoQuery.Parameters.ParamByName('strFileMd5').Value := FileMd5 ;
    adoQuery.Parameters.ParamByName('strFileName').Value := FileName ;
    adoQuery.Parameters.ParamByName('dtCreateTime').Value := CreateTime ;
    if adoQuery.ExecSQL < 0 then
      Exit;
  finally
    adoQuery.Free;
  end;
end;

procedure TDBSharedLog.AddSuccessLog(Ip, FileName, FileMd5: string;
  CreateTime: TDateTime);
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  adoQuery := NewADOQuery;
  try
    strSql := ' insert into tab_SharedUploadSuccess_Log (strIp,strFileMd5,strFileName,dtCreateTime) values (:strIp,:strFileMd5,:strFileName,:dtCreateTime)';
    adoQuery.SQL.Text := strSql;
    adoQuery.Parameters.ParamByName('strIp').Value := Ip ;
    adoQuery.Parameters.ParamByName('strFileMd5').Value := FileMd5 ;
    adoQuery.Parameters.ParamByName('strFileName').Value := FileName ;
    adoQuery.Parameters.ParamByName('dtCreateTime').Value := CreateTime ;
    if adoQuery.ExecSQL < 0 then
      Exit;
  finally
    adoQuery.Free;
  end;
end;

procedure TDBSharedLog.Clear;
var
  adoQuery : TADOQuery;
begin
  adoQuery := NewADOQuery ;
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      //ɾ������FTP��¼
      Sql.Text := 'delete from tab_SharedUploadFailer_Log';
      ExecSQL  ;

      //ɾ���ɹ���FTP��¼
      Sql.Text := 'delete from tab_SharedUploadSuccess_Log';
      ExecSQL  ;

    end;
  finally
    adoQuery.Free;
  end;
end;

function TDBSharedLog.IsExist(Ip, FileMd5: string): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  Result := False ;
  adoQuery := NewADOQuery;
  try
    strSql := format('select strFileMd5 from tab_SharedUploadSuccess_Log where strIp = %s and strFileMd5 = %s ',[QuotedStr(Ip),QuotedStr(FileMd5)]);
    adoQuery.SQL.Text := strSql;
    adoQuery.Open;
    if adoQuery.RecordCount <= 0 then
      Exit ;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

end.
