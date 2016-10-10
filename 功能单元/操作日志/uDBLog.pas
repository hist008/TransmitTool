unit uDBLog;

interface

uses
  SysUtils,uTFSystem,ADODB,Contnrs;

type

//==============================================================================
// ���ݿ������־��
// ���������    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================

  //��־����
  TLogType = (ltFtpSuccess{FTP�ɹ�},
        ltFtpError{FTPʧ��},
        ltSharedSuccess{����ɹ�},
        ltSharedError{����ʧ��}) ;

  TLog = class
  private
    m_nID : Int64 ;
    m_strIp : string ;
    m_strFileMd5 : string ;
    m_strFileName : string ;
    m_dtCreateTime : TDateTime ;
  public
    property ID:Int64  read m_nID write m_nID;
    property Ip:string  read m_strIp write m_strIp;
    property FileMd5:string  read m_strFileMd5 write m_strFileMd5;
    property FileName:string  read m_strFileName write m_strFileName;
    property CreateTime:TDateTime  read m_dtCreateTime write m_dtCreateTime;
  end;

  TLogList = class(TObjectList)
  public
    function GetItem(Index: Integer): TLog;
    procedure SetItem(Index: Integer; AObject: TLog);
    function Add(AObject: TLog): Integer;
  public
    property Items[Index: Integer]: TLog read GetItem write SetItem; default;
  end;

//==============================================================================
// ���ݿ������־�� TDBLog
// author : lyq 2015-11-12
//==============================================================================

  TDBLog = class(TDBOperate)
  public
    //�������ں����Ͳ�ѯ����
    procedure QueryLog(StartDate,EndDate:TDateTime;LogType:TLogType;Ip,FileName:string;LogList:TLogList) ;
        {�����־}
    class procedure ClearDB(ADOConnection: TADOConnection);
  private
    //��ѯ
    procedure Query(StrTable:string;StartDate,EndDate:TDateTime;Ip,FileName:string;LogList:TLogList) ;
    procedure AdoToData(Log:TLog;ADOQuery:TADOQuery) ;
  end;



implementation

{ TLogList }

function TLogList.Add(AObject: TLog): Integer;
begin
  Result := inherited Add(AObject);
end;

function TLogList.GetItem(Index: Integer): TLog;
begin
  Result := TLog ( inherited GetItem(Index) ) ;
end;

procedure TLogList.SetItem(Index: Integer; AObject: TLog);
begin
  inherited SetItem(Index,AObject) ;
end;

{ TDBLog }

procedure TDBLog.AdoToData(Log: TLog; ADOQuery: TADOQuery);
begin
  with ADOQuery do
  begin
    Log.ID := FieldByName('nID').AsInteger ;
    Log.Ip := FieldByName('strIp').AsString ;
    Log.FileMd5 := FieldByName('strFileMd5').AsString ;
    Log.FileName := FieldByName('strFileName').AsString ;
    Log.CreateTime := FieldByName('dtCreateTime').AsDateTime ;
  end;
end;

class procedure TDBLog.ClearDB(ADOConnection: TADOConnection);
var
  adoQuery : TADOQuery;
begin
  adoQuery := TADOQuery.Create(nil) ;
  try
    with adoQuery do
    begin
      Connection := ADOConnection;
      //ɾ������FTP��¼
      Sql.Text := 'delete from tab_FtpUploadFailer_Log';
      ExecSQL  ;

      //ɾ���ĳɹ�FTP��¼
      Sql.Text := 'delete from tab_FtpUploadSuccess_Log';
      ExecSQL  ;


      //ɾ���������¼
      Sql.Text := 'delete from tab_SharedUploadFailer_Log';
      ExecSQL  ;

      //ɾ���ɹ��Ĺ����¼
      Sql.Text := 'delete from tab_SharedUploadSuccess_Log';
      ExecSQL  ;
    end;
  finally
    adoQuery.Free;
  end;
end;

procedure TDBLog.Query(StrTable: string; StartDate, EndDate: TDateTime; Ip,
  FileName: string; LogList: TLogList);
var
  adoQuery : TADOQuery;
  strSql : string ;
  Log : TLog ;
begin
  adoQuery := NewADOQuery;
  try
    strSql := StrTable + ' where ( dtCreateTime between :StartDate and :EndDate ) ' ;

    if Length(ip) <> 0 then
      strSql := strSql + ' and strIp = ' + QuotedStr(Ip);

    if Length(FileName) <> 0  then
      strSql := strSql + ' and strFileName = ' + QuotedStr(FileName);
    
    adoQuery.SQL.Text := strSql;
    adoQuery.Parameters.ParamByName('StartDate').Value := StartDate ;
    adoQuery.Parameters.ParamByName('EndDate').Value := EndDate ;
    adoQuery.Open;
    if adoQuery.RecordCount <= 0 then
      Exit ;
    while not adoQuery.Eof do
    begin
      Log := TLog.Create ;
      AdoToData(Log,adoQuery);
      LogList.Add(Log);
      adoQuery.Next ;
    end;
  finally
    adoQuery.Free;
  end;
end;



procedure TDBLog.QueryLog(StartDate, EndDate: TDateTime; LogType: TLogType;
  Ip,FileName: string; LogList: TLogList);
var
  strTable:string;
  strSql:string ;
begin
  case LogType of
    ltFtpSuccess: strTable := 'tab_FtpUploadSuccess_Log' ;
    ltFtpError: strTable := 'tab_FtpUploadFailer_Log'  ;
    ltSharedSuccess: strTable := 'tab_SharedUploadSuccess_Log' ;
    ltSharedError: strTable := 'tab_SharedUploadFailer_Log'  ;
  end;
  strSql := Format('select * from %s ',[strTable]);
  Query(strSql,StartDate, EndDate,Ip,FileName,LogList);
end;



end.
