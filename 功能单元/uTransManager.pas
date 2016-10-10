unit uTransManager;

interface

uses
  ADODB ,SysUtils,DateUtils;

type
  {日志回调函数}
  TLogEvent = procedure (LogText:string;IsWriteFile:Boolean) of object ;
//==============================================================================
// 管理基类类 TTransBaseManager
// 管理基类类    author lyq
// 修改时间      date : 2015-11-13
//==============================================================================
  TTransBaseManager = class
  public
    constructor Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
    destructor Destroy();override;
  public
    //上传过程 {第二个参数表示否是是强制，如果是，就不检查文件的有效性}
    function UpLoad(FileName:string;IsForce:Boolean=False):Boolean;
  protected
    //上传文件 虚函数 需要各自的子类实现上传功能 
    function UploadFile(FileName:string):Boolean;virtual;abstract;
    //是否上传过
    function  IsUploaded(FileName:string):Boolean;virtual;abstract;
    //插入成功日志
    procedure InsertSuccessDBLog(FileName:string);virtual;abstract;
    //插入失败日志
    procedure InsertErrorDBLog(FileName:string); virtual;abstract;
  private
    //检测文件是否有效
    function IsValidFile(FileName:string):Boolean;
    //检测文件是否是过期文件
    function IsFileExpired(FileName:string;Day:Integer):Boolean;
  private
    //文件的过滤日期
    m_nFilterDate : Cardinal ;
    //是否停止
    m_bStopFlag : Boolean ;
    //界面日志
    m_logUI :TLogEvent ;
  published
    property FilterDate : Cardinal read m_nFilterDate write m_nFilterDate ;
    property UILog:TLogEvent  read m_logUI write m_logUI;
    property Stop : Boolean read m_bStopFlag write m_bStopFlag ;
  end;

implementation

{ TTransBaseManager }

constructor TTransBaseManager.Create(ADOConnection: TADOConnection;LogEvent:TLogEvent);
const
  DEFAULT_FILTER_DATE = 30 ;
begin
  m_logUI := LogEvent ;
  m_nFilterDate := DEFAULT_FILTER_DATE ;
  m_bStopFlag := False ;
end;

destructor TTransBaseManager.Destroy;
begin

  inherited;
end;

function TTransBaseManager.IsFileExpired(FileName: string;
  Day: Integer): Boolean;
var
  DateTimeModify: TDateTime;
  nDayInterval:Integer ;
  text:string ;
begin

  if Day = 0 then
  begin
    Result := False ;
    Exit ;
  end;

  if FileName = '' then
    Exception.Create('文件名为空');

  FileAge(FileName, DateTimeModify) ;
  text := FormatDateTime('yyyy-MM-dd hh:mm:ss',DateTimeModify);
  nDayInterval := DaysBetween(Now,DateTimeModify);
  if  nDayInterval >= Day  then
    Result := True
  else
    Result := False ;
end;

function TTransBaseManager.IsValidFile(FileName: string): Boolean;
begin
  //检测文件的修改日期是否在指定日期内
  Result :=  not IsFileExpired(FileName,m_nFilterDate);
end;

function TTransBaseManager.UpLoad(FileName: string;IsForce:Boolean): Boolean;
var
  strText : string ;
begin
  Result := False ;
  try
    //检查是否退出
    if m_bStopFlag then
    begin
      if Assigned(m_logUI) then
      begin
        strText := '检测到退出标志';
        m_logUI(strText,False);
      end;
      Exit ;
    end;

    //检查是否是强制上传
    if not IsForce then
    begin
      //检查文件是否过期
      if not IsValidFile(FileName) then
      begin
        if Assigned(m_logUI) then
        begin
          strText := Format(' 文件[%s] 过期', [FileName]);
          m_logUI(strText,False);
        end;
        Exit;
      end;
    end;

    //检查文件是否上传过
    if IsUploaded(FileName) then
    begin
      if Assigned(m_logUI) then
      begin
        strText := Format(' 文件:[%s] 已上传', [FileName]);
        m_logUI(strText, False);
      end;
      Exit;
    end;

    //上传文件
    Result := UploadFile(FileName);
  except
    on e:Exception do
    begin
      ;
    end;
  end;
  
end;

end.
