unit Utils.WindowMove;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Rtti, System.Classes, System.Variants,
  System.Notification, System.TypInfo, System.Generics.Collections,
  FMX.Platform,

  FMX.Types, FMX.Text, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls, FMX.Memo,
  FMX.Layouts;

type
  IWindowMove = interface
    ['{1BA5624D-87CD-4A3F-A31D-47B01B6F7767}']

    procedure RegisterControl(AControl: TControl);

    function WasMoved: Boolean;
  end;

  TWindowMove = class(TInterfacedObject, IWindowMove)
  private
    FForm: TCommonCustomForm;
    FMouseDown: TMouseEvent;
    FMouseMove: TMouseMoveEvent;
    FMouseUp: TMouseEvent;

    FControlList: TList<TControl>;
    FMouseDownList: TList<TMouseEvent>;
    FMouseMoveList: TList<TMouseMoveEvent>;
    FMouseUpList: TList<TMouseEvent>;

    FPos: TPointF;

    FWasMoved: Boolean;

    procedure DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure DoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    procedure RegisterControl(AControl: TControl);
    function WasMoved: Boolean;
  public
    constructor Create(AForm: TCommonCustomForm);
    procedure BeforeDestruction; override;
  end;

implementation

{ TC2NWindowMove }

constructor TWindowMove.Create(AForm: TCommonCustomForm);
begin
  inherited Create;

  FForm := AForm;

  FMouseDown := AForm.OnMouseDown;
  FMouseMove := AForm.OnMouseMove;
  FMouseUp := AForm.OnMouseUp;
  AForm.OnMouseDown := DoMouseDown;
  AForm.OnMouseMove := DoMouseMove;
  AForm.OnMouseUp := DoMouseUp;

  FControlList := TList<TControl>.Create;
  FMouseDownList := TList<TMouseEvent>.Create;
  FMouseMoveList := TList<TMouseMoveEvent>.Create;
  FMouseUpList := TList<TMouseEvent>.Create;
end;

procedure TWindowMove.BeforeDestruction;
begin
  FControlList.Free;
  FMouseDownList.Free;
  FMouseMoveList.Free;
  FMouseUpList.Free;

  inherited BeforeDestruction;
end;

procedure TWindowMove.DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FWasMoved := False;

  if Shift = [ssLeft] then
  begin
    FPos := Point(Round(X), Round(Y));
    FForm.MouseCapture;
    if (Sender <> FForm) and (FControlList.IndexOf(TControl(Sender)) >= 0) then
      FControlList[FControlList.IndexOf(TControl(Sender))].Root.Captured := IControl(TControl(Sender));
  end;

  if (Sender = FForm) and Assigned(FMouseDown) then
    FMouseDown(Sender, Button, Shift, X, Y)
  else if (FControlList.IndexOf(TControl(Sender)) >= 0) and Assigned(FMouseDownList[FControlList.IndexOf(TControl(Sender))]) then
    FMouseDownList[FControlList.IndexOf(TControl(Sender))](Sender, Button, Shift, X, Y);
end;

procedure TWindowMove.DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if (Shift = [ssLeft]) then
  begin
    FForm.Left := FForm.Left - Round((FPos.X - X));
    FForm.Top := FForm.Top - Round((FPos.Y - Y));
    FWasMoved := True;
  end;

  if (Sender = FForm) and Assigned(FMouseMove) then
    FMouseMove(Sender, Shift, X, Y)
  else if (FControlList.IndexOf(TControl(Sender)) >= 0) and Assigned(FMouseMoveList[FControlList.IndexOf(TControl(Sender))]) then
    FMouseMoveList[FControlList.IndexOf(TControl(Sender))](Sender, Shift, X, Y);
end;

procedure TWindowMove.DoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Sender = FForm then
    FForm.ReleaseCapture;

  if FWasMoved then
    Exit;

  if (Sender = FForm) and Assigned(FMouseUp) then
    FMouseUp(Sender, Button, Shift, X, Y)
  else if (FControlList.IndexOf(TControl(Sender)) >= 0) and Assigned(FMouseUpList[FControlList.IndexOf(TControl(Sender))]) then
    FMouseUpList[FControlList.IndexOf(TControl(Sender))](Sender, Button, Shift, X, Y);
end;

procedure TWindowMove.RegisterControl(AControl: TControl);
begin
  if FControlList.IndexOf(AControl) < 0 then
  begin
    FControlList.Add(AControl);
    FMouseDownList.Add(AControl.OnMouseDown);
    FMouseMoveList.Add(AControl.OnMouseMove);
    FMouseUpList.Add(AControl.OnMouseUp);

    AControl.OnMouseDown := DoMouseDown;
    AControl.OnMouseMove := DoMouseMove;
    AControl.OnMouseUp := DoMouseUp;
  end;
end;

function TWindowMove.WasMoved: Boolean;
begin
  Result := FWasMoved;
end;

end.
