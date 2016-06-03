
    function isImageFile()
    {
        return fileData.mimeType === "image/jpeg" || fileData.mimeType === "image/png" ||
                fileData.mimeType === "image/gif";
    }

    function isAudioFile()
    {
        return fileData.mimeType === "audio/x-wav" || fileData.mimeType === "audio/mpeg" ||
                fileData.mimeType === "audio/x-vorbis+ogg" || fileData.mimeType === "audio/flac" ||
                fileData.mimeType === "audio/mp4";
    }

    function isVideoFile()
    {
        return fileData.mimeType === "video/quicktime" || fileData.mimeType === "video/mp4";
    }

    function isMediaFile()
    {
        return isAudioFile() | isVideoFile();
    }

    function isZipFile()
    {
        return fileData.mimeTypeInherits("application/zip");
    }

    function isRpmFile()
    {
        return fileData.mimeType === "application/x-rpm";
    }

    function isApkFile()
    {
        return fileData.suffix === "apk" && fileData.mimeType === "application/vnd.android.package-archive";
    }

    function quickView()
    {
        // dirs are special cases - there's no way to display their contents, so go to them
        if (fileData.isDir && fileData.isSymLink) {
            Functions.goToFolder(fileData.symLinkTarget);

        } else if (fileData.isDir) {
            Functions.goToFolder(fileData.file);

        } else {
            viewContents();
        }
    }

    function viewContents()
    {
        // view depending on file type
        if (isZipFile()) {
            pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                         { title: Functions.lastPartOfPath(fileData.file),
                           command: "unzip",
                           arguments: [ "-Z", "-2ht", fileData.file ] });

        } else if (isRpmFile()) {
            pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                         { title: Functions.lastPartOfPath(fileData.file),
                           command: "rpm",
                           arguments: [ "-qlp", "--info", fileData.file ] });

        } else if (fileData.mimeType === "application/x-tar" ||
                   fileData.mimeType === "application/x-compressed-tar" ||
                   fileData.mimeType === "application/x-bzip-compressed-tar") {
            pageStack.push(Qt.resolvedUrl("ConsolePage.qml"),
                         { title: Functions.lastPartOfPath(fileData.file),
                           command: "tar",
                           arguments: [ "tf", fileData.file ] });
        } else {
            pageStack.push(Qt.resolvedUrl("ViewPage.qml"), { path: page.file });
        }
    }

    function playAudio()
    {
        if (audioPlayer.playbackState !== MediaPlayer.PlayingState) {
            audioPlayer.source = fileData.file;
            audioPlayer.play();
        } else {
            audioPlayer.stop();
        }
    } 
