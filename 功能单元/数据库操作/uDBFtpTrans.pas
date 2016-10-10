unit uDBFtpTrans;

interface

uses
  SysUtils,uTFSystem,ADODB,uFtpConfig;

type
//==============================================================================
// FTP��־���ݿ������
// ����    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  TDBFtpLog = class(TDBOperate)
  public
    {����ɹ��ļ�¼}
    procedure AddSuccessLog(Ip,FileName:string;FileMd5:string;CreateTime:TDateTime);
    {����ʧ�ܵļ�¼}
    procedure AddFailerLog(Ip,FileName:string;FileMd5:string;CreateTime:TDateTime);
    {��ѯ�Ƿ���ڸü�¼ }
    function IsExist(Ip,FileMd5:string):Boolean;
    {�����־}
    procedure Clear();
  end;

//==============================================================================
// FTP�������ݿ������
// ����    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  TDBFtpTrans = class(TDBOperate)
  public
    class procedure GetFtpList(ADOConnection : TADOConnection;var FTPConfigArray:RFTPConfigArray);
    //��ȡ���е��б�
    procedure GetList(var FTPConfigArray:RFTPConfigArray);
    //��ѯ����
    function QueryById(ID:Integer;var ExFTPConfig:RExFTPConfig):Boolean;
    //����һ��
    function Insert(ExFTPConfig:RExFTPConfig):Boolean;
    //ɾ��һ��
    function Delete(ExFTPConfig:RExFTPConfig):Boolean;
    //�޸�һ��
    function Modify(ExFTPConfig:RExFTPConfig):Boolean;
    //����Ƿ����
    function IsExist(ID:Integer):Boolean;
  private
    procedure AdoToData(var ExFTPConfig:RExFTPConfig;ADOQuery:TADOQuery);
    procedure DataToAdo(ExFTPConfig:RExFTPConfig;ADOQuery:TADOQuery);
  end;


implementation

{ TDBFtp }

procedure TDBFtpLog.AddFailerLog(Ip, FileName, FileMd5: string;
  CreateTime: TDateTime);
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  adoQuery := NewADOQuery;
  try
    strSql := ' insert into tab_FtpUploadFailer_Log (strIp,strFileMd5,strFileName,dtCreateTime) values (:strIp,:strFileMd5,:strFileName,:dtCreateTime)';
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

procedure TDBFtpLog.AddSuccessLog(Ip,FileName,FileMd5: string; CreateTime: TDateTime);
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  adoQuery := NewADOQuery;
  try
    strSql := ' insert into tab_FtpUploadSuccess_Log (strIp,strFileMd5,strFileName,dtCreateTime) values (:strIp,:strFileMd5,:strFileName,:dtCreateTime)';
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

procedure TDBFtpLog.Clear;
var
  adoQuery : TADOQuery;
begin
  adoQuery := NewADOQuery ;
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      //ɾ������FTP��¼
      Sql.Text := 'delete from tab_FtpUploadFailer_Log';
      ExecSQL  ;

      //ɾ���ĳɹ�FTP��¼
      Sql.Text := 'delete from tab_FtpUploadSuccess_Log';
      ExecSQL  ;

    end;
  finally
    adoQuery.Free;
  end;
end;

function TDBFtpLog.IsExist(Ip,FileMd5: string): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string ;
begin
  Result := False ;
  adoQuery := NewADOQuery;
  try
    strSql := format('select strFileMd5 from tab_FtpUploadSuccess_Log where strIp = %s and strFileMd5 = %s ',[QuotedStr(Ip),QuotedStr(FileMd5)]);
    adoQuery.SQL.Text := strSql;
    adoQuery.Open;
    if adoQuery.RecordCount <= 0 then
      Exit ;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

{ TDBFtpTrans }

procedure TDBFtpTrans.AdoToData(var ExFTPConfig: RExFTPConfig; ADOQuery: TADOQuery);
begin
  ExFTPConfig.nID :=  ADOQuery.FieldByName('nID').AsInteger ;
  ExFTPConfig.FTPConfig.strHost := ADOQuery.FieldByName('FtpHostAddress').AsString ;
  ExFTPConfig.FTPConfig.nPort := ADOQuery.FieldByName('FtpPort').AsInteger ;
  ExFTPConfig.FTPConfig.strUserName := ADOQuery.FieldByName('FtpUserName').AsString ;
  ExFTPConfig.FTPConfig.strPassWord := ADOQuery.FieldByName('FtpPassWord').AsString ;
  ExFTPConfig.FTPConfig.strDir := ADOQuery.FieldByName('FtpSaveDir').AsString ;
end;

procedure TDBFtpTrans.DataToAdo(ExFTPConfig: RExFTPConfig; ADOQuery: TADOQuery);
begin
  ADOQuery.FieldByName('FtpHostAddress').AsString := ExFTPConfig.FTPConfig.strHost ;
  ADOQuery.FieldByName('FtpPort').AsInteger := ExFTPConfig.FTPConfig.nPort ;
  ADOQuery.FieldByName('FtpUserName').AsString := ExFTPConfig.FTPConfig.strUserName ;
  ADOQuery.FieldByName('FtpPassWord').AsString := ExFTPConfig.FTPConfig.strPassWord ;
  ADOQuery.FieldByName('FtpSaveDir').AsString := ExFTPConfig.FTPConfig.strDir ;
end;

function TDBFtpTrans.Delete(ExFTPConfig: RExFTPConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'delete from Tab_FtpTrans where nid = %d';
  strSql := Format(strSql,[ExFTPConfig.nID]);
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

class procedure TDBFtpTrans.GetFtpList(ADOConnection: TADOConnection;
  var FTPConfigArray: RFTPConfigArray);
var
  dbFtpTrans : TDBFtpTrans;
begin
  dbFtpTrans := TDBFtpTrans.Create(ADOConnection);
  try
    dbFtpTrans.GetList(FTPConfigArray);
  finally
    dbFtpTrans.Free;
  end;
end;

procedure TDBFtpTrans.GetList(var FTPConfigArray: RFTPConfigArray);
var
  adoQuery : TADOQuery;
  i : Integer ;
  strSql : string;
begin
  strSql := 'Select * from Tab_FtpTrans order by nid';
  i := 0 ;
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      SetLength(FTPConfigArray,adoQuery.RecordCount);
      while not adoQuery.eof do
      begin
        AdoToData(FTPConfigArray[i],adoQuery);
        Inc(i);
        adoQuery.Next ;
      end;
    end;
  finally
    adoQuery.Free;
  end;
end;

function TDBFtpTrans.Insert(ExFTPConfig: RExFTPConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'Select * from Tab_FtpTrans where 1 = 2';
  adoQuery := TADOQuery.Create(nil);
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      Append;
      DataToAdo(ExFTPConfig,ADOQuery);
      Post;
    end;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

function TDBFtpTrans.IsExist(ID: Integer): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  result := false;
  strSql := 'Select nid from Tab_FtpTrans where nid = %d';
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

function TDBFtpTrans.Modify(ExFTPConfig: RExFTPConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  strSql := 'Select * from Tab_FtpTrans where nid = %d';
  strSql := Format(strSql,[ExFTPConfig.nID]);
  adoQuery := NewADOQuery;
  try
    with adoQuery do
    begin
      Connection := m_ADOConnection;
      Sql.Text := strSql;
      Open;
      Edit;
      DataToAdo(ExFTPConfig,ADOQuery);
      Post;
    end;
    Result := True ;
  finally
    adoQuery.Free;
  end;
end;

function TDBFtpTrans.QueryById(ID: Integer; var ExFTPConfig: RExFTPConfig): Boolean;
var
  adoQuery : TADOQuery;
  strSql : string;
begin
  result := false;
  strSql := 'Select * from Tab_FtpTrans where nid = %d';
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
      AdoToData(ExFTPConfig,adoQuery);
      result := true;
    end;
  finally
    adoQuery.Free;
  end;
end;

end.
