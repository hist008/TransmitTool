unit uFtpManager;

interface
uses
  uTransManager,uFtpConfig,uFtpOper,uDBFtpTrans,ADODB,SysUtils,uMd5;

type

//==============================================================================
// ���������    TFtpManager
// ���������    author lyq
// �޸�ʱ��      date : 2015-11-13
//==============================================================================
  TFtpManager = class(TTransBaseManager)
  public
    constructor Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
    destructor Destroy();override;
  protected
    //�ϴ��ļ�
    function UploadFile(FileName:string):Boolean;override;
    //�Ƿ��ϴ���
    function  IsUploaded(FileName:string):Boolean;override;
    //����Shared�ɹ���־
    procedure InsertSuccessDBLog(FileName:string);override;
    //����Sharedʧ����־
    procedure InsertErrorDBLog(FileName:string);override;
  private
    //���ݿ������¼
    m_dbFtpLog : TDBFtpLog ;
    //���������
    m_FtpOper : TFtpOper ;
    //FTP����
    m_FTPConfig : RExFTPConfig ;
  public
    property  FTPConfig:RExFTPConfig read m_FTPConfig write m_FTPConfig ;
  end;
  
implementation

{ TFtpManager }


constructor TFtpManager.Create(ADOConnection: TADOConnection;
  LogEvent: TLogEvent);
begin
  m_dbFtpLog := TDBFtpLog.Create(ADOConnection);
  m_FtpOper := TFtpOper.Create;
  m_FtpOper.DBSuccessLogEvent := InsertSuccessDBLog ;
  m_FtpOper.DBErrorLogEvent :=  InsertErrorDBLog ;
  m_FtpOper.LogEvent := LogEvent ;
  inherited Create(ADOConnection,LogEvent);
end;

destructor TFtpManager.Destroy;
begin
  m_dbFtpLog.Free ;
  m_FtpOper.Free ;
  inherited;
end;

procedure TFtpManager.InsertErrorDBLog(FileName: string);
var
  strMd5 : string ;
  strIp  : string ;
begin

  strIp := m_FTPConfig.FTPConfig.strHost ;
  strMd5 := RivestFile(FileName) ;
  m_dbFtpLog.AddFailerLog(strIp, FileName,strMd5,Now);
end;

procedure TFtpManager.InsertSuccessDBLog(FileName: string);
var
  strMd5 : string ;
  strIp  : string ;
begin
  strIp := m_FTPConfig.FTPConfig.strHost ;
  strMd5 := RivestFile(FileName) ;
  m_dbFtpLog.AddSuccessLog(strIp , FileName,strMd5 ,Now);
end;

function TFtpManager.IsUploaded(FileName: string): Boolean;
var
  strFileMd5 : string ;
  strIp      : string ;
begin
  strFileMd5 := RivestFile(FileName)  ;
  if strFileMd5 = '' then
  begin
    raise Exception.Create('�ļ���MD5Ϊ��,����!');
    exit ;
  end;
  strIp := m_FTPConfig.FTPConfig.strHost ;
  Result := m_dbFtpLog.IsExist(strIp,strFileMd5) ;
end;

function TFtpManager.UploadFile(FileName: string): Boolean;
begin
  m_FtpOper.FTPConfig := m_FTPConfig  ;
  Result := m_FtpOper.UploadFile(FileName) ;
end;

end.
