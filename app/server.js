const express = require("express");

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send(`
    <html>
      <head><title>AWS DevSecOps Security Gate Pipeline</title></head>
      <body>
        <h1>AWS DevSecOps Security Gate Pipeline</h1>
        <p>This sample app is used to validate SAST, SCA, DAST, and IaC scanning in AWS.</p>
      </body>
    </html>
  `);
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy" });
});

app.listen(port, () => {
  console.log(`Sample app listening on port ${port}`);
});
