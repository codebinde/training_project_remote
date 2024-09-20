[
  serialNumber: 10,
  issuer: "vorwerk_root",
  subject: [
    countryName: "DE",
    organizationName: "Vorwerk",
    organizationalUnitName: "TEQS",
    commonName: "Integration Testing Intermediate CA"
  ],
  extensions: [
    basicConstraints: {[cA: true], :critical},
    keyUsage: {[:digitalSignature, :keyCertSign, :cRLSign], :critical}
  ]
]
