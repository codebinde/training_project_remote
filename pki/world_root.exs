[
  serialNumber: 1,
  subject: [
    organizationName: "World CA",
    commonName: "World CA Root"
  ],
  extensions: [
    basicConstraints: {[cA: true], :critical},
    keyUsage: {[:keyCertSign, :cRLSign], :critical}
  ]
]
