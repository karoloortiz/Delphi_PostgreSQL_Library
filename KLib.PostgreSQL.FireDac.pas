{
  KLib Version = 3.0
  The Clear BSD License

  Copyright (c) 2020 by Karol De Nery Ortiz LLave. All rights reserved.
  zitrokarol@gmail.com

  Redistribution and use in source and binary forms, with or without
  modification, are permitted (subject to the limitations in the disclaimer
  below) provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.

  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY
  THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
}

unit KLib.PostgreSQL.FireDac;

interface

uses
  KLib.PostgreSQL.Info,
  FireDac.Comp.Client;

type

  T_Query = class(FireDac.Comp.Client.TFDQuery)
  end;

  T_Connection = class(FireDac.Comp.Client.TFDConnection)
  private
    function getPort: integer;
    procedure setport(value: integer);
  public
    property port: integer read getPort write setport;
  end;

function _getPostgreSQLTConnection(PostgreSQLCredentials: TPostgreSQLCredentials): T_Connection;

function getValidPostgreSQLTFDConnection(PostgreSQLCredentials: TPostgreSQLCredentials): TFDConnection;
function getPostgreSQLTFDConnection(PostgreSQLCredentials: TPostgreSQLCredentials): TFDConnection;

implementation

uses
  KLib.PostgreSQL.Validate,
  KLib.Utils,
  FireDac.VCLUI.Wait,
  FireDac.Stan.Def, FireDac.Stan.Async,
  FireDac.DApt,
  FireDac.Phys.PG, FireDac.Phys.PGDef,
  System.SysUtils;

function T_Connection.getPort: integer;
var
  port: integer;
begin
  port := TFDPhysPGConnectionDefParams
    (ResultConnectionDef.Params).Port;

  Result := port;
end;

procedure T_Connection.setport(value: integer);
begin
  TFDPhysPGConnectionDefParams(ResultConnectionDef.Params).Port := value;
end;

function _getPostgreSQLTConnection(PostgreSQLCredentials: TPostgreSQLCredentials): T_Connection;
var
  _FDConnection: TFDConnection;
  connection: T_Connection;
begin
  _FDConnection := getPostgreSQLTFDConnection(PostgreSQLCredentials);
  connection := T_Connection(_FDConnection);
  Result := connection;
end;

function getValidPostgreSQLTFDConnection(PostgreSQLCredentials: TPostgreSQLCredentials): TFDConnection;
var
  connection: TFDConnection;
begin
  validatePostgreSQLCredentials(PostgreSQLCredentials);
  connection := getPostgreSQLTFDConnection(PostgreSQLCredentials);
  Result := connection;
end;

function getPostgreSQLTFDConnection(PostgreSQLCredentials: TPostgreSQLCredentials): TFDConnection;
var
  connection: TFDConnection;
  _PGAdvanced: string;
begin
  validateRequiredPostgreSQLProperties(PostgreSQLCredentials);
  if PostgreSQLCredentials.ssl then
  begin
    _PGAdvanced := 'sslmode=require';
  end;
  connection := TFDConnection.Create(nil);
  with connection do
  begin
    LoginPrompt := false;

    DriverName := 'PG';
    with Params do
    begin
      with PostgreSQLCredentials do
      begin
        Values['Server'] := Server;
        Values['Port'] := IntToStr(port);
        Values['User_Name'] := credentials.username;
        Values['Password'] := credentials.password;
        Values['Database'] := database;
        Values['PGAdvanced'] := _PGAdvanced;
      end;
    end;
  end;
  Result := connection;
end;

end.
