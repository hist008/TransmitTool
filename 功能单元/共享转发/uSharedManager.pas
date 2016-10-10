unit uSharedManager;

interface

uses
  uTransManager,uSharedConfig,uSharedOper,uDBSharedTrans,ADODB,SysUtils,uMd5;

type
//==============================================================================
// 共享管理类 TSharedManager
// 共享操作类    author lyq
// 修改时间      date : 2015-11-13
//==============================================================================
  TSharedManager = class(TTransBaseManager)
  public
    constructor Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
    destructor Destroy();override;
  protected
    //上传文件
    function UploadFile(FileName:string):Boolean;override;
    //是否上传过
    function  IsUploaded(FileName:string):Boolean;override;
    //插入Shared成功日志
    procedure InsertSuccessDBLog(FileName:string);override;
    //插入Shared失败日志
    procedure InsertErrorDBLog(FileName:string);override;
  private
    //数据库操作记录
    m_dbSharedLog : TDBSharedLog ;
    //共享操作类
    m_SharedOper : TSharedOper ;
    //共享配置
    m_SharedConfig : RSharedConfig ;
  public
    property  SharedConfig:RSharedConfig read m_SharedConfig write m_SharedConfig ;
  end;


implementation

{ TSharedManager }


constructor TSharedManager.Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
begin
  m_dbSharedLog := TDBSharedLog.Create(ADOConnection);
  m_SharedOper := TSharedOper.Create;
  m_SharedOper.LogEvent := LogEvent ;
  inherited Create(ADOConnection,LogEvent);
end;

destructor TSharedManager.Destroy;
begin
  m_dbSharedLog.Free ;
  m_SharedOper.Free ;
  inherited;
end;

procedure TSharedManager.InsertErrorDBLog(FileName: string);
var
  strMd5 : string ;
  strIp : string ;
begin
  strMd5 := RivestFile(FileName) ;
  strIp := m_SharedOper.SharedConfig.strHost ;
  m_dbSharedLog.AddFailerLog(strIp, FileName,strMd5,Now);
end;

procedure TSharedManager.InsertSuccessDBLog(FileName: string);
var
  strMd5 : string ;
  strIp : string ;
begin
  strIp := m_SharedOper.SharedConfig.strHost ;
  strMd5 := RivestFile(FileName) ;
  m_dbSharedLog.AddSuccessLog(strIp , FileName,strMd5,Now);
end;

function TSharedManager.IsUploaded(FileName: string): Boolean;
var
  strFileMd5 : string ;
  strIp : string ;
begin
  strFileMd5 := RivestFile(FileName)  ;
  if strFileMd5 = '' then
  begin
    raise Exception.Create('文件的MD5为空,请检查!');
    exit ;
  end;
  strIp := m_SharedConfig.strHost ;
  Result := m_dbSharedLog.IsExist(strIP,strFileMd5) ;
end;

function TSharedManager.UploadFile(FileName: string): Boolean;
begin
  Result := False ;
  m_SharedOper.SharedConfig := m_SharedConfig ;
  //连接
  if not m_SharedOper.IsConnect() then
  begin
    if not m_SharedOper.Connect() then
    begin
      //如果连接失败则加入数据库日志
      //InsertErrorDBLog(FileName);
      Exit;
    end;
  end;

  //上传文件并记录结果
  if m_SharedOper.UploadFile( FileName ) then
    InsertSuccessDBLog(FileName)
  else
    InsertErrorDBLog(FileName);
end;

end.
