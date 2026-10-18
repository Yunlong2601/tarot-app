"""Makes a fake App Attest chain for tests (test-only keys, never Apple's).

Run: python3 test/fixtures/make-appattest.py > test/fixtures/appattest.json
Needs openssl. The root here stands in for Apple's App Attestation root CA.
"""
import base64, hashlib, json, os, subprocess, tempfile

APP_ID = "TEAMID1234.com.example.tarot"
INSTALL_ID = "5b0c4b7e-2f1a-4c55-9a7e-0d1f2e3a4b5c"
CHALLENGE = "dGVzdC1jaGFsbGVuZ2UtMTIzNDU2Nzg5MDEyMzQ1Njc4OQ=="

def run(*a, inp=None):
    return subprocess.run(a, check=True, capture_output=True, input=inp).stdout

def cbor(v):
    def head(major, n):
        if n < 24: return bytes([major << 5 | n])
        if n < 256: return bytes([major << 5 | 24, n])
        if n < 65536: return bytes([major << 5 | 25]) + n.to_bytes(2, "big")
        return bytes([major << 5 | 26]) + n.to_bytes(4, "big")
    if isinstance(v, bytes): return head(2, len(v)) + v
    if isinstance(v, str): b = v.encode(); return head(3, len(b)) + b
    if isinstance(v, int): return head(0, v)
    if isinstance(v, list): return head(4, len(v)) + b"".join(cbor(x) for x in v)
    if isinstance(v, dict): return head(5, len(v)) + b"".join(cbor(k) + cbor(x) for k, x in v.items())
    raise TypeError(v)

d = tempfile.mkdtemp()
p = lambda n: os.path.join(d, n)
run("openssl", "ecparam", "-name", "secp384r1", "-genkey", "-noout", "-out", p("root.key"))
run("openssl", "req", "-new", "-x509", "-key", p("root.key"), "-sha384", "-days", "7300", "-subj", "/CN=Test Root",
    "-addext", "basicConstraints=critical,CA:true", "-out", p("root.pem"))
run("openssl", "ecparam", "-name", "secp384r1", "-genkey", "-noout", "-out", p("int.key"))
run("openssl", "req", "-new", "-key", p("int.key"), "-subj", "/CN=Test Intermediate", "-out", p("int.csr"))
open(p("int.ext"), "w").write("basicConstraints=critical,CA:true\n")
run("openssl", "x509", "-req", "-in", p("int.csr"), "-CA", p("root.pem"), "-CAkey", p("root.key"), "-CAcreateserial",
    "-sha384", "-days", "7000", "-extfile", p("int.ext"), "-out", p("int.pem"))
run("openssl", "ecparam", "-name", "prime256v1", "-genkey", "-noout", "-out", p("leaf.key"))
run("openssl", "pkcs8", "-topk8", "-nocrypt", "-in", p("leaf.key"), "-out", p("leaf.p8"))
pub_der = run("openssl", "ec", "-in", p("leaf.key"), "-pubout", "-outform", "DER")
point = pub_der[-65:]
key_id = hashlib.sha256(point).digest()
auth_data = (hashlib.sha256(APP_ID.encode()).digest() + b"\x40" + (0).to_bytes(4, "big")
             + b"appattest\0\0\0\0\0\0\0" + len(key_id).to_bytes(2, "big") + key_id)
client_data = f"{INSTALL_ID}.{CHALLENGE}".encode()
nonce = hashlib.sha256(auth_data + hashlib.sha256(client_data).digest()).digest()
ext_der = bytes([0x30, 0x24, 0xA1, 0x22, 0x04, 0x20]) + nonce
run("openssl", "req", "-new", "-key", p("leaf.key"), "-subj", "/CN=Test Leaf", "-out", p("leaf.csr"))
open(p("leaf.ext"), "w").write(f"1.2.840.113635.100.8.2=DER:{ext_der.hex().upper()}\n")
run("openssl", "x509", "-req", "-in", p("leaf.csr"), "-CA", p("int.pem"), "-CAkey", p("int.key"), "-CAcreateserial",
    "-sha256", "-days", "6000", "-extfile", p("leaf.ext"), "-out", p("leaf.pem"))
der = lambda f: run("openssl", "x509", "-in", p(f), "-outform", "DER")
att = cbor({"fmt": "apple-appattest", "attStmt": {"x5c": [der("leaf.pem"), der("int.pem")], "receipt": b"r"}, "authData": auth_data})
print(json.dumps({
    "appId": APP_ID, "installId": INSTALL_ID, "challenge": CHALLENGE,
    "keyId": base64.b64encode(key_id).decode(), "attestation": base64.b64encode(att).decode(),
    "rootPem": open(p("root.pem")).read(), "leafPrivatePkcs8": open(p("leaf.p8")).read(),
}, indent=1))
