var files = [];
var sendingOffset = 0;
var lastRequest = '';
var dataView;
var filesCount = 0;
var currentUploadingFile = 0;
var uploadOrder = [];
var uploadingInProgress = 0;
var fileUploadRequest;

var chunkSize = 128;
var totalUploaded = 0;

var tpl = '<li class="working" id="file%filenum%"><div class="chart" id="graph%filenum%" data-percent="0"></div><p>%filename%<i>%filesize%</i></p><span class="delete" id="fileStatus%filenum%" onclick="DeleteFiles(%filenum%);"></span></li>';

document.addEventListener("DOMContentLoaded", function() {
    var dropbox;

    dropbox = document.getElementById("dropbox");
    dropbox.addEventListener("dragenter", dragenter, false);
    dropbox.addEventListener("dragover", dragover, false);
    dropbox.addEventListener("drop", drop, false);

    UpdateFileList();

    UploadDir("http");
});

function dragenter(e) {
    e.stopPropagation();
    e.preventDefault();
}

function dragover(e) {
    e.stopPropagation();
    e.preventDefault();
}

function drop(e) {
    e.stopPropagation();
    e.preventDefault();

    var dt = e.dataTransfer;

    handleFiles(dt.files);
}

function handleFiles(tfiles) {
    var filesCount = tfiles.length;
    files = tfiles;
    currentUploadingFile = 0;
    uploadOrder = [];

    sendingOffset = 0;
    lastRequest = '';

    document.getElementById('fileList').innerHTML = '';

    var fileNames = {};

    for (var i = 0; i < filesCount; i++) {
        fileNames[uploadDir + tfiles[i].name] = i;
    }

    Keys(fileNames).sort(function(a,b){var c=a.toLowerCase(),d=b.toLowerCase();return c<d?-1:c>d?1:0}).forEach(function(item) {
        var i = fileNames[item];

        var append = tpl.replace(/%filename%/g, uploadDir + tfiles[i].name);
        append = append.replace(/%filesize%/g, formatFileSize(tfiles[i].size));
        append = append.replace(/%filenum%/g, i);

        document.getElementById('fileList').insertAdjacentHTML('beforeend', append);

        UpdateGraph(0, i);

        uploadOrder.push(i);
    });
}

function DeleteFiles(filenum) {
    var elem = document.getElementById('file' + filenum.toString());
    elem.parentNode.removeChild(elem);

    if (uploadingInProgress) {
        if (parseInt(filenum) != uploadOrder[currentUploadingFile]) {
            for (var i = 0; i < uploadOrder.length; i++) {
                if (uploadOrder[i] == filenum) {
                    delete uploadOrder[i];
                }
            }
        }
        else {
            uploadingInProgress = 0;

            RemoveFile(files[uploadOrder[currentUploadingFile]].name + '.dnl');

            for (var i = 0; i < uploadOrder.length; i++) {
                if (uploadOrder[i] == filenum) {
                    delete uploadOrder[i];
                }
            }

            currentUploadingFile++;
            totalUploaded = 0;
            sendingOffset = 0;

            lastRequest = '';
            fileUploadRequest.abort();
            fileUploadRequest = 0;

            UploadFiles();
        }
    }
    else {
        for (var i = 0; i < uploadOrder.length; i++) {
            if (uploadOrder[i] == filenum) {
                delete uploadOrder[i];
            }
        }
    }
}

function UploadFiles() {
    if (uploadOrder[currentUploadingFile] === undefined) {
        uploadingInProgress = 0;

        if (currentUploadingFile < files.length - 1) {
            currentUploadingFile++;

            UploadFiles();
        }

        return;
    }

    var fileNum = uploadOrder[currentUploadingFile];
    var file = files[fileNum];
    var chunkLen = 0;
    var filedata = '';

    uploadingInProgress = 1;

    var fr = new FileReader();

    fr.onload = function() {
        dataView = null;
        dataView = new Uint8Array(fr.result);

        if (file.size <= chunkSize) {
            sendingOffset = 0;
            chunkLen = file.size;

            for (var i = 0; i < dataView.length; i++) {
                if (dataView[i] < 16) {
                    filedata += '0';
                }

                filedata += dataView[i].toString(16).toUpperCase();
            }
        }
        else {
            if (dataView.length - sendingOffset > chunkSize) {
                chunkLen = chunkSize;
            }
            else {
                chunkLen = dataView.length - sendingOffset;
            }


            for (var i = sendingOffset; i < sendingOffset + chunkLen; i++) {
                if (dataView[i] < 16) {
                    filedata += '0';
                }

                filedata += dataView[i].toString(16).toUpperCase();
            }
        }

        fileUploadRequest = new XMLHttpRequest();

        fileUploadRequest.onreadystatechange = function() {
            if (fileUploadRequest.readyState != 4) return;

            if (fileUploadRequest.status == 200) {
                if (chunkLen + sendingOffset < dataView.length) {
                    totalUploaded += chunkSize;

                    UpdateGraph(Math.round((totalUploaded / file.size) * 100), uploadOrder[currentUploadingFile]);

                    sendingOffset += chunkSize;
                    UploadFiles();
                }
                else {
                    var statusElement = document.getElementById('fileStatus' + uploadOrder[currentUploadingFile]);

                    sendingOffset = 0;

                    UpdateGraph(100, uploadOrder[currentUploadingFile]);

                    uploadingInProgress = 0;

                    UpdateFileList();

                    totalUploaded = 0;

                    if (statusElement) {
                        statusElement.classList.add("uploaded");
                    }

                    if (currentUploadingFile < files.length) {
                        currentUploadingFile++;
                        UploadFiles();
                    }
                }
            }
            else {
                UploadFiles();
            }

            fileUploadRequest = 0;
        }

        lastRequest = 'upload.lua?cmd=upload&filename=' + uploadDir + file.name + '&filesize=' + file.size + '&len=' + chunkLen + '&offset=' + sendingOffset + '&data=' + filedata;

        fileUploadRequest.timeout = 5000;
        fileUploadRequest.open('GET', lastRequest, true);
        fileUploadRequest.send();
    };

    fr.readAsArrayBuffer(file);
}

function UploadDir(dir) {
    if (uploadingInProgress == 0) {
        document.getElementById('dir').innerHTML = "/" + dir;
        uploadDir = dir;
        if (!(uploadDir == "")) {
            uploadDir += "/";
        }
    }
}

function formatFileSize(bytes) {
    if (typeof bytes !== 'number') {
        return '';
    }

    if (bytes >= 1073741824) {
        return (bytes / 1073741824).toFixed(2) + ' GB';
    }

    if (bytes >= 1048576) {
        return (bytes / 1048576).toFixed(2) + ' MB';
    }

    return (bytes / 1024).toFixed(2) + ' KB';
}

function UpdateGraph(percent, id) {
    var el = document.getElementById('graph' + id); // get canvas

    if (!el) {
        return;
    }

    var options = {
        percent:  el.getAttribute('data-percent') || 0,
        size: el.getAttribute('data-size') || 48,
        lineWidth: el.getAttribute('data-line') || 8,
        rotate: el.getAttribute('data-rotate') || 0
    }

    var canvas = document.createElement('canvas');

    if (typeof(G_vmlCanvasManager) !== 'undefined') {
        G_vmlCanvasManager.initElement(canvas);
    }

    var ctx = canvas.getContext('2d');
    canvas.width = canvas.height = options.size;

    el.appendChild(canvas);

    ctx.translate(options.size / 2, options.size / 2); // change center
    ctx.rotate((-1 / 2 + options.rotate / 180) * Math.PI); // rotate -90 deg

    var radius = (options.size - options.lineWidth) / 2;

    function drawCircle(color, lineWidth, percent) {
        if (percent) {
            percent = Math.min(Math.max(0, percent), 1);
            ctx.beginPath();
            ctx.arc(0, 0, radius, 0, Math.PI * 2 * percent, false);
            ctx.strokeStyle = color;
            ctx.lineCap = 'round'; // butt, round or square
            ctx.lineWidth = lineWidth
            ctx.stroke();
        }
    };

    options.percent = percent;

    drawCircle('#2e3134', options.lineWidth + 1, 100 / 100);
    drawCircle('#007a96', options.lineWidth, options.percent / 100);
}

function Keys(obj) {
    var keys = [];

    for(var key in obj){
        if(obj.hasOwnProperty(key)){
            keys.push(key);
        }
    }

    return keys;
}

function UpdateFileList() {
    var fileListRequest = new XMLHttpRequest();

    fileListRequest.onreadystatechange = function() {
        if (fileListRequest.readyState != 4) return;

        if (fileListRequest.status == 200) {
            var fileInfo = JSON.parse(fileListRequest.responseText);
            var fileList = fileInfo['files'];

            document.getElementById('fileInfo').innerHTML = '';

            var tpl = '<li class="working"><p style="left: 30px;">%filenamelink%<i>%filesize%</i></p><span class="delete" id="fileStatus" onclick="RemoveFile(\'%filename%\');"></span></li>';
            var tplTotal = '<li class="working"><p style="left: 30px;">Used:<i>%used%</i></p></li><li class="working"><p style="left: 30px;">Free:<i>%free%</i></p></li><li class="working"><p style="left: 30px;">Total:<i>%total%</i></p></li>';

            var append, link;

            Keys(fileList).sort(function(a,b){var c=a.toLowerCase(),d=b.toLowerCase();return c<d?-1:c>d?1:0}).forEach(function(item) {
                if (!item.match(/\.lc$/ig) && item.match(/^http\//ig)) {
                    link = item.replace(/\.gz$/g, '').replace(/^http\//g, '');
                    append = tpl.replace(/%filenamelink%/g, '<a href="' + link + '" target="_blank">' + item + '</a>');
                }
                else {
                    append = tpl.replace(/%filenamelink%/g, item);
                }

                append = append.replace(/%filename%/g, item);
                append = append.replace(/%filesize%/g, formatFileSize(parseInt(fileList[item])));
                document.getElementById('fileInfo').insertAdjacentHTML('beforeend', append);
            });

            append = tplTotal.replace(/%used%/g, formatFileSize(parseInt(fileInfo['used'])));
            append = append.replace(/%free%/g,   formatFileSize(parseInt(fileInfo['free'])));
            append = append.replace(/%total%/g,  formatFileSize(parseInt(fileInfo['total'])));

            document.getElementById('fileInfo').insertAdjacentHTML('beforeend', append);
        }
        else {

        }

        fileListRequest = null;
    }

    fileListRequest.open('GET', 'upload.lua?cmd=list', true);
    fileListRequest.send();
}

function RemoveFile(name) {
    var fileRemoveRequest = new XMLHttpRequest();

    fileRemoveRequest.onreadystatechange = function() {
        if (fileRemoveRequest.readyState != 4) return;

        if (fileRemoveRequest.status == 200) {
            UpdateFileList();
        }
    }

    fileRemoveRequest.open('GET', 'upload.lua?cmd=remove&filename=' + name, true);
    fileRemoveRequest.send();
}
