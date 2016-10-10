unit uSystemConfig;

interface

uses
  SysUtils,IniFiles,Windows,Classes,
  uFtpConfig,uSharedConfig;


const
  SCAN_INRVAL = 30 * 1000 ;

type

//=============================================================================
// 作者    author lyq
// 修改时间      date : 2015-11-13
//==============================================================================

  //重启参数
  RRebootParams = record
    bEnable:Boolean;
    dtCloseDate:TDateTime;
    dtLastCloseDate:TDateTime;    //上一次的关闭时间;
  end;


//==============================================================================
// 配置功能单元
// 作者    author lyq
// 修改时间      date : 2015-11-13
//==============================================================================
  TSystemConfig = class
  public
    //单例模式，获取实例和释放实例
    class function GetInstance(FileName: string): TSystemConfig;
    class procedure FreeInstnce();
  private
    //暂没有使用等待以后更新
    procedure   LoadFromFile(); deprecated;
    procedure   SaveToFile(); deprecated;
  private
    constructor Create(const FileName: string);
    destructor Destroy(); override;
  private
      // 上传间隔
    function GetInterval:Integer;
    procedure SetInterval(Interval:Integer);
    //上传目录
    function GetFolder:string;
    procedure SetFolder(Path:string);
    //上传后是否删除原文件
    function  GetEnableDelete():boolean;
    procedure SetEnableDelete(Del:boolean);

    //是否上传到FTP
    function  GetEnableFtp():boolean;
    procedure SetEnableFtp(Upload:boolean);

    //是否上传到共享目录
    function  GetEnableShared():boolean;
    procedure SetEnableShared(Upload:boolean);

    //上传过滤日期
    function GetUploadFilterDate :Integer ;
    procedure SetUploadFilterDate(Interval:Integer);

    //日期的记录时间
    function GetLogSaveDate:Integer;
    procedure SetLogSaveDate(Interval:Integer);

    {功能：设置和获取重启参数}
    procedure SetRebootParams(RebootParams:RRebootParams);
    function  GetRebootParams():RRebootParams;

    {功能：最后一次重启时间}
    procedure WriteLastCloseDate(Date:TDateTime);
  private
    var
      //配置文件名字
      m_strFileName:string;
    class var
      //引用计数
        FRefCount: Integer;
    class var
      //单例模式
      FInstance: TSystemConfig;
    var
      //INI读取类
      m_IniFile: TIniFile;
  public
    //FTP转发列表
    FTPConfigArray:     RFTPConfigArray ;
    //共享列表
    SharedConfigArray : RSharedConfigArray;
  private
    //间隔
    m_nInterval : Integer ;
    //
    m_strFolder : string ;
    //
    m_bEnableDelete : Boolean ;
    //
    m_bEnableFtp : Boolean ;
    //
    m_bEnableShared : Boolean ;
    //
    m_nUploadFilterDate : Integer ;
    //
    m_nLogSaveDate : Integer ;
    //
    m_dtLastCloseDate : TDateTime ;
    //
    m_RebootParams : RRebootParams ;
  public
    property FileName:string read m_strFileName write m_strFileName ;

    property Interval:Integer  read GetInterval write SetInterval;
    property Folder:string read GetFolder write SetFolder;
    property EnableDelete:Boolean  read GetEnableDelete write SetEnableDelete;
    //
    property EnableFtp:Boolean read GetEnableFtp write SetEnableFtp;
    property EnableShared:Boolean read GetEnableShared write  SetEnableShared;
    //文件上传的过滤日期
    property UploadFilterDate :Integer  read GetUploadFilterDate write SetUploadFilterDate;
    //日期的记录日期
    property LogSaveDate:Integer  read GetLogSaveDate write SetLogSaveDate;

    property RebootParams:RRebootParams   read  GetRebootParams  write SetRebootParams ;
    property LastCloseDate:TDateTime  write WriteLastCloseDate;
  end;


implementation

{ TSystemConfig }

constructor TSystemConfig.Create(const FileName: string);
begin
  m_strFileName := FileName ;
  m_IniFile := TIniFile.Create(FileName);
end;

destructor TSystemConfig.Destroy;
begin
  m_IniFile.Free ;
  inherited;
end;

class procedure TSystemConfig.FreeInstnce;
var
  nCount : Integer ;
begin
  nCount := InterlockedDecrement(FRefCount);
  if nCount = 0 then
    FreeAndNil(FInstance);
end;

class function TSystemConfig.GetInstance(FileName: string): TSystemConfig;
begin
  if FInstance = nil then
    FInstance := TSystemConfig.Create(FileName);

  //添加引用技术
  InterlockedIncrement(FRefCount);
  Result := FInstance ;
end;

function TSystemConfig.GetEnableFtp: boolean;
var
  strText:string;
begin
  Result := False ;
  strText := m_IniFile.ReadString('SysConfig','IsUploadFtp','0');
  if strText = '' then
    Exit
  else
    Result := StrToBool(strText);
end;

function TSystemConfig.GetEnableShared: boolean;
var
  strText:string;
begin
  Result := False ;
  strText := m_IniFile.ReadString('SysConfig','IsUploadShared','');
  if strText = '' then
    Exit
  else
    Result := StrToBool(strText);
end;

function TSystemConfig.GetLogSaveDate: Integer;
const
  DEFAULT_LOG_SAVE_DATE = 30 ;
begin
  Result := m_IniFile.ReadInteger('SysConfig','LogSaveDate',DEFAULT_LOG_SAVE_DATE);
end;

function TSystemConfig.GetRebootParams: RRebootParams;
begin
  Result.bEnable := True;
  Result.dtCloseDate := StrToTime('00:00') ;
  Result.dtLastCloseDate := 0;
  try
    Result.bEnable := StrToBool( m_IniFile.ReadString('RebootConfig', 'Enable',''));
    Result.dtCloseDate := StrToTime( m_IniFile.ReadString('RebootConfig', 'Date',''));
    Result.dtLastCloseDate := StrToDateTime( m_IniFile.ReadString('RebootConfig', 'LastDate',''));
  except

  end;
end;

function TSystemConfig.GetEnableDelete: boolean;
var
  strDel:string;
begin
  Result := False ;
  strDel := m_IniFile.ReadString('SysConfig','DelUploadFile','');
  if strDel = '' then
    Exit
  else
    Result := StrToBool(strDel);
end;

function TSystemConfig.GetUploadFilterDate: Integer;
const
  DEFAULT_FILTER_DATE = 3 ;
begin
  Result := m_IniFile.ReadInteger('SysConfig','UploadFilterDate',DEFAULT_FILTER_DATE);
end;

procedure TSystemConfig.LoadFromFile();
begin
  m_nInterval := GetInterval ;
  m_strFolder := GetFolder ;
  m_bEnableDelete := GetEnableDelete ;
  m_bEnableFtp := GetEnableFtp ;
  m_bEnableShared := GetEnableShared ;
  m_nUploadFilterDate := GetUploadFilterDate ;
  m_nLogSaveDate := GetLogSaveDate ;
  m_RebootParams := GetRebootParams ;
end;

function TSystemConfig.GetFolder: string;
begin
  Result := m_IniFile.ReadString('SysConfig','UploadFolder','');
end;

function TSystemConfig.GetInterval: Integer;
begin
  Result := m_IniFile.ReadInteger('SysConfig','UploadInterval',SCAN_INRVAL);
end;

procedure TSystemConfig.SetEnableFtp(Upload: boolean);
var
  strText:string;
begin
  if Upload then
    strText := '1'
  else
    strText := '0';
  m_IniFile.WriteString('SysConfig','IsUploadFtp',strText);
end;

procedure TSystemConfig.SetEnableShared(Upload: boolean);
var
  strText:string;
begin
  if Upload then
    strText := '1'
  else
    strText := '0';
  m_IniFile.WriteString('SysConfig','IsUploadShared',strText);
end;

procedure TSystemConfig.SetLogSaveDate(Interval: Integer);
begin
  m_IniFile.WriteInteger('SysConfig','LogSaveDate',Interval);
end;

procedure TSystemConfig.SetRebootParams(RebootParams: RRebootParams);
var
  strText:string;
  ConfigFileName:string;
begin
  if RebootParams.bEnable then
    strText := '1'
  else
    strText := '0';
  ConfigFileName := m_strFileName ;
  m_IniFile.WriteString('RebootConfig','Enable',strText);
  m_IniFile.WriteString('RebootConfig','Date',FormatDateTime('HH:mm',RebootParams.dtCloseDate));
end;

procedure TSystemConfig.SaveToFile();
begin
  SetInterval(m_nInterval);
  SetFolder(m_strFolder);
  SetEnableDelete(m_bEnableDelete);
  SetEnableFtp(m_bEnableFtp);
  SetEnableShared(m_bEnableShared) ;
  SetUploadFilterDate(m_nUploadFilterDate);
  SetLogSaveDate(m_nLogSaveDate);
  WriteLastCloseDate(m_dtLastCloseDate);
  SetRebootParams(m_RebootParams);
end;

procedure TSystemConfig.SetEnableDelete(Del: boolean);
var
  strDel:string;
begin
  if Del then
    strDel := '1'
  else
    strDel := '0';
  m_IniFile.WriteString('SysConfig','DelUploadFile',strDel);
end;

procedure TSystemConfig.SetUploadFilterDate(Interval: Integer);
begin
  m_IniFile.WriteInteger('SysConfig','UploadFilterDate',Interval);
end;

procedure TSystemConfig.SetFolder(Path: string);
begin
  m_IniFile.WriteString('SysConfig','UploadFolder',Path);
end;

procedure TSystemConfig.SetInterval(Interval: Integer);
begin
  m_IniFile.WriteInteger('SysConfig','UploadInterval',Interval);
end;

procedure TSystemConfig.WriteLastCloseDate(Date: TDateTime);
begin
  m_IniFile.WriteString('RebootConfig','LastDate',FormatDateTime('yyyy-MM-dd HH:mm:ss',Date));
end;

end.
