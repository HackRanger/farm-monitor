<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <link
            rel="stylesheet"
            href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css"
            integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm"
            crossorigin="anonymous">

        <script>
            function encode(input) {
                var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
                var output = "";
                var chr1,
                    chr2,
                    chr3,
                    enc1,
                    enc2,
                    enc3,
                    enc4;
                var i = 0;

                while (i < input.length) {
                    chr1 = input[i++];
                    chr2 = i < input.length
                        ? input[i++]
                        : Number.NaN; // Not sure if the index
                    chr3 = i < input.length
                        ? input[i++]
                        : Number.NaN; // checks are needed here

                    enc1 = chr1 >> 2;
                    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
                    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
                    enc4 = chr3 & 63;

                    if (isNaN(chr2)) {
                        enc3 = enc4 = 64;
                    } else if (isNaN(chr3)) {
                        enc4 = 64;
                    }
                    output += keyStr.charAt(enc1) + keyStr.charAt(enc2) + keyStr.charAt(enc3) + keyStr.charAt(enc4);
                }
                return output;
            }

            window
                .addEventListener("load", function (evt) {
                    var output = document.getElementById("output");
                    var input = document.getElementById("input");
                    var ws;
                    var print = function (message) {
                        var d = document.createElement("div");
                        d.innerHTML = message;
                        output.appendChild(d);
                    };
                    document
                        .getElementById("connectcamera")
                        .onclick = function (evt) {
                        if (ws) {
                            return false;
                        }
                        ws = new WebSocket("{{.}}");
                        ws.binaryType = 'arraybuffer';
                        ws.onopen = function (evt) {
                            print("OPEN");
                        }
                        ws.onclose = function (evt) {
                            print("CLOSE");
                            ws = null;
                        }
                        ws.onmessage = function (evt) {
                            if (typeof evt.data == "object") {
                                var arrayBuffer = evt.data;
                                var bytes = new Uint8Array(arrayBuffer);
                                var image = document.getElementById('image');
                                image.with = 400;
                                image.height = 400;
                                image.src = 'data:image/png;base64,' + encode(bytes);
                            } else {
                                var table = document.getElementById("table");
                                $("#table tr").remove();
                                objArr = JSON.parse(evt.data);
                                objArr.forEach(element => {
                                    var row = table.insertRow(0);
                                    // Insert new cells (<td> elements) at the 1st and 2nd position of the "new"
                                    // <tr> element:
                                    var cell1 = row.insertCell(0);
                                    var cell2 = row.insertCell(1);
                                    // Add some text to the new cells:
                                    cell1.innerHTML = element.Tag;
                                    cell2.innerHTML = element.Confidance;
                                });

                            }
                        }
                        ws.onerror = function (evt) {
                            print("ERROR: " + evt.data);
                        }
                        return false;
                    };

                    document
                        .getElementById("disconnectcameralose")
                        .onclick = function (evt) {
                        if (!ws) {
                            return false;
                        }
                        ws.close();
                        return false;
                    };
                });
        </script>
    </head>
    <body>
        <div
            class="d-flex flex-column flex-md-row align-items-center p-3 px-md-4 mb-3 bg-white border-bottom box-shadow">
            <h5 class="my-0 mr-md-auto font-weight-normal">Farm Monitor</h5>
            <nav class="my-2 my-md-0 mr-md-3">
                <a class="p-2  btn-primary" href="#">Wild Life & Animals</a>
                <a class="p-2  btn-primary" href="#">People & Trespassers</a>
            </nav>
        </div>

        <div class="container-fluid">
            <div class="row">
                <nav class="col-md-2 d-none d-md-block bg-light sidebar">
                    <div class="sidebar-sticky">
                        <ul class="nav flex-column">
                            <li class="nav-item">
                                <a class="nav-link active" href="#">
                                    <span data-feather="home"></span>
                                    Dashboard
                                    <span class="sr-only">(current)</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#">
                                    <span data-feather="file"></span>
                                    Wildlife & Animals
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="#">
                                    <span data-feather="shopping-cart"></span>
                                    People & Trespassers
                                </a>
                            </li>
                        </ul>
                    </div>
                </nav>

                <main role="main" class="col-md-9 ml-sm-auto col-lg-10 pt-3 px-4">
                    <div
                        class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-3 border-bottom">
                        <h1 class="h2">Dashboard</h1>
                        <div class="btn-toolbar mb-2 mb-md-0">
                            <div class="btn-group mr-2">
                                <button class="btn btn-sm btn-outline-secondary">Share</button>
                                <button class="btn btn-sm btn-outline-secondary">Export</button>
                            </div>
                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle">
                                <span data-feather="calendar"></span>
                                This week
                            </button>
                        </div>
                    </div>

                    <table>
                        <tr>
                            <td valign="top" width="50%">
                                <form>
                                    <button
                                        type="button"
                                        class="btn btn-lg btn-primary btn-block"
                                        id="connectcamera">Connect Camera</button>
                                    <button
                                        type="button"
                                        class="btn btn-lg btn-primary btn-block"
                                        id="disconnectcamera">Disconnect Camera</button>
                                </form>
                                <div id="canvas" style="width: 400px; height: 400px; border: 2px solid black;">
                                    <img id="image" style="width: 395px; height: 395px;"/>
                                </div>

                            </td>
                            <td valign="top" width="50%">
                                <div id="output"></div>
                            </td>
                        </tr>
                    </table>

                    <h2>Detected Animals</h2>
                    <div class="table-responsive">
                        <table id="table" class="table table-striped table-sm"></table>
                    </div>
                </main>
            </div>
        </div>

        <script
            src="https://code.jquery.com/jquery-3.2.1.slim.min.js"
            integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN"
            crossorigin="anonymous"></script>
        <script
            src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js"
            integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q"
            crossorigin="anonymous"></script>
        <script
            src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js"
            integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl"
            crossorigin="anonymous"></script>
        <script src="/static/main.js"/>
    </body>
</html>