import idna

def test_idna():
    ts = TAINTED_STRING
    tb = TAINTED_BYTES

    ensure_tainted(
        idna.encode(ts),  # $ tainted encodeInput=ts encodeOutput=Attribute() encodeFormat=IDNA
        idna.encode(s=ts),  # $ tainted encodeInput=ts encodeOutput=Attribute() encodeFormat=IDNA

        idna.decode(tb),  # $ tainted decodeInput=tb decodeOutput=Attribute() decodeFormat=IDNA
        idna.decode(s=tb),  # $ tainted decodeInput=tb decodeOutput=Attribute() decodeFormat=IDNA
    )
