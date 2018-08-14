unit DSLSSL;

interface

uses
  SysUtils, Classes, Math, DSLUtils, DSLCrypto;

function TLS1PRF(const lab: RawByteString; const secret, seed; secretLen, seedLen, bytes: Integer): RawByteString;
function TLS1CalcKeyBlock(const ClientRandom, ServerRandom, PreMasterSecret; len: Integer): RawByteString; overload;
function TLS1CalcKeyBlock(const ClientRandom, ServerRandom, PreMasterSecret: RawByteString; len: Integer): RawByteString; overload;
function TLS1CalcFinishedDigest(const body; BodyLen: Integer;
  const MasterSecret; const SideMixer: RawByteString): RawByteString;

implementation

procedure TLS1PMD5(const secret, seed; secretLen, seedLen, bytes: Integer; var pmd5);
var
  cnt, i: Integer;
  A1, A2: TMD5Digest;
  p: PMD5Digest;
  ctx: THMAC_MD5Context;
begin
  cnt := (bytes - 1) div 16 + 1;
  ctx.init(secret, secretLen);
  ctx.update(seed, seedLen);
  A1 := ctx.finish;
  p := PMD5Digest(@pmd5);

  for i := 0 to cnt - 1 do
  begin
    ctx.reset;
    ctx.update(A1, SizeOf(A1));
    ctx.update(seed, seedLen);

    if bytes >= 16 then
    begin
      p^ := ctx.finish;
      Dec(bytes, 16);
    end
    else begin
      A2 := ctx.finish;
      Move(A2, P^, bytes);
      bytes := 0;
    end;

    Inc(p);

    ctx.Reset;
    ctx.update(A1, SizeOf(A1));
    A1 := ctx.finish;
  end;
end;

procedure TLS1PSHA1(const secret, seed; secretLen, seedLen, bytes: Integer; var psha1);
var
  cnt, i: Integer;
  A1, A2: T160BitBuf;
  p: P160BitBuf;
  ctx: THMAC_SHA1Context;
begin
  cnt := (bytes - 1) div 20 + 1;

  ctx.init(secret, secretLen);
  ctx.update(seed, seedLen);
  A1 := ctx.finish;
  p := P160BitBuf(@psha1);

  for i := 0 to cnt - 1 do
  begin
    ctx.reset;
    ctx.update(A1, SizeOf(A1));
    ctx.update(seed, seedLen);

    if bytes >= 20 then
    begin
      p^ := ctx.finish;
      Dec(bytes, 20);
    end
    else begin
      A2 := ctx.finish;
      Move(A2, P^, bytes);
      bytes := 0;
    end;

    Inc(p);

    ctx.Reset;
    ctx.update(A1, SizeOf(A1));
    A1 := ctx.finish;
  end;
end;

function TLS1PRF(const lab: RawByteString; const secret, seed; secretLen, seedLen, bytes: Integer): RawByteString;
var
  sSeed: RawByteString;
  i, cnt, labLen: Integer;
  H1, H2: array of Byte;
  p: PByteArray;
begin
  cnt := Ceil(secretLen / 2.0);
  labLen := Length(lab);
  SetLength(sSeed, seedLen + labLen);
  Move(Pointer(lab)^, Pointer(sSeed)^, labLen);
  Move(seed, PAnsiChar(sSeed)[labLen], seedLen);
  SetLength(H1, ((bytes - 1) div 16 + 1) * 16);
  SetLength(H2, ((bytes - 1) div 20 + 1) * 20);
  TLS1PMD5(secret, Pointer(sSeed)^, cnt, Length(sSeed), bytes, H1[0]);
  TLS1PSHA1(PAnsiChar(@secret)[SecretLen - cnt], Pointer(sSeed)^, cnt, Length(sSeed), bytes, H2[0]);

  SetLength(Result, bytes);
  p := PByteArray(Result);
  for i := 0 to bytes -1 do
    P[i] := H1[i] xor H2[i];
end;

function TLS1CalcKeyBlock(const ClientRandom, ServerRandom, PreMasterSecret; len: Integer): RawByteString;
var
  seed: array [0..63] of Byte;
  pms: RawByteString;
begin
  Move(ClientRandom, Seed[0], 32);
  Move(ServerRandom, Seed[32], 32);
  pms := TLS1PRF('master secret', PreMasterSecret, seed, 48, 64, 48);
  Move(ServerRandom, Seed[0], 32);
  Move(ClientRandom, Seed[32], 32);
  Result := TLS1PRF('key expansion', PreMasterSecret, seed, 48, 64, len);
end;

function TLS1CalcKeyBlock(const ClientRandom, ServerRandom, PreMasterSecret: RawByteString; len: Integer): RawByteString;
var
  seed: array [0..63] of Byte;
  pms: RawByteString;
begin
  Move(Pointer(ClientRandom)^, Seed[0], 32);
  Move(Pointer(ServerRandom)^, Seed[32], 32);
  pms := TLS1PRF('master secret', Pointer(PreMasterSecret)^, seed, 48, 64, 48);
  DbgOutput('pms: ' + MemHex(pms));
  Move(Pointer(ServerRandom)^, Seed[0], 32);
  Move(Pointer(ClientRandom)^, Seed[32], 32);
  Result := TLS1PRF('key expansion', Pointer(pms)^, seed, 48, 64, len);
end;

function TLS1CalcFinishedDigest(const body; BodyLen: Integer;
  const MasterSecret; const SideMixer: RawByteString): RawByteString;
var
  ms: array [0..47] of Byte;
  hashes: array [0..35] of Byte;
begin
  (*
  if (Side = sClient) then
    SideMixer := ('client finished')
  else
    SideMixer := ('server finished');
  *)

  hashes[0] := 36;
  P128BitBuf(@hashes[0])^ := MD5(body, BodyLen);
  P160BitBuf(@hashes[16])^ := SHA1(body, BodyLen);
  Move(MasterSecret, ms[0], 48);

  Result := TLS1PRF(SideMixer, ms, hashes, SizeOf(ms), SizeOf(hashes), 12);
end;

end.
