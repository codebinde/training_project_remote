// For Phoenix.HTML support, including form and button helpers
// copy the following scripts into your javascript bundle:
// * deps/phoenix_html/priv/static/phoenix_html.js

// For Phoenix.Channels support, copy the following scripts
// into your javascript bundle:
// * deps/phoenix/priv/static/phoenix.js

// For Phoenix.LiveView support, copy the following scripts
// into your javascript bundle:
// * deps/phoenix_live_view/priv/static/phoenix_live_view.js

function formatTimestamp(date) {
  return date.toISOString().replace("T", " ").replace(/\.\d+Z/, "");
}

function createElement(message) {
  var text = document.createTextNode(message);
  var br = document.createElement("br");
  document.body.appendChild(br);
  document.body.appendChild(text);
}

function log(origin, dialogfunc, message, timestamp) {
  message = `[${formatTimestamp(timestamp)}] ${origin} ${message} ${dialogfunc}`;
  console.log(message);
  createElement(message);
}

async function dialogfunctions(dialogfunc, params, pid) {
  try {
    log("ONLINE_MOCK_COOKIDOO", dialogfunc, "opening", new Date());
    if (pid == null) {
      var res = await COOKIDOO.device[dialogfunc](params);
    } else {
      if (dialogfunc == "modesOverviewDialog") {
        var res = await COOKIDOO.device[dialogfunc]({pid});
      } else {
        var res = await COOKIDOO.device[dialogfunc](params, {pid});
      }
    }
    if (res.validationErrors) {
      log("ONLINE_MOCK_COOKIDOO", dialogfunc, "validationErrors occured opening", new Date());
    }
  } catch (error) {
    msg = `PARAMS: ${params}, PID: ${pid}, ERROR: ${JSON.stringify(error)}`;
    log("ONLINE_MOCK_COOKIDOO", dialogfunc, msg, new Date());
  } finally {
    log("ONLINE_MOCK_COOKIDOO", dialogfunc, "closed", new Date());
  }
}
