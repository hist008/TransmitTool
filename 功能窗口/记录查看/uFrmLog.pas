unit uFrmLog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, Grids, AdvObj, BaseGrid, AdvGrid, ComCtrls, RzDTP, StdCtrls,
  Buttons, PngCustomButton, ExtCtrls, RzPanel, RzCmboBx,uDBLog,uTFSystem,
  PngSpeedButton;

type
  TFrmLog = class(TForm)
    rzpnl3: TRzPanel;
    lb1: TLabel;
    lb2: TLabel;
    lb5: TLabel;
    dtpStartDate: TRzDateTimePicker;
    dtpStartTime: TDateTimePicker;
    dtpEndDate: TRzDateTimePicker;
    dtpEndTime: TDateTimePicker;
    edtFileName: TEdit;
    rzpnl2: TRzPanel;
    strGridLog: TAdvStringGrid;
    trz: TLabel;
    cmbLogType: TRzComboBox;
    edtIP: TEdit;
    btnQuery: TPngSpeedButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
  private
      //初始化
    procedure InitData();
    //信息展示
    procedure DataToGrid(LogList : TLogList);
  private
    { Private declarations }
    //数据库日志操作
    m_dbLog : TDBLog ;
    //日志列表
    m_logList : TLogList ;
  public
    { Public declarations }
    class procedure ShowLog();
  end;

var
  FrmLog: TFrmLog;

implementation

uses
  uGlobalDM ;

{$R *.dfm}

procedure TFrmLog.btnQueryClick(Sender: TObject);
begin
  InitData ;
end;

procedure TFrmLog.FormCreate(Sender: TObject);
begin
  m_dbLog :=  TDBLog.Create(GlobalDM.ADOConnection);
  //日志列表
  m_logList := TLogList.Create ;

  dtpStartDate.Date := Now ;
  dtpStartDate.Format := 'yyyy-MM-dd';
  dtpEndDate.Date := Now ;
  dtpEndDate.Format := 'yyyy-MM-dd';

end;

procedure TFrmLog.FormDestroy(Sender: TObject);
begin
  m_dbLog.Free ;
  //日志列表
  m_logList.Free ;
end;

procedure TFrmLog.InitData;
var
  dtStart:TDateTime ;
  dtEnd:TDateTime ;
  strIp : string ;
  strFileName:string ;
  LogType : TLogType ;
begin
  m_logList.Clear;

  dtStart := AssembleDateTime(dtpStartDate.Date,dtpStartTime.Time);
  dtEnd := AssembleDateTime(dtpEndDate.Date,dtpEndTime.Time) ;
  strIp := Trim(edtIP.Text) ;
  strFileName := Trim(edtFileName.Text) ;
  LogType :=   TLogType (cmbLogType.ItemIndex) ;
  m_dbLog.QueryLog(dtStart,dtEnd,LogType,strIp,strFileName,m_logList);
  DataToGrid(m_logList);
end;

procedure TFrmLog.DataToGrid(LogList: TLogList);
var
  i : Integer ;
  Log : TLog ;
begin
  
  with strGridLog do
  begin
    ClearRows(1, 10000);
    if LogList.Count > 0 then
      RowCount := LogList.Count + 1
    else begin
      RowCount := 2;
    end;
    for I := 0 to LogList.Count - 1 do
    begin
      Log := LogList.Items[i];
      Cells[0, i + 1] := inttoStr( i + 1 );
      Cells[1, i + 1] := Log.Ip ;
      Cells[2, i + 1] := ExtractFileName( Log.FileName );
      Cells[3, i + 1] := FormatDateTime('yyyy-MM-dd HH:mm:ss',Log.CreateTime);
    end;
  end;
end;

class procedure TFrmLog.ShowLog;
var
  frm : TFrmLog ;
begin
  frm :=  TFrmLog.Create(nil);
  try
    frm.ShowModal ;
  finally
    frm.Free;
  end;
end;

end.
