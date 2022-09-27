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

unit KLib.PostgreSQL.Utils;

interface

uses
  KLib.PostgreSQL.DriverPort, KLib.PostgreSQL.Info;

procedure emptyTable(tableName: string; connection: TConnection);

procedure executeQuery(sqlStatement: string; connection: TConnection);

function checkPostgreSQLCredentials(PostgreSQLCredentials: TPostgreSQLCredentials): boolean;
function checkRequiredPostgreSQLProperties(PostgreSQLCredentials: TPostgreSQLCredentials): boolean;

implementation

uses
  KLib.MyString,
  System.SysUtils;

procedure emptyTable(tableName: string; connection: TConnection);
const
  PARAM_TABLENAME = ':TABLENAME';
  DELETE_FROM_WHERE_PARAM_TABLENAME =
    'DELETE' + sLineBreak +
    'FROM' + sLineBreak +
    PARAM_TABLENAME;
var
  _queryStmt: myString;
begin
  _queryStmt := DELETE_FROM_WHERE_PARAM_TABLENAME;
  _queryStmt.setParamAsString(PARAM_TABLENAME, tableName);
  executeQuery(_queryStmt, connection);
end;

procedure executeQuery(sqlStatement: string; connection: TConnection);
var
  _query: TQuery;
begin
  _query := getTQuery(connection, sqlStatement);
  _query.ExecSQL;
  FreeAndNil(_query);
end;

function checkPostgreSQLCredentials(PostgreSQLCredentials: TPostgreSQLCredentials): boolean;
var
  _connection: TConnection;
  _result: boolean;
begin
  _connection := getPostgreSQLTConnection(PostgreSQLCredentials);
  try
    _connection.Connected := true;
    _result := true;
  except
    on E: Exception do
    begin
      _result := false;
    end;
  end;
  _connection.Connected := false;
  _connection.Free;

  Result := _result;
end;

function checkRequiredPostgreSQLProperties(PostgreSQLCredentials: TPostgreSQLCredentials): boolean;
var
  _result: boolean;
begin
  with PostgreSQLCredentials do
  begin
    _result := (server <> '') and (credentials.username <> '') and (credentials.password <> '') and (port <> 0);
  end;

  Result := _result;
end;

end.
