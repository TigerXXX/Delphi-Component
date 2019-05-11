{ ============================================
  Software Name : 	OLED Library
  ============================================ }
{ ******************************************** }
{ Written By WalWalWalides                     }
{ CopyRight � 2019                             }
{ Email : WalWalWalides@gmail.com              }
{ GitHub :https://github.com/walwalwalides     }
{ ******************************************** }
unit UOLEDKnob;

interface

uses ExtCtrls,Controls;
type TonKnobEdit    = procedure (Sender:Tobject;active:boolean;knob,value:integer) of object;
type TKnobEditor = class
  private
                  CurKnob:integer;

                  Active,MouseMoved:boolean;
                  lastvalue,TimerTicks:integer;
                  Timer:TTimer;
                  knobform:TWinControl;
                  SaveLedColor: boolean;  // Circular Reference
                  procedure OnTimer(Sender: TObject);
  public
                  KnobLedOffset:integer;
                  constructor Create(aknobform:TWinControl); // Circular Reference
                  Destructor Destroy;
                  procedure EditKeyEnd;
                  procedure EditKnobMouseMove(knob,value:integer);
                  procedure EditKnobMouseUp(knob:integer);
                  procedure EditKnobMouseDown(knob,value:integer);

                end;

implementation

{ TKnobEditor }

uses UOLEDBaseControlPanel,UOLEDControls,StdCtrls,Graphics;

constructor TKnobEditor.Create(aknobform: TWinControl);
begin
  knobform:=aknobform;
  KnobLedOffset:=0;

  Timer:=TTimer.Create(NIL);
  Timer.Enabled:=false;
  Timer.Interval:=300;
  Timer.OnTimer:=OnTimer;
end;

procedure TKnobEditor.OnTimer(Sender:TObject);
begin
  if timerticks<30 then with TRMCBaseControlPanel(knobform) do
  begin
    if KnobLedOffset<>0 then
    begin
      setLedColors(curKnob+KnobLedOffset,clBlack,clYellow);
      setLed(curKnob+KnobLedOffset,timerticks MOD 2 =0);
    end;
    inc(timerticks);
  end
  else EditKeyEnd;
end;

destructor TKnobEditor.Destroy;
begin
  Timer.Free;
end;

procedure TKnobEditor.EditKeyEnd;
begin
  timer.enabled:=false;
  if active then with TRMCBaseControlPanel(knobform) do
  begin
    if KnobLedOffset<>0 then
    begin
      setLedColors(curKnob+KnobLedOffset,clBlack,clRed);
      setLed(curKnob+KnobLedOffset,SaveLedColor);
    end;
    if assigned(onknobedit) then
      onknobedit(knobform,false,curknob,lastvalue);
  end;
  active:=false;
end;

procedure TKnobEditor.EditKnobMouseDown(knob,value: integer);
begin
  if active then EditKeyEnd;
  curknob:=knob;
  MouseMoved:=false;
  active:=true;
  timer.enabled:=true;
  timerticks:=0;
  lastvalue:=value;
  with TRMCBaseControlPanel(knobform) do
  begin
    SaveLedColor:=GetLed(curKnob+KnobLedOffset);
    if assigned(onknobedit) then
        onknobedit(knobform,true,curknob,value);
  end;
end;

procedure TKnobEditor.EditKnobMouseMove(knob, value: integer);
begin
    with TRMCBaseControlPanel(knobform) do
    if assigned(onknobedit) then
    begin
      onknobedit(knobform,false,curknob,lastvalue);
      onknobedit(knobform,true,curknob,value);
      lastvalue:=value;
    end;
    MouseMoved:=true;
end;

procedure TKnobEditor.EditKnobMouseUp(knob: integer);
begin
  if MouseMoved then EditKeyEnd;
end;

end.
