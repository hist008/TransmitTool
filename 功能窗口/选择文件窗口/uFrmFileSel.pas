unit uFrmFileSel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, XPMan, StdCtrls,uTFSystem, Menus, Buttons, PngBitBtn,
  PngSpeedButton, RzTreeVw, RzShellCtrls, FileCtrl, RzFilSys, RzShellDialogs;

type
  TFrmFileSel = class(TForm)
    lvFile: TListView;
    XPManifest1: TXPManifest;
    btnSelAll: TButton;
    btnSelOther: TButton;
    GroupBox1: TGroupBox;
    chkFtp: TCheckBox;
    chkShared: TCheckBox;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    btnSearch: TPngBitBtn;
    btnOk: TPngBitBtn;
    Label2: TLabel;
    edSearchText: TEdit;
    OpenDialog1: TRzOpenDialog;
    btnClear: TButton;
    btnRefresh: TPngBitBtn;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure lvFileColumnClick(Sender: TObject; Column: TListColumn);
    procedure btnSelAllClick(Sender: TObject);
    procedure btnSelOtherClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure lvFileCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure N1Click(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  private
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure AppOnMessage(var Msg: TMsg; var Handled: Boolean);
  private
    { Private declarations }
    {功能:初始化}
    procedure InitData();
    {功能:检车输入}
    function CheckInput():Boolean;

    function FindFile(const szSearchSubText: string; StartIndex: Integer): TListItem; overload;

  private
    m_FileList:TStringList ;
  public
    { Public declarations }
  end;

  {工能:获取文件列表}
  function GetSelFiles(FileList:TStringList;var IsUploadFtp,IsUploadShared:Boolean):Boolean;

implementation

uses
  uGlobalDM ,uWinUtils,ShellAPI;

var
  bAsc:Boolean = True ;



function CustomSortProc(Item1, Item2: TListItem; ColumnIndex: integer): integer; stdcall;
begin
  if ColumnIndex = 0 then
  begin
    if bAsc then
      Result := CompareText(Item1.Caption, Item2.Caption)
    else
     Result := CompareText( Item2.Caption, Item1.Caption ) ;
  end
  else
  begin
    if bAsc then
      Result := CompareText(Item1.SubItems[ColumnIndex - 1], Item2.SubItems[ColumnIndex - 1])
    else
      Result := CompareText(Item2.SubItems[ColumnIndex - 1] , Item1.SubItems[ColumnIndex - 1] ) ;
  end;
end;

{$R *.dfm}

  {工能:获取文件列表}
function GetSelFiles(FileList: TStringList;var IsUploadFtp,IsUploadShared:Boolean): Boolean;
var
  FrmFileSel: TFrmFileSel;
begin
  Result := False ;
  FrmFileSel := TFrmFileSel.Create(nil);
  try
    FrmFileSel.InitData();
    if FrmFileSel.ShowModal = mrOk then
    begin
      Result := True ;
      IsUploadFtp := FrmFileSel.chkFtp.Checked ;
      IsUploadShared := FrmFileSel.chkShared.Checked ;
      FileList.Assign(FrmFileSel.m_FileList);
    end;
  finally
    FreeAndNil(FrmFileSel);
  end;
end;




procedure TFrmFileSel.AppOnMessage(var Msg: TMsg; var Handled: Boolean);
var
  WMD: TWMDropFiles;
begin
  if Msg.message = WM_DROPFILES then
  begin
    WMD.Msg := Msg.message;
    WMD.Drop := Msg.wParam;
    WMD.Unused := Msg.lParam;
    WMD.Result := 0;
    WMDropFiles(WMD);
    Handled := TRUE;
  end;
end;

procedure TFrmFileSel.btnClearClick(Sender: TObject);
begin
  if not TBox('确认清空吗?') then
    Exit ;
  m_FileList.Clear;
  lvFile.Items.Clear ;
end;

procedure TFrmFileSel.btnOkClick(Sender: TObject);
var
  i : Integer ;
begin
  if not CheckInput then
    exit ;
  m_FileList.Clear;
  for I := 0 to lvFile.Items.Count - 1 do
  begin
    if lvFile.Items[i].Checked  then
    begin
      m_FileList.Add(lvFile.Items[i].Caption);
    end;
  end;
  ModalResult := mrOk ;
end;

procedure TFrmFileSel.btnRefreshClick(Sender: TObject);
begin
  InitData ;
end;

procedure TFrmFileSel.btnSearchClick(Sender: TObject);
begin
  MakeListItemVisible(self.FindFile(self.edSearchText.Text, 0));
  self.lvFile.Invalidate;
end;

procedure TFrmFileSel.btnSelAllClick(Sender: TObject);
var
  i: Integer;
begin
  for I := 0 to lvFile.Items.Count - 1 do
  begin
    lvFile.Items[i].Checked := True ;
  end;
end;

procedure TFrmFileSel.btnSelOtherClick(Sender: TObject);
var
  i : Integer ;
begin
  for I := 0 to lvFile.Items.Count - 1 do
  begin
    lvFile.Items[i].Checked :=  not lvFile.Items[i].Checked ;
  end;
end;

function TFrmFileSel.CheckInput: Boolean;
begin
  Result := False ;
  if ( chkFtp.Checked = False ) and ( chkShared.Checked = False ) then
  begin
    BoxErr('上传选择不能同时为空');
    exit ;
  end;
  Result := True ;
end;

function TFrmFileSel.FindFile(const szSearchSubText: string;
  StartIndex: Integer): TListItem;
var
  I: Integer;
begin
  for I := 0 to lvFile.Items.Count - 1 do
  begin
    result := lvFile.Items[I];

    if MatchItem(result, szSearchSubText) then
    begin
      exit;
    end;
  end;
  result := nil;
end;

procedure TFrmFileSel.FormCreate(Sender: TObject);
begin
  m_FileList := TStringList.Create ;
  chkFtp.Checked := False ;
  chkShared.Checked := False ;

  DragAcceptFiles(lvFile.Handle,True);
  Application.OnMessage := AppOnMessage;
end;

procedure TFrmFileSel.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(lvFile.Handle,False) ;
  m_FileList.Free ;
end;

procedure TFrmFileSel.InitData();
var
  Item : TListItem ;
  i : Integer ;
  Date:TDateTime ;
  strText : string ;
begin
  lvFile.Items.Clear ;
  m_FileList.Clear;

  GlobalDM.GetFileList(GlobalDM.SystemConfig.Folder,m_FileList);

  for I := 0 to m_FileList.Count - 1 do
  begin
    with lvFile do
    begin
      Item := lvFile.Items.add ;
      item.Caption := IntToStr(i+1);
      Item.SubItems.Add(m_FileList[i]) ;
      FileAge(m_FileList[i], Date);
      strText :=  FormatDateTime('yyyy-MM-dd hh:mm',Date);
      Item.SubItems.Add(strText) ;
      Item.Selected := False ;
    end;
  end;
end;


procedure TFrmFileSel.lvFileColumnClick(Sender: TObject; Column: TListColumn);
begin
  lvFile.CustomSort(@CustomSortProc,Column.Index);
  bAsc := not bAsc ;
end;

procedure TFrmFileSel.lvFileCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  //文本高亮标记 -add by LiMingLei 2015.7.2
  if Sender.Selected=Item then
  begin
    Sender.Canvas.Brush.Color := clHighlight;
    Sender.Canvas.Font.Color := clHighlightText;
    exit;
  end;

  if MatchItem(Item, edSearchText.Text) then
  begin
    Sender.Canvas.Brush.Color := clYellow;
    exit;
  end;
end;

procedure TFrmFileSel.N1Click(Sender: TObject);
var
  i : Integer ;
begin
  for I := 0 to lvFile.Items.Count - 1 do
  begin
    if lvFile.Items[i].Selected then
    begin
      lvFile.Items[i].Checked := True ;
    end;
  end;
end;

procedure TFrmFileSel.WMDropFiles(var Msg: TWMDropFiles);
var
  nCount : Integer ;
  i: Integer;
  buffer: array[0..MAX_PATH] of Char;
  item: TListItem;
  strText : string ;
  strFile : string ;
  Date:TDateTime ;
begin

  with Msg do
  begin
    nCount := DragQueryFile(Drop,$FFFFFFFF,nil,0) ;
    for i := 0 to nCount - 1 do
    begin
      fillchar(buffer,SizeOf(buffer),0);
      DragQueryFile(Drop, i, Buffer, SizeOf(buffer));
      strFile := string (buffer) ;

      Item := lvFile.Items.add ;
      item.Caption := IntToStr( lvFile.Items.Count + i  );
      Item.SubItems.Add(strFile) ;
      FileAge(strFile, Date);
      strText :=  FormatDateTime('yyyy-MM-dd hh:mm',Date);
      Item.SubItems.Add(strText) ;
      Item.Checked := True ;

    end;
    DragFinish(Drop);
  end;
end;

end.
